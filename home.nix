{
  config,
  pkgs,
  agenix,
  osUsername,
  ...
}:
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
    ai = "aichat";

    hms = "home-manager switch";
  };
  claude_alt =
    {
      name,
      url,
      token_path,
      reasoner,
      chat,
    }:
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

  fzf-tab-completion = pkgs.fetchFromGitHub {
    owner = "lincheney";
    repo = "fzf-tab-completion";
    rev = "4850357beac6f8e37b66bd78ccf90008ea3de40b";
    sha256 = "02kxsxkf7wk7s6q5faqli4546dwf73y3mpjkhl1bls6r2r2jn1x6";
  };

  localBinPath = "${config.home.homeDirectory}/.local/bin";
  cargoBinPath = "${config.home.homeDirectory}/.cargo/bin/";
in
{
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
    pkgs.ast-grep
    pkgs.cmake
    pkgs.cppman
    pkgs.dircolors-solarized
    pkgs.fd
    pkgs.gemini-cli
    pkgs.github-cli
    pkgs.jq
    pkgs.lazydocker
    pkgs.lazygit
    pkgs.nodejs
    pkgs.pnpm
    pkgs.podman
    pkgs.podman-compose
    pkgs.ripgrep
    pkgs.rustup
    pkgs.tree-sitter # for nvim
    pkgs.typst
    pkgs.uv
    pkgs.yazi
    pkgs.zellij
    pkgs.zig
    pkgs.zoxide

    agenix.packages.${pkgs.system}.default

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
      reasoner = "glm-4.6";
      chat = "glm-4.6-air";
      token_path = config.age.secrets.glm.path;
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
    DEEPSEEK_API_KEY = "$(cat ${config.age.secrets.deepseek.path})";
  };

  home.sessionPath = [
    localBinPath
    "$PNPM_HOME"
    cargoBinPath
  ];

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

      source ${fzf-tab-completion}/bash/fzf-bash-completion.sh
      bind -x '"\t": fzf_bash_completion'
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
          type = "openai-compatible";
          name = "deepseek";
          api_base = "https://api.deepseek.com/v1";
          api_key_env = "DEEPSEEK_API_KEY";
          models = [
            {
              name = "deepseek-chat";
              supports_function_calling = true;
              supports_vision = false;
            }
          ];
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
    env = {
      GOBIN = "${localBinPath}";
    };
  };

  programs.claude-code = {
    enable = true;
    settings = {
      memory.source = ./claude-memory/claude-memory.md;
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
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withNodeJs = true;
  };
  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
  };

  nixpkgs.config.allowUnfree = true;

  nixp.fzf-pushd.enable = true;
}
