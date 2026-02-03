# ~/.config/nushell/env.nu — Nushell environment configuration (loaded before config.nu)

##### PATH Configuration
# Nushell uses $env.PATH which is a list, not a colon-separated string
# Prepend custom paths (they have priority)
$env.PATH = (
  $env.PATH
  | split row (char esep)
  | prepend [
      ($env.HOME | path join '.nix-profile' 'bin')
      ($env.HOME | path join '.nix-profile' 'sbin')
      '/nix/var/nix/profiles/default/bin'
      ($env.HOME | path join 'bin')
      ($env.HOME | path join '.local' 'bin')
      ($env.HOME | path join '.local' 'personal')
    ]
  | uniq  # Remove duplicates
)

##### Core terminal environment
$env.TERMINAL = "foot"
$env.TERM = "xterm-256color"
$env.CLICOLOR = "1"
$env.EDITOR = "nvim"
$env.VISUAL = "nvim"
$env.PAGER = "less"
$env.FILE = "nnn"

##### Locale
$env.LANG = "en_US.UTF-8"
$env.LC_ALL = "en_US.UTF-8"

##### XDG Base Directory
$env.XDG_CONFIG_HOME = ($env.HOME | path join '.config')
$env.XDG_DATA_HOME = ($env.HOME | path join '.local' 'share')
$env.XDG_CACHE_HOME = ($env.HOME | path join '.cache')
$env.XDG_RUNTIME_DIR = $"/run/user/(id -u | str trim)"

##### XDG-compliant app settings
$env.NOTMUCH_CONFIG = ($env.XDG_CONFIG_HOME | path join 'notmuch-config')
$env.GTK2_RC_FILES = ($env.XDG_CONFIG_HOME | path join 'gtk-2.0' 'gtkrc-2.0')
$env.WGETRC = ($env.XDG_CONFIG_HOME | path join 'wget' 'wgetrc')
$env.WINEPREFIX = ($env.XDG_DATA_HOME | path join 'wineprefixes' 'default')
$env.KODI_DATA = ($env.XDG_DATA_HOME | path join 'kodi')
$env.PASSWORD_STORE_DIR = ($env.XDG_DATA_HOME | path join 'password-store')
$env.ANDROID_SDK_HOME = ($env.XDG_CONFIG_HOME | path join 'android')
$env.CARGO_HOME = ($env.XDG_DATA_HOME | path join 'cargo')
$env.GOPATH = ($env.XDG_DATA_HOME | path join 'go')
$env.ANSIBLE_CONFIG = ($env.XDG_CONFIG_HOME | path join 'ansible' 'ansible.cfg')
$env.WEECHAT_HOME = ($env.XDG_CONFIG_HOME | path join 'weechat')
$env.MBSYNCRC = ($env.XDG_CONFIG_HOME | path join 'mbsync' 'config')
$env.ELECTRUMDIR = ($env.XDG_DATA_HOME | path join 'electrum')
$env.NPM_CONFIG_USERCONFIG = ($env.XDG_CONFIG_HOME | path join 'npm' 'npmrc')

##### App-specific
$env.LESSHISTFILE = "-"
$env.GTK_OVERLAY_SCROLLING = "0"
$env._JAVA_AWT_WM_NONREPARENTING = "1"
$env.TMUX_TMPDIR = $env.XDG_RUNTIME_DIR
$env.GTK_USE_PORTAL = "1"

##### Nix
$env.NIX_PATH = $"nixpkgs=($env.HOME)/.nix-defexpr/channels/nixpkgs"
$env.NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt"

##### FZF theming (Kintsugi Dark Flared inspired)
$env.FZF_DEFAULT_OPTS = "
  --color=fg:#BCAC8F,bg:#161618,hl:#DBAD49
  --color=fg+:#dddddd,bg+:#20201f,hl+:#b8943a
  --color=border:#2a2a28,header:#798283,gutter:#161618
  --color=spinner:#E08542,info:#6c7a8a,separator:#2a2a28
  --color=pointer:#DBAD49,marker:#b38f8f,prompt:#c9c4b8"

##### NNN options (only if installed)
if (which nnn | is-not-empty) {
  $env.NNN_OPTS = "dH"
}

##### Bootstrap /tmp/upd directory (once per session)
if not ('/tmp/upd' | path exists) {
  mkdir /tmp/upd
  
  # Create empty files
  [
    '/tmp/upd/count'
    '/tmp/upd/updates'
    '/tmp/upd/new'
    '/tmp/upd/old'
    '/tmp/upd/pretty'
    '/tmp/upd/installed'
  ] | each { |file| touch $file }
  
  # Write 0 to count file
  "0" | save -f /tmp/upd/count
}

##### Starship Prompt Configuration (if installed)
if (which starship | is-not-empty) {
    $env.STARSHIP_SHELL = "nu"
    $env.STARSHIP_SESSION_KEY = (random chars -l 16)

    # Define Starship prompt function
    def create_left_prompt [] {
        starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
    }

    # Set prompt command
    $env.PROMPT_COMMAND = { || create_left_prompt }
    $env.PROMPT_COMMAND_RIGHT = ""

    # Prompt indicators
    $env.PROMPT_INDICATOR = ""
    $env.PROMPT_INDICATOR_VI_INSERT = ": "
    $env.PROMPT_INDICATOR_VI_NORMAL = "〉"
    $env.PROMPT_MULTILINE_INDICATOR = "::: "
} else {
    # Fallback to default Nushell prompt if Starship is not installed
    $env.PROMPT_INDICATOR = "〉"
    $env.PROMPT_INDICATOR_VI_INSERT = ": "
    $env.PROMPT_INDICATOR_VI_NORMAL = "〉"
    $env.PROMPT_MULTILINE_INDICATOR = "::: "
}
