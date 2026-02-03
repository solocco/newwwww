#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# 🖼️ WALLPAPER SELECTOR (Theme-aware with Rofi)
# Features:
#   - Auto-detect current theme from flavours
#   - Load wallpapers from theme folder (via walls.map)
#   - Thumbnail preview in grid layout
#   - Apply with swww transition
# -----------------------------------------------------------------------------
set -u
set -o pipefail

# --- CONFIGURATION ---
readonly WALL_DIR="${WALL_DIR:-$HOME/pictures/walls}"
readonly MAP_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/flavours/walls.map"
readonly CACHE_DIR="${HOME}/.cache/rofi-wallpaper-thumbs"
readonly ROFI_THEME="${HOME}/.config/rofi/wallpaper-selector.rasi"
readonly THUMB_SIZE=300

# swww settings
readonly WALL_MODE="${WALL_MODE:-crop}"
readonly SWWW_TRANSITION="${SWWW_TRANSITION:-wipe}"
readonly SWWW_DURATION="${SWWW_DURATION:-2}"
readonly SWWW_ANGLE="${SWWW_ANGLE:-30}"

# State
readonly STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/autostart"
readonly LAST_THEME="$STATE_DIR/last_theme"

# Parallel jobs
readonly MAX_JOBS=$(($(nproc) * 2))

# Notification Config
readonly APP_NAME="Wallpaper"
readonly NOTIFY_ID=7774

# Per-theme cache files (will be set after theme detection)
CACHE_FILE=""
PATH_MAP=""
PLACEHOLDER_FILE="${CACHE_DIR}/_placeholder.png"

# --- DEPENDENCIES ---
for cmd in magick rofi swww flavours; do
    if ! command -v "$cmd" &>/dev/null; then
        notify_user "Missing dependency: $cmd"
        exit 1
    fi
done

mkdir -p "$CACHE_DIR"

# --- NOTIFICATION FUNCTIONS ---
have() {
    command -v "$1" >/dev/null 2>&1
}

notify_user() {
    local msg="$1"
    if have dunstify; then
        dunstify -a "$APP_NAME" -r "$NOTIFY_ID" -u low "$msg"
    else
        notify-send -a "$APP_NAME" -u low \
            -h string:x-canonical-private-synchronous:"wallpaper-selector" \
            "$msg"
    fi
}

# --- FUNCTIONS ---
ensure_placeholder() {
    if [[ ! -f "$PLACEHOLDER_FILE" ]]; then
        magick -size "${THUMB_SIZE}x${THUMB_SIZE}" xc:"#333333" \
            "$PLACEHOLDER_FILE" 2>/dev/null
    fi
}

generate_single_thumb() {
    local file="$1"
    local filename="${file##*/}"
    local thumb="${CACHE_DIR}/${filename}.png"
    
    [[ -f "$thumb" && "$thumb" -nt "$file" ]] && return 0
    
    nice -n 19 magick "$file" \
        -strip \
        -resize "${THUMB_SIZE}x${THUMB_SIZE}^" \
        -gravity center \
        -extent "${THUMB_SIZE}x${THUMB_SIZE}" \
        "$thumb" 2>/dev/null
}

export -f generate_single_thumb
export CACHE_DIR THUMB_SIZE

get_current_theme() {
    local theme
    theme="$(flavours current 2>/dev/null | awk 'NF{print; exit}')"
    
    if [[ -n "$theme" ]]; then
        echo "$theme"
        return
    fi
    
    if [[ -f "$LAST_THEME" ]]; then
        cat "$LAST_THEME"
        return
    fi
    
    echo ""
}

resolve_wall_folder() {
    local theme="$1"
    
    # STRICT: Only check MAP_FILE, no fallback
    if [[ -f "$MAP_FILE" ]]; then
        local map_path
        map_path="$(awk -v t="$theme" '($1==t){$1=""; sub(/^[ \t]+/,""); print; exit}' "$MAP_FILE")"
        if [[ -n "$map_path" ]]; then
            map_path="${map_path/#\~/$HOME}"
            if [[ -d "$map_path" ]]; then
                echo "$map_path"
                return 0
            fi
        fi
    fi
    
    # No fallback - if theme not in walls.map, return empty
    echo ""
    return 1
}

refresh_cache() {
    local folder="$1"
    local theme="$2"
    
    # Cache per theme
    local theme_cache="${THEME_CACHE_DIR}"
    
    notify_user "Building cache..."
    
    ensure_placeholder
    
    # 1. Generate thumbnails with better error handling
    local count=0
    while IFS= read -r -d '' file; do
        local filename="${file##*/}"
        local thumb="${theme_cache}/${filename}.png"
        
        # Skip if thumbnail exists and is newer
        [[ -f "$thumb" && "$thumb" -nt "$file" ]] && continue
        
        # Generate thumbnail
        if magick "$file" \
            -strip \
            -resize "${THUMB_SIZE}x${THUMB_SIZE}^" \
            -gravity center \
            -extent "${THUMB_SIZE}x${THUMB_SIZE}" \
            "$thumb" 2>/dev/null; then
            ((count++))
        else
            echo "Failed to generate thumb for: $filename" >&2
        fi
        
        # Limit concurrent jobs
        if (( count % MAX_JOBS == 0 )); then
            wait
        fi
        
    done < <(find "$folder" -maxdepth 2 -type f \( \
        -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
        -o -iname "*.webp" -o -iname "*.gif" \
    \) -print0)
    
    # Wait for all background jobs
    wait
    
    echo "Generated $count thumbnails" >&2
    
    # 2. Build cache files
    : > "$CACHE_FILE"
    : > "$PATH_MAP"
    
    while IFS= read -r -d '' file; do
        local filename="${file##*/}"
        local thumb="${theme_cache}/${filename}.png"
        
        local icon
        if [[ -f "$thumb" ]]; then
            icon="$thumb"
        else
            icon="$PLACEHOLDER_FILE"
            echo "Using placeholder for: $filename" >&2
        fi
        
        # Format: Name \0 icon \x1f PathToIcon
        printf '%s\0icon\x1f%s\n' "$filename" "$icon" >> "$CACHE_FILE"
        
        # Map: Name -> FullPath
        printf '%s\t%s\n' "$filename" "$file" >> "$PATH_MAP"
        
    done < <(find "$folder" -maxdepth 2 -type f \( \
        -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
        -o -iname "*.webp" -o -iname "*.gif" \
    \) -print0 | sort -z)
    
    echo "Cache built: $(wc -l < "$CACHE_FILE") entries" >&2
}

resolve_path() {
    local name="$1"
    awk -F'\t' -v t="$name" '$1 == t {print $2; exit}' "$PATH_MAP"
}

apply_wallpaper() {
    local img="$1"
    
    swww img "$img" \
        --resize "$WALL_MODE" \
        --transition-type "$SWWW_TRANSITION" \
        --transition-duration "$SWWW_DURATION" \
        --transition-angle "$SWWW_ANGLE" \
        --transition-fps 60 &
    
    notify_user "Applied: $(basename "$img")"
}

# --- MAIN LOGIC ---
current_theme="$(get_current_theme)"
if [[ -z "$current_theme" ]]; then
    notify_user "No active theme found"
    exit 1
fi

wall_folder="$(resolve_wall_folder "$current_theme")"
if [[ -z "$wall_folder" ]]; then
    notify_user "Theme not found in walls.map"
    exit 1
fi

# Set per-theme cache paths
readonly THEME_CACHE_DIR="${CACHE_DIR}/${current_theme}"
readonly CACHE_FILE="${THEME_CACHE_DIR}/rofi_input.cache"
readonly PATH_MAP="${THEME_CACHE_DIR}/path_map.cache"
mkdir -p "$THEME_CACHE_DIR"

# Refresh cache if needed
if [[ ! -s "$CACHE_FILE" ]] || [[ "$wall_folder" -nt "$CACHE_FILE" ]]; then
    refresh_cache "$wall_folder" "$current_theme"
fi

# Check if cache has content
if [[ ! -s "$CACHE_FILE" ]]; then
    notify_user "No wallpapers found"
    exit 1
fi

# Launch Rofi
selection=$(rofi \
    -dmenu \
    -i \
    -show-icons \
    -theme "$ROFI_THEME" \
    -p "Select Wallpaper" \
    < "$CACHE_FILE"
)

exit_code=$?
if [[ $exit_code -ne 0 ]]; then
    exit 0
fi

if [[ -n "$selection" ]]; then
    full_path="$(resolve_path "$selection")"
    
    if [[ -n "$full_path" && -f "$full_path" ]]; then
        apply_wallpaper "$full_path"
    else
        rm -f "$CACHE_FILE"
        notify_user "Path error. Cache cleared."
    fi
fi
