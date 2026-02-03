# ~/.config/nushell/config.nu — Nushell configuration

##### Aliases
alias la = ^lsd -al
alias lls = ^lsd --color=auto
alias ll = ls -la
alias l = ls -a
alias lh = ls -lh
alias lsd = ^lsd  
alias lb = lsblk
alias cat = bat
alias vpy = .venv/bin/python
alias vpip = .venv/bin/python -m pip

# System
alias p = sudo poweroff
alias r = sudo reboot
alias mi = sudo make install
alias mc = make clean
alias sudo = doas

# Foot reload
alias rel = pkill -HUP -x foot

# Git
alias gcl = git clone
alias gc = git commit -m
alias gp = git push -u

# JJ (Jujutsu)
alias jcl = jj git clone --colocate
alias jc = jj commit -m 
alias jp = jj push -u

##### Custom Commands (XBPS wrappers)
def q [...query: string] {
  xbps-query -Rs ...$query
}

def u [...packages: string] {
  sudo xbps-install -Su ...$packages
}

def i [...packages: string] {
  sudo xbps-install -S ...$packages
}

def d [...packages: string] {
  sudo xbps-remove ...$packages
}

def c [] {
  sudo xbps-remove -o
  sudo xbps-remove -O
}

def foot-reload [] {
  try { pkill -HUP -x foot }
}

##### Basic Nushell Config
$env.config = {
  show_banner: false
  edit_mode: emacs
  buffer_editor: "nvim"
  
  datetime_format: {
    normal: "%d/%m/%Y %H:%M"
    table: "%d/%m/%Y %H:%M"
  }
  
  completions: {
    case_sensitive: false
    quick: true
    partial: true
  }
  
  keybindings: [
    {
      name: completion_menu
      modifier: none
      keycode: tab
      mode: [emacs vi_normal vi_insert]
      event: {
        until: [
          { send: menu name: completion_menu }
          { send: menunext }
        ]
      }
    }
  ]
  
  # Color theme (Kintsugi Dark Flared inspired)
  color_config: {
    separator: "#75715e"
    leading_trailing_space_bg: { attr: "n" }
    header: { fg: "#DBAD49" attr: "b" }
    empty: "#6c7a8a"
    bool: {
      true: "#a3be8c"
      false: "#b38f8f"
    }
    int: "#DB9833"
    filesize: {
      b: "#6c7a8a"
      kb: "#6c7a8a"
      mb: "#6c7a8a"
      gb: "#a3be8c"
      tb: "#a3be8c"
      pb: "#a3be8c"
      eb: "#a3be8c"
    }
    duration: "#c9c4b8"
    date: { fg: "#c9c4b8" attr: "n" }
    range: "#c9c4b8"
    float: "#DB9833"
    string: "#cc7f66"
    nothing: "#c9c4b8"
    binary: "#6c7a8a"
    cellpath: "#c9c4b8"
    row_index: { fg: "#a3be8c" attr: "b" }
    record: "#c9c4b8"
    list: "#c9c4b8"
    block: "#c9c4b8"
    hints: "dark_gray"
    search_result: { fg: "#b8943a" bg: "#20201f" }
    shape_and: { fg: "#D66848" attr: "b" }
    shape_binary: { fg: "#b38f8f" attr: "b" }
    shape_block: { fg: "#6c7a8a" attr: "b" }
    shape_bool: "#a3be8c"
    shape_closure: { fg: "#a3be8c" attr: "b" }
    shape_custom: "#a3be8c"
    shape_datetime: { fg: "#6c7a8a" attr: "b" }
    shape_directory: "#6c7a8a"
    shape_external: "#6c7a8a"
    shape_externalarg: { fg: "#a3be8c" attr: "b" }
    shape_filepath: "#6c7a8a"
    shape_flag: { fg: "#6c7a8a" attr: "b" }
    shape_float: { fg: "#DB9833" attr: "b" }
    shape_garbage: { fg: "#FFFFFF" bg: "#b38f8f" attr: "b" }
    shape_globpattern: { fg: "#6c7a8a" attr: "b" }
    shape_int: { fg: "#DB9833" attr: "b" }
    shape_internalcall: { fg: "#6c7a8a" attr: "b" }
    shape_list: { fg: "#6c7a8a" attr: "b" }
    shape_literal: "#6c7a8a"
    shape_match_pattern: "#a3be8c"
    shape_matching_brackets: { attr: "u" }
    shape_nothing: "#a3be8c"
    shape_operator: "#E08542"
    shape_or: { fg: "#D66848" attr: "b" }
    shape_pipe: { fg: "#D66848" attr: "b" }
    shape_range: { fg: "#ebcb8b" attr: "b" }
    shape_record: { fg: "#6c7a8a" attr: "b" }
    shape_redirection: { fg: "#D66848" attr: "b" }
    shape_signature: { fg: "#a3be8c" attr: "b" }
    shape_string: "#cc7f66"
    shape_string_interpolation: { fg: "#6c7a8a" attr: "b" }
    shape_table: { fg: "#6c7a8a" attr: "b" }
    shape_variable: "#DBAD49"
    shape_vardecl: "#DBAD49"
  }
}
