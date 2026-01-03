{
  config,
  pkgs,
  lib,
  ...
}:

with lib;
let
  # 模块的配置选项 (nixp.fzf-pushd.enable)
  cfg = config.nixp.fzf-pushd;

  # 获取 fzf 二进制文件的路径，确保它被正确引用
  fzf-package = config.programs.fzf.package or pkgs.fzf;
  fzfBin = "${fzf-package}/bin/fzf";

  # 目录搜索脚本的通用部分
  dir-search-command = ''
    (find -L . -mindepth 1 -type d -print 2>/dev/null || \
     find -L . -mindepth 1 -type d) | \
    "${fzfBin}" --no-sort --reverse --tac \
        --header="Select directory to PUSHD (Alt+Shift+C)"
  '';
in
{
  # 1. 定义模块的启用选项
  options.nixp.fzf-pushd = {
    enable = mkEnableOption "fzf pushd (Alt+Shift+C) functionality injected into enabled shell (Bash/Zsh).";
  };

  # 2. 配置逻辑：如果本模块启用，则执行以下条件判断
  config = mkIf cfg.enable {

    # --- Zsh 配置 (如果 Zsh 启用) ---
    programs.zsh = mkIf config.programs.zsh.enable {
      initExtra = ''
        # Zsh 函数/Widget 定义
          fzf-pushd-widget() {
            local selected_dir
            selected_dir=$(${dir-search-command})
            
            if [[ -n "$selected_dir" ]]; then
              pushd "$selected_dir" > /dev/null
            fi
            
            # 刷新 Zsh 命令行
            zle redisplay
          }

          # 注册 widget 并绑定按键
          zle -N fzf-pushd-widget
          # \eC 对应 Alt+Shift+C
          bindkey '\eC' fzf-pushd-widget
      '';
    };

    # --- Bash 配置 (如果 Bash 启用) ---
    programs.bash = mkIf config.programs.bash.enable {

      initExtra = ''
        # Bash 函数定义
        fzf_pushd_dir() {
          local selected_dir
          selected_dir=$(${dir-search-command})

          if [[ -n "$selected_dir" ]]; then
            pushd "$selected_dir" > /dev/null
            
            # 清除 Bash Readline 缓冲区，确保提示符正确刷新
            READLINE_LINE=""
            READLINE_POINT=0
          fi
        }

        # Bash 绑定 (使用 bind -x)
        # "\eC" 对应 Alt+Shift+C
        bind -x '"\eC": fzf_pushd_dir'
      '';
    };
  };
}
