{
  lib,
  rustPlatform,
  pkg-config,
  cmake,
  python3,
  shaderc,
  vulkan-headers,
  vulkan-loader,
  spirv-headers,
  openblas,
  alsa-lib,
  alsa-plugins,
  pipewire,
  libva,
  ffmpeg-headless,
  openssl,
  libxkbcommon,
  wayland,
  fontconfig,
  freetype,
  curl,
  util-linux,
  wl-clipboard,
  wtype,
  makeWrapper,
  autoAddDriverRunpath,
  symlinkJoin,
  libx11,
  libxcb,
  libxcursor,
  libxrandr,
  libxi,
  fetchFromGitHub,
  pname,
  version,
  meta,
  updateScript,
}:

let
  runtimeEnv = {
    LD_LIBRARY_PATH = lib.makeLibraryPath [
      vulkan-loader
      openblas
      alsa-lib
      wayland
      libxkbcommon
      fontconfig
      # Linux Annotate dlopens libpipewire-0.3, libva and libva-drm. libva finds VA-API
      # drivers through its built-in /run/opengl-driver path or LIBVA_DRIVERS_PATH.
      pipewire
      libva
    ];
    ALSA_PLUGIN_DIR = symlinkJoin {
      name = "${pname}-alsa-plugins";
      paths = [
        "${pipewire}/lib/alsa-lib"
        "${alsa-plugins}/lib/alsa-lib"
      ];
    };
  };
  runtimePackages = [
    curl
    wl-clipboard
    wtype
    # Annotate runs ffmpeg and ffprobe; the headless build includes libx264.
    ffmpeg-headless
  ];
in
rustPlatform.buildRustPackage (finalAttrs: {
  inherit pname version;
  src = fetchFromGitHub {
    owner = "anomalyco";
    repo = "hex";
    # nix-update patches the hash; rev follows the version literal
    rev = "v${version}";
    hash = "sha256-CAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  cargoHash = "sha256-CAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  __structuredAttrs = true;

  nativeBuildInputs = [
    pkg-config
    cmake
    python3
    shaderc
    makeWrapper
    autoAddDriverRunpath
  ];
  buildInputs = [
    vulkan-headers
    vulkan-loader
    spirv-headers
    openblas
    alsa-lib
    openssl
    libxkbcommon
    wayland
    fontconfig
    freetype
    libx11
    libxcb
    libxcursor
    libxrandr
    libxi
  ];

  # OpenCode HTTP requests run through curl, including in the tests; the
  # 2.3.1 adoption test runs the Linux installer, which needs flock.
  nativeCheckInputs = [
    curl
    util-linux
  ];

  dontUseCmakeConfigure = true;
  buildEnv = {
    OPENSSL_NO_VENDOR = "1";
    BLA_VENDOR = "OpenBLAS";
  };
  # Desktop and installed-model tests are #[ignore]; run the remaining suite.
  doCheck = true;
  preCheck = ''
    export HOME="$TMPDIR/hex-test-home"
    mkdir -p "$HOME"
  '';

  postInstall = ''
    install -Dm644 packaging/anomaly.hex.desktop $out/share/applications/anomaly.hex.desktop
    mkdir -p $out/share/icons
    cp -R packaging/linux/icons/hicolor $out/share/icons/hicolor
    substituteInPlace $out/share/applications/anomaly.hex.desktop \
      --replace-fail '@HEX_BIN@' "$out/bin/hex"
  '';

  postFixup = ''
    wrapProgram $out/bin/hex \
      --prefix PATH : ${lib.makeBinPath runtimePackages} \
      --prefix LD_LIBRARY_PATH : ${runtimeEnv.LD_LIBRARY_PATH} \
      --set ALSA_PLUGIN_DIR ${runtimeEnv.ALSA_PLUGIN_DIR}
  '';

  passthru = {
    inherit updateScript;
  };

  meta = meta // {
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
})
