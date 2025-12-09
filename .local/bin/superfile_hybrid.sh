#!/bin/bash
# Hybrid superfile theme mapper
# Gunakan builtin theme jika ada yang match, generate custom jika tidak
# Usage: superfile_hybrid.sh <scheme-name>

SCHEME="${1:-gruvbox-dark-medium}"
SUPERFILE_THEME_DIR="$HOME/.config/superfile/theme"
SUPERFILE_CONFIG="$HOME/.config/superfile/theme.toml"
FLAVOURS_TEMPLATE="$HOME/.config/flavours/templates/superfile/templates/default.mustache"

# Map Base16 schemes ke builtin theme superfile
declare -A BUILTIN_THEME_MAP=(
    [aamis]="monokai"
    [boombox]="boombox"
    [catppuccin-latte]="catppuccin-latte"
    [catppuccin-mocha]="catppuccin-mocha"
    [dracula]="dracula"
    [everforest-dark-medium]="everforest-dark-medium"
    [gruvbox-dark-medium]="gruvbox-dark-medium"
    [nord]="nord"
    [onedark]="onedark"
    [pine]="pine"
    [rose-pine-moon]="rose-pine-moon"
    [solarized-dark]="solarized-dark"
    [tokyo-night-storm]="tokyonight"
)

# Map ke chroma style untuk syntax highlight
declare -A CHROMA_STYLE_MAP=(
    [aamis]="monokai"
    [boombox]="dracula"
    [catppuccin-latte]="monokai"
    [catppuccin-mocha]="dracula"
    [dracula]="dracula"
    [everforest-dark-medium]="monokai"
    [gruvbox-dark-medium]="gruvbox"
    [nord]="nord"
    [onedark]="monokai"
    [pine]="monokai"
    [rose-pine-moon]="dracula"
    [solarized-dark]="solarized-dark"
    [tokyo-night-storm]="dracula"
)

# Cek apakah builtin theme tersedia
BUILTIN_THEME="${BUILTIN_THEME_MAP[$SCHEME]}"
BUILTIN_PATH="$SUPERFILE_THEME_DIR/${BUILTIN_THEME}.toml"

if [ -f "$BUILTIN_PATH" ]; then
    # Gunakan builtin theme
    cp "$BUILTIN_PATH" "$SUPERFILE_CONFIG"
    echo "✓ Superfile theme updated: $BUILTIN_THEME (builtin)"
else
    # Generate custom theme dengan flavours
    if [ -f "$FLAVOURS_TEMPLATE" ]; then
        echo "⚠ Builtin theme not found, generating custom theme..."
        # Biarkan flavours handle generation melalui hook normal
        echo "✓ Custom superfile theme will be generated"
    else
        echo "✗ Template not found: $FLAVOURS_TEMPLATE"
        exit 1
    fi
fi

# Update syntax highlight chroma style
CHROMA_STYLE="${CHROMA_STYLE_MAP[$SCHEME]:-monokai}"
if [ -f "$SUPERFILE_CONFIG" ]; then
    sed -i "s/code_syntax_highlight = .*/code_syntax_highlight = \"$CHROMA_STYLE\"/" "$SUPERFILE_CONFIG"
    echo "✓ Syntax highlight updated to: $CHROMA_STYLE"
fi
