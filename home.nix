{ config, pkgs, ... }:
let
  aliases = {
    ls = "ls --color=auto";
    ll = "ls -alF";
    la = "ls -A";
    l = "ls -CF";

    grep = "grep --color=auto";
    fgrep = "fgrep --color=auto";
    egrep = "egrep --color=auto";

    lg = "lazygit";

    hms = "home-manager switch";
  };
in {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "johnsonlee";
  home.homeDirectory = "/home/johnsonlee";

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
    pkgs.claude-code
    pkgs.cmake
    pkgs.cppman
    pkgs.dircolors-solarized
    pkgs.fd
    pkgs.gemini-cli
    pkgs.go
    pkgs.jq
    pkgs.lazydocker
    pkgs.lazygit
    pkgs.neovim
    pkgs.nodejs
    pkgs.pnpm
    pkgs.ripgrep
    pkgs.rustup
    pkgs.typst
    pkgs.uv
    pkgs.yazi
    pkgs.zellij
    pkgs.zig
    pkgs.zoxide

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
    EDITOR = "nvim";
    #WINHOME = "/mnt/c/Users/JohnsonLee";
    PNPM_HOME = "${config.home.homeDirectory}/.local/share/pnpm";
  };

  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" "$PNPM_HOME" ];

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
    '';
  };

  programs.fzf.enable = true;
  programs.less.enable = true; # 启用 lesspipe
  programs.starship.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.direnv.enable = true;

  nixpkgs.config.allowUnfree = true;
}
