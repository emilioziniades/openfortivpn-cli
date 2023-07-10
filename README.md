# openfortivpn-cli

_CLI tool for connecting to Fortinet VPN via SAML login_

## Description

This is a simple command line tool (read: bash script), which is a wrapper around [`openfortivpn`](https://github.com/adrienverge/openfortivpn) and [`openfortivpn-webview`](https://github.com/gm-vm/openfortivpn-webview).

I made it because I had to - it is used at $WORK.

`openfortivpn` alone doesn't handle SAML login. So it is necessary to use `openfortivpn-webview` to get the cookie from the SAML login, and use that cookie when calling `openfortivpn`.

## Install

This can be installed using `nix`, so make sure you have [nix installed](https://nixos.org/download.html).

To test it out, you can run the following

```
nix run github:emilioziniades/openfortivpn-cli
```

To install with home-manager + nix flake, add the following to your flake inputs.

```
inputs.openfortivpn-cli.url = github:emilioziniades/openfortivpn-cli;
inputs.openfortivpn-cli.inputs.nixpkgs.follows = "nixpkgs";
```

Then, update the call to the home-manager configuration in the flake outputs in order to pass the script into the home-manager configuration using extraSpecialArgs. The below example is on NixOS but it should be similar on other platforms.

```
...
home-manager.nixosModules.home-manager
{
  ...
  home-manager.extraSpecialArgs = {
    ...
    openfortivpn-cli = openfortivpn-cli.defaultPackage.x86_64-linux;
  };
}
```

Finally, add the script to the list of packages in your home-manager configuration.

```
home.packages = [
    ...
    openfortivpn-cli
    ...
];
```

Then rebuild your configuration, with e.g. `nixos-rebuild switch`, and confirm that the script is in your path by typing `vpn`.

## Configuration

You will need to create a configuration file at ~/.vpn. This is a JSON
array with "name", "host", "port" and "default" fields. An example
configuration file looks like this:

```
[
    {
        "name": "favourite-vpn",
        "host": "one.vpn.com",
        "port": 10443,
        "default": true
    },
    {
        "name": "less-favourite-vpn",
        "host": "two.vpn.com",
        "port": 10443,
        "default": false
    }
]
```

## Usage

You can run `vpn up less-favourite-vpn` or `vpn up` to use the
default. To check the vpn status you can run `vpn status`, and to
disconnect from the vpn you can run `vpn down`. It's a little janky
and you may need to press enter after running `vpn up` or `vpn down`.
