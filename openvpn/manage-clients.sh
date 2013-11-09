#!/bin/bash
# Helper for adding new openvpn client
# @version: 0.1
#
# Script should be copied to easy-rsa directory
# NOTE: openvpn configuration should contains ta.key configuration

# Paths to main files
TA_KEY=/etc/openvpn/ta.key
CLIENT_CONF=/etc/openvpn/client.conf
CA_CRT=/etc/openvpn/ca.crt
KEYS_DIR=/etc/openvpn/easy-rsa/keys


add_client(){
    NAME=$1
    [ -z "$NAME" ] && echo -n "Enter client name and press [ENTER]: "; read NAME || echo "Prepare settings for client $NAME"
    SETTINGS_PACK=${NAME}_openvpn

	 # Read easy-rsa vars
    . ./vars

    echo "Remove old client files"
    rm $KEYS_DIR/$NAME.*
    ./pkitool --interact $NAME &&\
    \
    echo -n "Generate client.conf..."
    sed -i "s/^cert\ .*\.crt$/cert $NAME.crt/" $CLIENT_CONF &&\
    sed -i "s/^key\ .*\.key$/key $NAME.key/" $CLIENT_CONF
    echo "OK"
    
    echo -n "Create archive..."
    mkdir $SETTINGS_PACK &&\
    cp $TA_KEY $CLIENT_CONF $KEYS_DIR/$NAME.key $KEYS_DIR/$NAME.crt $CA_CRT $SETTINGS_PACK/ &&\
    tar -czvf $SETTINGS_PACK.tar.gz $SETTINGS_PACK && rm -rf $SETTINGS_PACK &&\
    echo "OK" &&\
    echo "Settings for $NAME are prepared. Copy $SETTINGS_PACK.tar.gz to user and replace openvpn client configuration"
}

case "$1" in
    add)
    add_client $2
    ;;

    *)
    echo "Usage: $0 add <clientname or login>"
    ;;
esac

