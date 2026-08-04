{ pkgs, ... }:
{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [
      awk-language-server
      bash-language-server
      fish-lsp
      jq-lsp
      just-lsp
      nixd
      nixfmt
      rumdl
      shfmt
      tombi
      typos-lsp
      vscode-extensions.llvm-org.lldb-vscode
      vscode-json-languageserver
      yaml-language-server
    ];
    ignores = [
      "!.helix"
    ];
    languages = {
      language = [
        {
          name = "markdown";
          language-servers = [
            "rumdl"
            "typos"
          ];
        }
        {
          name = "typst";
          language-servers = [
            "tinymist"
            "typos"
          ];
        }
        {
          name = "jjdescription";
          language-servers = [ "typos" ];
        }
      ];
      language-server = {
        clangd.args = [
          "--background-index"
        ];
        rumdl = {
          command = "rumdl";
          args = [ "server" ];
        };
        typos.command = "typos-lsp";
      };
    };
    settings = {
      editor = {
        bufferline = "multiple";
        color-modes = true;
        cursorline = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        end-of-line-diagnostics = "hint";
        file-picker.hidden = false;
        indent-guides.render = true;
        inline-diagnostics = {
          cursor-line = "hint";
          max-diagnostics = 3;
        };
        jump-label-alphabet = "uhetoaidnsypgcf,'.rlbmwvxqjkz;/-=";
        line-number = "relative";
        soft-wrap.enable = true;
        statusline = {
          left = [
            "mode"
            "spacer"
            "version-control"
          ];
          center = [
            "file-name"
            "file-modification-indicator"
          ];
          right = [
            "diagnostics"
            "spinner"
            "read-only-indicator"
            "file-type"
            "separator"
            "primary-selection-length"
            "position"
            "total-line-numbers"
          ];
          mode = {
            normal = "NORMAL";
            insert = "INSERT";
            select = "SELECT";
          };
        };
      };
      keys.normal = {
        "C-h" = "jump_view_left";
        "C-j" = "jump_view_down";
        "C-k" = "jump_view_up";
        "C-l" = "jump_view_right";
      };
    };
  };
}
