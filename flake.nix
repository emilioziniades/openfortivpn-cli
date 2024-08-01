{
  description = "A flake shell script to glue together `openfortivpn` and `openfortivpn-webview`";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        packages.script = pkgs.callPackage ./vpn.nix {openfortivpn-webview = packages.openfortivpn-webview;};
        packages.openfortivpn-webview = pkgs.callPackage ./openfortivpn-webview.nix {};
        packages.default = packages.script;
      }
    );
}
