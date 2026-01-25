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

# System
alias p = sudo poweroff
alias r = sudo reboot
alias mi = sudo make install
alias mc = make clean
alias sudo = doas

# Foot reload
alias rel = pkill -HUP -x foot

# Git
alias gc = git commit -m
alias gp = git push -u

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

##### Starship Prompt
# Setup starship first with: mkdir -p ~/.cache/starship && starship init nu > ~/.cache/starship/init.nu
# Then uncomment this line:
# source ~/.cache/starship/init.nu

##### Basic Nushell Config
$env.config = {
  show_banner: false
  edit_mode: emacs
  buffer_editor: "nvim"
  
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
}
