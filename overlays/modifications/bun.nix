final: prev:
prev.bun.overrideAttrs (oldAttrs: {
  nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ final.makeBinaryWrapper ];
  postFixup = (oldAttrs.postFixup or "") + ''
    wrapProgram $out/bin/bun \
      --prefix PATH : ${final.lib.makeBinPath [ final.nodejs ]}
  '';
})
