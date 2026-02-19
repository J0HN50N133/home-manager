{ config, pkgs, agenix, bft, osUsername, ... }:
let
  aliases = {
    ls = "ls --color=auto";
    ll = "ls -alF";
    la = "ls -A";
    l = "ls -CF";
    ".." = "cd ..";

    grep = "grep --color=auto";
    fgrep = "fgrep --color=auto";
    egrep = "egrep --color=auto";

    lg = "lazygit";

    hms = "home-manager switch";
    neovide = "neovide.exe --wsl";
  };
  aichat_alt = { name, model, client_prefix, token_path, }:
    (pkgs.writeShellScriptBin name ''
      export ${client_prefix}_API_KEY=''${${client_prefix}_API_KEY-$(cat ${token_path})}
      exec aichat --model ${model} "$@"
    '');
  codex_alt = { name, token_path, }:
    (pkgs.writeShellScriptBin name ''
      export OPENAI_API_KEY=''${OPENAI_API_KEY-$(cat ${token_path})}
      exec codex "$@"
    '');
  claude_alt = { name, url, token_path, reasoner, chat, }:
    (pkgs.writeShellScriptBin name ''
      # Environment variables for the Anthropic CLI tool.
      # https://docs.anthropic.com/en/docs/claude-code/settings#environment-variables

      export ANTHROPIC_AUTH_TOKEN=''${ANTHROPIC_AUTH_TOKEN-$(cat ${token_path})}
      export ANTHROPIC_BASE_URL=${url}
      export ANTHROPIC_MODEL=''${ANTHROPIC_MODEL-"${reasoner}"}
      export API_TIMEOUT_MS=600000
      export ANTHROPIC_SMALL_FAST_MODEL=''${ANTHROPIC_SMALL_FAST_MODEL-"${chat}"}

      exec claude "$@"
    '');

  localBinPath = "${config.home.homeDirectory}/.local/bin";
  cargoBinPath = "${config.home.homeDirectory}/.cargo/bin/";
in {
  imports = [ ./fzf-pushd.nix ];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = osUsername;
  home.homeDirectory = "/home/${osUsername}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.amp-cli
    pkgs.ast-grep
    pkgs.bottom
    pkgs.cmake
    pkgs.cppman
    pkgs.carapace
    pkgs.dircolors-solarized
    pkgs.docker-compose # compatible with podman(ideally)
    pkgs.fd
    pkgs.jq
    pkgs.lazydocker
    pkgs.lazygit
    pkgs.nodejs
    pkgs.pnpm
    pkgs.podman
    pkgs.su # for podman rootless
    pkgs.ripgrep
    pkgs.rustup
    pkgs.tree-sitter # for nvim
    pkgs.typst
    pkgs.uv
    pkgs.witr
    pkgs.zellij
    pkgs.zig
    pkgs.zoxide

    agenix.packages.${pkgs.system}.default
    bft.packages.${pkgs.system}.default

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    (claude_alt {
      name = "glm";
      url = "https://open.bigmodel.cn/api/anthropic";
      reasoner = "glm-4.7";
      chat = "glm-4.7";
      token_path = config.age.secrets.glm.path;
    })

    (claude_alt {
      name = "minimaxi";
      url = "https://api.minimaxi.com/anthropic";
      reasoner = "MiniMax-M2.5";
      chat = "MiniMax-M2.5";
      token_path = config.age.secrets.minimaxi.path;
    })

    (claude_alt {
      name = "ds-cli";
      url = "https://api.deepseek.com/anthropic";
      reasoner = "deepseek-reasoner";
      chat = "deepseek-chat";
      token_path = config.age.secrets.deepseek.path;
    })

    (claude_alt {
      name = "kimi";
      url = "https://api.kimi.com/coding/";
      reasoner = "kimi-for-coding";
      chat = "kimi-for-coding";
      token_path = config.age.secrets.kimi.path;
    })

    (aichat_alt {
      name = "ai";
      model = "deepseek:deepseek-chat";
      client_prefix = "DEEPSEEK";
      token_path = config.age.secrets.deepseek.path;
    })

    (aichat_alt {
      name = "gmn";
      model = "gemini:gemini-3-flash-preview";
      client_prefix = "GEMINI";
      token_path = config.age.secrets.gemini.path;
    })

    (codex_alt {
      name = "aiberm";
      token_path = config.age.secrets.aiberm.path;
    })

  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/johnsonlee/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    #WINHOME = "/mnt/c/Users/JohnsonLee";
    PNPM_HOME = "${config.home.homeDirectory}/.local/share/pnpm";
    #DEEPSEEK_API_KEY = "$(cat ${config.age.secrets.deepseek.path})";
    #GEMINI_API_KEY = "$(cat ${config.age.secrets.deepseek.path})";

    # PODMAN related
    DOCKER_HOST = "unix:///run/user/$UID/podman/podman.sock";
    DOCKER_ROOTLESS = "1";
  };

  home.sessionPath = [ localBinPath "$PNPM_HOME" cargoBinPath ];

  systemd.user.sockets.podman = {
    Unit = {
      Description = "Podman API Socket";
      Documentation = "man:podman-system-service(1)";
    };
    Socket = {
      ListenStream = "%t/podman/podman.sock";
      SocketMode = "0660";
    };
    Install = { WantedBy = [ "sockets.target" ]; };
  };

  systemd.user.services.podman = {
    Unit = {
      Description = "Podman API Service";
      Requires = "podman.socket";
      After = "podman.socket";
      Documentation = "man:podman-system-service(1)";
      StartLimitIntervalSec = 0;
    };
    Service = {
      Type = "exec";
      KillMode = "process";
      Environment = ''LOGGING="--log-level=info"'';
      # 注意：这里直接引用 pkgs.podman，确保路径绝对正确
      ExecStart = "${pkgs.podman}/bin/podman $LOGGING system service";
    };
    Install = { WantedBy = [ "default.target" ]; };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = aliases;
    sessionVariables = { };
    initExtra = ''
      if [ -e ${config.home.profileDirectory}/etc/profile.d/nix.sh ]; then
        . ${config.home.profileDirectory}/etc/profile.d/nix.sh;
      fi # added by Nix installer
      [ ! -f "$HOME/.x-cmd.root/X" ] || . "$HOME/.x-cmd.root/X" # boot up x-cmd.
      source <(bft --init-script) 
      # nvm is not installed via nix
      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    '';
    profileExtra = ''
       if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then
        . $HOME/.nix-profile/etc/profile.d/nix.sh
      fi
    '';
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "JohnsonLee";
        email = "0xjohnsonlee@gmail.com";
      };
      init.defaultBranch = "main";
    };
  };

  programs.fzf.enable = true;
  programs.less.enable = true; # 启用 lesspipe
  programs.starship.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.direnv.enable = true;

  programs.aichat = {
    enable = true;

    settings = {
      clients = [
        {
          type = "gemini";
          name = "gemini";
          api_base = "https://generativelanguage.googleapis.com/v1beta";
        }
        {
          type = "openai-compatible";
          name = "deepseek";
          api_base = "https://api.deepseek.com/v1";
        }
      ];
    };

    agents = {
      deepseek = {
        model = "deepseek-chat";
        temperature = 0.7;
        top_p = 0.9;
        use_tools = "fs,web_search";
        agent_prelude = "default";
      };
    };
  };

  programs.go = {
    enable = true;
    env = { GOBIN = "${localBinPath}"; };
  };

  programs.claude-code = {
    enable = true;
    memory = { source = ./agent-memory/memory.md; };
    settings = {
      statusLine = {
        type = "command";
        command = ''
          input=$(cat)
          model_name=$(echo "$input" | jq -r '.model.display_name')
          dir_name=$(basename "$(echo "$input" | jq -r '.workspace.current_dir')")

          # Get git branch if in a git repository
          git_branch=""
          current_dir="$(echo "$input" | jq -r '.workspace.current_dir')"
          if cd "$current_dir" 2>/dev/null && git rev-parse --git-dir >/dev/null 2>&1; then
            git_branch=$(git branch --show-current 2>/dev/null || echo "detached")
            git_branch=":$git_branch"
          fi

          echo "[$model_name] 📁 $dir_name$git_branch"
        '';
        padding = 0;
      };
      hooks = {
        Stop = [{
          hooks = [{
            type = "command";
            command = "claude-bell -c 2";
          }];
        }];
        PermissionRequest = [{
          hooks = [{
            type = "command";
            command = "claude-bell -c 3 -i 100";
          }];
        }];
        Notification = [{
          matcher = "idle_prompt";
          hooks = [{
            type = "command";
            command = "claude-bell -c 2 -i 150";
          }];
        }];
      };
    };
  };

  programs.gemini-cli = {
    enable = true;
    package = pkgs.gemini-cli-bin;
    context.GEMINI = ./agent-memory/memory.md;
  };

  programs.opencode = { enable = true; };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withNodeJs = true;
  };

  #programs.codex = {
  #  enable = true;
  #  settings = {
  #    model = "openai/gpt-5.2-codex";
  #    model_provider = "aiberm";
  #    model_providers = {
  #      aiberm = {
  #        name = "Aiberm API";
  #        base_url = "https://aiberm.com/v1";
  #        env_key = "OPENAI_API_KEY";
  #        wire_api = "responses";
  #      };
  #    };
  #    notify = [ "claude-bell" "-c" "2" ];
  #  };
  #};

  programs.yazi = { enable = true; };

  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
  };

  nixpkgs.config.allowUnfree = true;

  nixp.fzf-pushd.enable = true;
}
