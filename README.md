# qwentts-nix

Nix package and NixOS module for [qwentts.cpp](https://github.com/ServeurpersoCom/qwentts.cpp), a local [Qwen3-TTS](https://github.com/QwenLM/Qwen3-TTS) speech server with an OpenAI-compatible API. Built with the Vulkan backend for x86_64 Linux.

## Run

```bash
nix run github:Santuzius/qwentts-nix -- --model talker.gguf --codec codec.gguf --port 8080
```

The package also contains `qwen-tts`, `qwen-codec` and `quantize`. Model weights are not included; download them from [Serveurperso/Qwen3-TTS-GGUF](https://huggingface.co/Serveurperso/Qwen3-TTS-GGUF).

## NixOS module

```nix
{
  inputs.qwentts-nix.url = "github:Santuzius/qwentts-nix";

  # in the system's modules:
  #   qwentts-nix.nixosModules.default

  services.qwentts = {
    enable = true;
    port = 8080;
  };
}
```

The service is a systemd user service, so `systemctl --user start qwentts` and `stop` work without root. By default it loads the 0.6B CustomVoice talker and the 12 Hz tokenizer from `~/.local/share/qwentts/models/`; `model` and `codec` set other paths.

On a machine with several GPUs, restrict Vulkan to one of them:

```nix
services.qwentts.environment.VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json";
```
