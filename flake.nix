{
  description = "A flake shell script to glue together `openfortivpn` and `openfortivpn-webview`";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
  inputs.flake-utils.url = github:numtide/flake-utils;

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
        name = "vpn";
        buildInputs = with pkgs; [
          openfortivpn
        ];
        script = (pkgs.writeScriptBin name (builtins.readFile ./vpn.sh)).overrideAttrs (
          old: {
            buildCommand = "${old.buildCommand}\n patchShebangs $out";
          }
        );
      in rec {
        defaultPackage = packages.script;
        packages.script = pkgs.symlinkJoin {
          name = name;
          paths = [script] ++ buildInputs;
          buildInputs = [pkgs.makeWrapper];
          postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
        };
      }
    );
}
