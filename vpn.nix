{
  makeWrapper,
  writeScriptBin,
  symlinkJoin,
  openfortivpn,
  jq,
  openfortivpn-webview,
  ...
}:
symlinkJoin rec {
  name = "vpn";
  paths = [script] ++ buildInputs;
  postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";

  script = writeScriptBin name (builtins.readFile ./vpn.sh);

  buildInputs = [
    jq
    openfortivpn
    openfortivpn-webview
  ];

  nativeBuildInputs = [
    makeWrapper
  ];
}
