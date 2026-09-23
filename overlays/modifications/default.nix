_final: _prev: {
  bun = import ./bun.nix _final _prev;
  cursorPlugins = import ./cursorPlugins _final _prev;
  ice-bar = import ./ice-bar.nix _final _prev;
  lix = import ./lix.nix _final _prev;
}
