{ pkgs
, unstable
, lib
, osConfig ? { }
, llm-agents ? null
, openai-codex ? null
, ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  hostName = osConfig.networking.hostName or "";
  desktopPackages = (with unstable; [
    wget

    # Terminal
    eza
    fd
    git
    kitty
    starship

    # Audio
    pamixer
    playerctl

    # Files
    unzip
    unrar
    zip

    # Browser
    firefox
    chromium
    qutebrowser

    # Social
    discord
    telegram-desktop

    # Dev
    distrobox
    docker
    claude-code
    antigravity

    # TODO: DELETE AFTER INSTALL NEOVIM AS NIX PACKAGE
    cmake
    gnumake
    nodejs
    gcc

    rustup
    zellij
    nmap
    lazygit
    ripgrep
    nil
    lua-language-server
    broot
    sd
    zoxide
    fastfetch
    bat
  ])
  ++ lib.optional (llm-agents != null) llm-agents.packages.${system}.antigravity-cli
  ++ lib.optional (openai-codex != null) openai-codex
  ++ lib.optional (osConfig.gnome.enable or false) pkgs.gnomeExtensions.pop-shell;

  n100Packages = with unstable; [
    wget

    # Terminal
    eza
    fd
    git
    kitty
    starship

    # Audio
    pamixer
    playerctl

    # Files
    unzip
    unrar
    zip

    # Browser
    firefox
    chromium

    # Social
    discord
    telegram-desktop

    # Dev
    distrobox
    docker
    cmake
    gnumake
    nodejs
    gcc

    rustup
    zellij
    nmap
    lazygit
    ripgrep
    nil
    lua-language-server
    broot
    sd
    zoxide
    fastfetch
    bat
  ];
in
with lib;
{
  home.stateVersion = "23.11";
  programs.home-manager.enable = true;

  dconf.settings = mkIf (osConfig.gnome.enable or false) {
    "org/gnome/desktop/peripherals/keyboard" = {
      numlock-state = true;
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
      clock-show-weekday = true;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
      two-finger-scrolling-enable = true;
    };

    "org/gnome/desktop/wm/keybindings" = {
      switch-windows = [ "<Alt>Tab" ];
      switch-windows-backward = [ "<Shift><Alt>Tab" ];
    };

    "org/gnome/shell" = {
      favorite-apps = [
        "firefox.desktop"
        "kitty.desktop"
        "org.gnome.Nautilus.desktop"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Ctrl><Alt>T";
      command = "kitty";
      name = "open-terminal";
    };
  };

  programs = {
    fish.enable = true;
    git = {
      enable = true;
      userName = "lluz55";
      userEmail = "lucasluz55@gmail.com";
    };
    direnv = {
      enable = true;
      enableBashIntegration = true; # see note on other shells below
      nix-direnv.enable = true;
    };
    helix = {
      enable = true;
      extraPackages = with unstable; [
        nixd
        nixfmt-rfc-style
        rust-analyzer
        gopls
        typescript-language-server
        typescript
        pyright
        ruff
        dart
      ];
      settings = {
        theme = "catppuccin_mocha";
        editor = {
          line-number = "relative";
          cursorline = true;
          bufferline = "multiple";
          true-color = true;
          auto-save = true;
          soft-wrap.enable = true;
          cursor-shape = {
            normal = "block";
            insert = "bar";
            select = "underline";
          };
          indent-guides = {
            render = true;
            character = "│";
          };
          statusline = {
            left = [ "mode" "spinner" "version-control" "file-name" ];
            center = [ "file-encoding" "file-type" ];
            right = [ "diagnostics" "workspace-diagnostics" "position" "position-percentage" ];
          };
          lsp.display-messages = true;
          file-picker.hidden = false;
        };
        keys.normal.space.t = {
          w = ":set soft-wrap.enable true";
          W = ":set soft-wrap.enable false";
        };
      };
      languages = {
        language-server = {
          nixd.command = "nixd";
          pyright = {
            command = "pyright-langserver";
            args = [ "--stdio" ];
            config = { python.analysis.typeCheckingMode = "basic"; };
          };
          ruff = {
            command = "ruff";
            args = [ "server" ];
          };
        };
        language = [
          {
            name = "nix";
            language-servers = [ "nixd" ];
            auto-format = true;
            formatter = { command = "nixfmt"; };
          }
          {
            name = "python";
            language-servers = [
              { name = "pyright"; except-features = [ "diagnostics" ]; }
              "ruff"
            ];
            auto-format = true;
            formatter = { command = "ruff"; args = [ "format" "-" ]; };
          }
          {
            name = "rust";
            language-servers = [ "rust-analyzer" ];
            auto-format = true;
          }
          {
            name = "go";
            language-servers = [ "gopls" ];
            auto-format = true;
          }
          {
            name = "typescript";
            language-servers = [ "typescript-language-server" ];
            auto-format = true;
          }
          {
            name = "javascript";
            language-servers = [ "typescript-language-server" ];
            auto-format = true;
          }
          {
            name = "dart";
            language-servers = [ "dart" ];
            auto-format = true;
          }
        ];
      };
    };
  };

  xdg.configFile = {
    "qutebrowser/config.py" = {
      source = ./qutebrowser/config.py;
      force = true;
    };
    "qutebrowser/autoconfig.yml" = {
      source = ./qutebrowser/autoconfig.yml;
      force = true;
    };
    "qutebrowser/quickmarks" = {
      source = ./qutebrowser/quickmarks;
      force = true;
    };
    "qutebrowser/bookmarks/urls" = {
      text = "";
      force = true;
    };
  };

  home.packages = if hostName == "n100" then mkForce n100Packages else desktopPackages;
}
