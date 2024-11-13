### I used https://github.com/drupol/my-own-nixpkgs to create this monorepo

{
  description = "monorepo for testing things";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, systems, ... }:
    let
      allSystems = ["x86_64-linux" "aarch64-linux"];
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import systems;

      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
        inputs.pkgs-by-name-for-flake-parts.flakeModule
        ./imports/overlay.nix
        ./imports/formatter.nix
        ./imports/pkgs-all.nix
      ];

      packages = builtins.listToAttrs (map (system: {
        name = system;
        value = import ./imports/pkgs-all.nix { pkgs = import nixpkgs { inherit system; }; };
      }) allSystems);
    };
}
