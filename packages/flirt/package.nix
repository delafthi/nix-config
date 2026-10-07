{
  lib,
  stdenv,
  rustPlatform,
  fetchFromCodeberg,
  nix-update-script,
  installShellFiles,
}:
rustPlatform.buildRustPackage (_finalAttrs: {
  pname = "flirt";
  version = "0-unstable-2026-10-07";

  src = fetchFromCodeberg {
    owner = "flirt";
    repo = "flirt";
    rev = "3f48ae5227ff0b3993fc0446caacc195eb30444d";
    hash = "sha256-OG4Uv23HVAQC68QpqluWrVlegqqqzWogHGu7J9hy8ug=";
    # `.git/HEAD` is required during build to get the commit id of HEAD
    leaveDotGit = true;
  };

  cargoHash = "sha256-gK6bfjHqlvLfNS3k3u2gKAg9KV61zL6O4FeNaamYVO8=";

  __structuredAttrs = true;

  nativeBuildInputs = [ installShellFiles ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd flirt \
      --bash <($out/bin/flirt util completion bash) \
      --fish <($out/bin/flirt util completion fish) \
      --zsh <($out/bin/flirt util completion zsh)
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version=branch"
    ];
  };

  meta = {
    description = "Fabulous Legendary Incremental Review Tool";
    homepage = "https://codeberg.org/delafthi/flirt";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.delafthi ];
    mainProgram = "flirt";
    platforms = lib.platforms.unix;
  };
})
