{
  description = "Hugo blog";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      wp2md = import ./scripts/wp2md {
        inherit pkgs;
      };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          hugo
          git
          wp2md
          mdformat
        ];
      };
    };
}