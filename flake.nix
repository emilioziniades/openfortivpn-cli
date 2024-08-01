{
  description = "A flake shell script to glue together `openfortivpn` and `openfortivpn-webview`";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    openfortivpn-webview.url = "github:emilioziniades/openfortivpn-webview-flake";
    openfortivpn-webview.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    openfortivpn-webview,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        name = "vpn";
        buildInputs = with pkgs; [
          jq
          openfortivpn
          openfortivpn-webview.packages.${system}.openfortivpn-webview
        ];
        script = (pkgs.writeScriptBin name (builtins.readFile ./vpn.sh)).overrideAttrs (
          old: {
            buildCommand = "${old.buildCommand}\n patchShebangs $out";
          }
        );
      in rec {
        packages.default = packages.script;
        packages.script = pkgs.symlinkJoin {
          name = name;
          paths = [script] ++ buildInputs;
          buildInputs = [pkgs.makeWrapper];
          postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
        };
      }
    );
}
