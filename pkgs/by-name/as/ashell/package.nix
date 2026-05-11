{
  fetchFromGitHub,
  lib,
  rustPlatform,
  autoPatchelfHook,
  pkg-config,
  libxkbcommon,
  libGL,
  pipewire,
  libpulseaudio,
  wayland,
  udev,
  vulkan-loader,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ashell";
  version = "0.8.0-1";

  src = fetchFromGitHub {
    owner = "MalpenZibo";
    repo = "ashell";
    rev = "192ee10c1a3d2342af0bca30252138fd26a55621";
    hash = "sha256-wZMPbSi1doaQM/1hAcDKhPiBjMOvBf6FhzAnHPgBKtg=";
  };

  cargoHash = "sha256-rlgc4Kd4sZEy1UuhWXfxsmzD4EBvq7RniZt5ZXgrpEg=";

  nativeBuildInputs = [
    pkg-config
    autoPatchelfHook
    rustPlatform.bindgenHook
  ];

  runtimeDependencies = [
    wayland
    libGL
    vulkan-loader
  ];

  buildInputs = [
    libpulseaudio
    libxkbcommon
    pipewire
    udev
  ]
  ++ finalAttrs.runtimeDependencies;

  meta = {
    description = "Ready to go Wayland status bar for Hyprland";
    homepage = "https://github.com/MalpenZibo/ashell";
    license = lib.licenses.mit;
    mainProgram = "ashell";
    maintainers = with lib.maintainers; [ justdeeevin ];
    platforms = lib.platforms.linux;
  };
})
