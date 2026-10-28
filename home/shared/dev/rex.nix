{
  home = {
  };
  programs.rex = {
    enable = true;
    shellSupport = true;
    initLua = ''
      rex.bind("ctrl+space>r", "client.config.reload")
      rex.bind("ctrl+space>c", "client.tab.new")
      rex.bind("ctrl+space>n", "client.tab.next")
      rex.bind("ctrl+space>p", "client.tab.previous")
      rex.bind("ctrl+space>l", "pane.focus_next")
      rex.bind("ctrl+space>h", "pane.focus_previous")
      rex.bind("ctrl+space>ctrl+space", "pane.send_key", { key = "ctrl+space" })
      rex.bind("ctrl+space>v", "pane.split", { direction = "right" })
      rex.bind("ctrl+space>s", "pane.split", { direction = "down" })
      rex.bind("ctrl+space>f", "pane.zoom")
      rex.bind("cmd+down", "session.next")
      rex.bind("cmd+up", "session.previous")

      -- Floating project picker (cdp / tv project). Selecting a project
      -- creates or switches to its session.
      rex.action{
        name = "project_switch",
        title = "Switch Project",
        description = "Open a floating tv project picker; selecting a project creates or switches to its session.",
        run = function(ctx, args)
          local layer, err = rex.session.new_layer{
            bounds = { x = 0.15, y = 0.1, w = 0.7, h = 0.8 },
            layout = rex.layout.block{
              flavor = "com.superlogical.terminal.shell",
              options = { command = { "tv", "project" } },
              label = "project",
            },
            focus = true,
          }
          if err ~= nil then error(err, 0) end
          return layer
        end,
      }
      rex.bind("cmd+k", "project_switch")
    '';
  };
}
