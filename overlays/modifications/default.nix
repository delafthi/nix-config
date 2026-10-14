final: prev:
let
  inherit (prev) lib;

  discover =
    dir:
    lib.mergeAttrsList (
      lib.mapAttrsToList (
        name: type:
        let
          path = dir + "/${name}";
        in
        if type == "directory" then
          {
            ${name} =
              if builtins.pathExists (path + "/default.nix") then
                import (path + "/default.nix") final prev
              else
                discover path;
          }
        else if lib.hasSuffix ".nix" name && name != "default.nix" then
          { ${lib.removeSuffix ".nix" name} = import path final prev; }
        else
          { }
      ) (builtins.readDir dir)
    );
in
discover ./.
