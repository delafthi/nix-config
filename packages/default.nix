{
  lib,
  pkgs,
}:
let
  discoverPackages =
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
              if builtins.pathExists (path + "/package.nix") then
                pkgs.callPackage (path + "/package.nix") { }
              else
                discoverPackages path;
          }
        else if lib.hasSuffix ".nix" name && name != "default.nix" then
          { ${lib.removeSuffix ".nix" name} = pkgs.callPackage path { }; }
        else
          { }
      ) (builtins.readDir dir)
    );
in
discoverPackages ./.
