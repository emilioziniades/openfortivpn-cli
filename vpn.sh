#!/usr/bin/env bash
set -e

VPN_CFG_FILE=~/.vpn
VPN_NAME_FILE=~/.vpn.current
VPN_PID=$(pgrep openfortivpn || true)

main() {
    if [[ ! -e $VPN_CFG_FILE ]]
    then
        echo "please create a configuration file at ~/.vpn with at least one default"
        exit 1
    fi

    case $1 in
        up)
            up $2;;
        down)
            down;;
        status)
            status;;
        logs)
            logs;;
        *)
            echo "please specify a valid subcommand: up {vpn-name}, down, status"
    esac
}

up() {
    if [[ -z $VPN_PID ]]
    then
        if [[ -z $1 ]]
        then
            echo "connecting to default vpn"
            host=$(jq -e -c 'map(select(.default == true)) | "\(.[0].host):\(.[0].port)"' $VPN_CFG_FILE | tr -d '"')
            name=$(jq -e -c 'map(select(.default == true)) | .[0].name' $VPN_CFG_FILE | tr -d '"')
        else
            host=$(jq -e -c "map(select(.name == \"$1\")) | \"\(.[0].host):\(.[0].port)\"" $VPN_CFG_FILE | tr -d '"')
            name=$(jq -e -c "map(select(.name == \"$1\")) | .[0].name" $VPN_CFG_FILE | tr -d '"')
            if [[ $? == 1 ]]
            then
                echo "could not find host $1, check the ~/.vpn config file"
                exit 1
            fi
        fi
        echo "connecting to $name"
        echo $name > $VPN_NAME_FILE
        COOKIE=$(openfortivpn-webview $host)
        sudo -b openfortivpn --cookie=$COOKIE $host
    else
        echo "vpn already connected"
    fi
}

down() {
    if [[ -z $VPN_PID ]]
    then
        echo "vpn already down"
    else
        echo "stopping vpn"
        sudo kill $VPN_PID
        rm $VPN_NAME_FILE
    fi
}

status() {
    if [[ -z $VPN_PID ]]
    then
        echo "[DOWN]"
    else
        echo "[UP] [PID: $VPN_PID] [VPN: $(cat $VPN_NAME_FILE)]"
    fi
}

main $1 $2
