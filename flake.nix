{
  description = "Nix package and NixOS module for qwentts.cpp, a local Qwen3-TTS speech server with Vulkan";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system} = rec {
        qwentts-cpp = pkgs.callPackage ./package.nix { };
        default = qwentts-cpp;
      };

      nixosModules.default = import ./module.nix self;
    };
}
