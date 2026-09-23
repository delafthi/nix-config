_final: _prev:
_prev.cursorPlugins.pstack.overrideAttrs (oldAttrs: {
  # Scope unslop to file content: keep it away from chat responses (caveman owns those).
  nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ _final.gnused ];
  postPatch = (oldAttrs.postPatch or "") + ''
    substituteInPlace skills/unslop/SKILL.md \
      --replace-fail \
        'description: Cut AI tells from any writing. Must always apply.' \
        'description: Cut AI tells from written artifacts. Use when writing or editing file content (docs, prose, comments, commit messages). Do not apply to chat responses.'
  '';
})
