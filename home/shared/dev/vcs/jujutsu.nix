_: {
  programs.jujutsu = {
    enable = true;
    settings = {
      aliases = {
        a = [
          "new"
          "--insert-after"
        ];
        add = [
          "file"
          "track"
        ];
        b = [ "bookmark" ];
        c = [ "commit" ];
        clone = [
          "git"
          "clone"
          "--colocate"
        ];
        d = [ "describe" ];
        e = [ "edit" ];
        f = [
          "git"
          "fetch"
        ];
        files = [
          "util"
          "exec"
          "--"
          "tv"
          "jj-diff"
        ];
        F = [
          "git"
          "fetch"
          "--all-remotes"
        ];
        i = [
          "new"
          "--insert-before"
        ];
        ibookmark = [
          "util"
          "exec"
          "--"
          "tv"
          "jj-bookmark"
        ];
        idiff = [
          "util"
          "exec"
          "--"
          "tv"
          "jj-diff"
        ];
        ilog = [
          "util"
          "exec"
          "--"
          "tv"
          "jj-log"
        ];
        iop-log = [
          "util"
          "exec"
          "--"
          "tv"
          "jj-op-log"
        ];
        jj = [ ];
        l = [
          "log"
          "-r"
          "::"
        ];
        n = [ "new" ];
        nxt = [
          "next"
          "--edit"
        ];
        p = [
          "git"
          "push"
        ];
        pr = [
          "util"
          "exec"
          "--"
          "bash"
          "-c"
          ''
            set -euo pipefail

            head_rev="''${1:-@-}"
            head="$(jj log -r $head_rev --no-graph -T bookmarks)"
            if test "$head" = "" ; then
                jj git push --change $head_rev
                head="$(jj log -r $head_rev --no-graph -T bookmarks)"
            fi
            base="$(jj log -r "heads(::''${head_rev}- & bookmarks())" --no-graph -T bookmarks)"
            if test "$(echo $base | wc -w)" -gt 1 ; then
                # parent of $head_rev has multiple bookmarks, fall back to main
                base=main
            fi

            echo "gh pr create --base $base --head $head --fill --editor"
            gh pr create --base $base --head $head --fill --editor
          ''
        ];
        prv = [
          "prev"
          "--edit"
        ];
        P = [
          "git"
          "push"
          "--all"
        ];
        remotes = [
          "util"
          "exec"
          "--"
          "tv"
          "jj-remotes"
        ];
        track-all = [
          "bookmark"
          "track"
          "glob:*@*"
        ];
        t = [ "tug" ];
        tug = [
          "bookmark"
          "move"
          "--from"
          "heads(::@- & bookmarks())"
          "--to"
          "@-"
        ];
        workspaces = [
          "util"
          "exec"
          "--"
          "tv"
          "jj-workspaces"
        ];
      };
      colors."diff token".underline = false;
      git.sign-on-push = true;
      remotes = {
        origin.auto-track-bookmarks = "*";
        upstream.auto-track-bookmarks = "delafthi/* | main | master";
      };
      signing = {
        backend = "gpg";
        behavior = "drop";
        key = "00926686981863CB";
      };
      snapshot.autoupdate-stale = true;
      template-aliases."format_timestamp(timestamp)" = "timestamp.ago()";
      templates.git_push_bookmark = ''"delafthi/" ++ change_id.short()'';
      ui = {
        default-command = "log";
        diff-editor = ":builtin";
      };
      user = {
        email = "delafthi@pm.me";
        name = "Thierry Delafontaine";
      };
      "--scope" = [
        {
          "--when".commands = [ "status" ];
          ui.paginate = "never";
        }
      ];
    };
  };
}
