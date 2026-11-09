{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  shaderc,
  autoPatchelfHook,
  vulkan-headers,
  vulkan-loader,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qwentts-cpp";
  version = "0-unstable-2026-11-06";

  src = fetchFromGitHub {
    owner = "ServeurpersoCom";
    repo = "qwentts.cpp";
    rev = "de2ad833e9bd5c06082231d1da637789f7562816";
    fetchSubmodules = true;
    hash = "sha256-jjY2xR/fBaJZbVIAbYJUWCnjf5y9NSy0+sHg3TG3I+E=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    shaderc
    autoPatchelfHook
  ];

  buildInputs = [
    vulkan-headers
    vulkan-loader
    stdenv.cc.cc.lib
  ];

  # The CPU backend is built once per x86 ISA level and picked at startup, because -march=native is neither reproducible nor allowed in the Nix sandbox.
  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" true)
    (lib.cmakeBool "CMAKE_SKIP_BUILD_RPATH" true) # autoPatchelfHook sets the final RPATHs
    (lib.cmakeBool "GGML_VULKAN" true)
    (lib.cmakeBool "GGML_NATIVE" false)
    (lib.cmakeBool "GGML_BACKEND_DL" true)
    (lib.cmakeBool "GGML_CPU_ALL_VARIANTS" true)
    (lib.cmakeFeature "GGML_BACKEND_DIR" "${placeholder "out"}/lib")
  ];

  # The project defines no install rules.
  installPhase = ''
    runHook preInstall
    install -Dm755 -t $out/bin qwen-tts qwen-codec tts-server quantize
    mkdir -p $out/lib
    cp -P libggml*.so* $out/lib/
    runHook postInstall
  '';

  meta = {
    description = "Qwen3-TTS text-to-speech on GGML (qwentts.cpp), built with the Vulkan backend";
    homepage = "https://github.com/ServeurpersoCom/qwentts.cpp";
    license = lib.licenses.mit;
    mainProgram = "tts-server";
    platforms = [ "x86_64-linux" ];
  };
})
