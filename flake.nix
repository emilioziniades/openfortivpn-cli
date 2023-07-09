{
  description = "A flake shell script to glue together `openfortivpn` and `openfortivpn-webview`";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;

  outputs = {
    self,
    nixpkgs,
  }: {
    defaultPackage.x86_64-linux = with import nixpkgs {system = "x86_64-linux";};
      stdenv.mkDerivation rec {
        name = "emilio-test";
        src = ./.;
        buildPhase = "";
        installPhase = ''
          mkdir -p $out/bin
          cp ${src}/test.sh $out/bin/emilio-test
          chmod +x $out/bin/emilio-test
        '';
      };
  };
}
