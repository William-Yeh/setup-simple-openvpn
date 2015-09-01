#!/bin/bash
#
# add more client certificates for the same OpenVPN server configuration.
#


USER_NAME=$1
OPENVPN_CONF=/etc/openvpn


function do_error_exit {
    echo { \"status\": $RETVAL, \"error_line\": $BASH_LINENO }
    exit
}


function main() {
    if [ $# -lt 1 ]; then
        echo "Simple tool to add more client certificates for the same OpenVPN server configuration."
        echo "Usage: add-user.sh  username"
        exit 1
    fi


    find_server_name SERVER_NAME
    #echo $SERVER_NAME
    CLIENT_CN="$USER_NAME-$SERVER_NAME"

    find_default_client_dir DEFAULT_CLIENT_DIR
    #echo $DEFAULT_CLIENT_DIR

    generate_client_cert

    pack_client_conf
}


function find_server_name() {
    local __resultvar=$1

    local fullpath_server_name=`ls $OPENVPN_CONF/easy-rsa/keys/client1-*.key`
    if [ $? -ne 0 ]; then
        echo "[ERROR] Cannot find 'easy-rsa/keys/client1-*.key' ; aborting!"
        exit 1
    fi

    #echo $fullpath_server_name
    if [[ $fullpath_server_name =~ client1-(.+)\.key[[:space:]]*$ ]]; then
        local server_name=${BASH_REMATCH[1]}
    else
        echo "[ERROR] Cannot extract server name in 'easy-rsa/keys/client1-*.key' ; aborting!"
    fi


    if [[ "$__resultvar" ]]; then
        eval $__resultvar="'$server_name'"
    else
        echo "$server_name"
    fi
}


function find_default_client_dir() {
    local __resultvar=$1
    local default_client_dir=`cat .default-client-dir`
    if [ $? -ne 0 ]; then
        echo "[ERROR] Cannot find 'default-client-dir' file ; aborting!"
        exit 1
    fi


    if [[ "$__resultvar" ]]; then
        eval $__resultvar="'$default_client_dir'"
    else
        echo "$default_client_dir"
    fi
}


function generate_client_cert() {
    local keys_dir="$OPENVPN_CONF/easy-rsa/keys"
    local target_files=($keys_dir/$CLIENT_CN.*)
    if [ -e ${target_files[0]} ]; then
        echo "[ERROR] '$CLIENT_CN' already exists in '$keys_dir' dir, aborting!"
        exit 1
    fi


    local easyrsa_dir="$OPENVPN_CONF/easy-rsa"
    (cd $easyrsa_dir || { echo "[ERROR] Cannot cd into '$easyrsa_dir', aborting!"; exit 1; }
        source myvars
        ./pkitool  $CLIENT_CN
    )
}


function pack_client_conf() {
    local TMPDIR="openvpn.$USER_NAME"
    mkdir $TMPDIR || { echo "[ERROR] Cannot make temporary directory '$TMPDIR', aborting!"; exit 1; }


    trap 'RETVAL=$?; echo "ERROR"; do_error_exit '  ERR

    local keys_dir="$OPENVPN_CONF/easy-rsa/keys"
    cp $keys_dir/$CLIENT_CN.key  $keys_dir/$CLIENT_CN.crt  $TMPDIR
    cp $DEFAULT_CLIENT_DIR/ca-*.crt           $TMPDIR
    cp $DEFAULT_CLIENT_DIR/$SERVER_NAME.ovpn  $TMPDIR/$SERVER_NAME.ovpn
    sed -i -e "s/client1/$USER_NAME/"         $TMPDIR/$SERVER_NAME.ovpn

    (cd $TMPDIR || { echo "[ERROR] Cannot cd into a temporary directory, aborting!"; exit 1; }
        zip -j $CLIENT_CN.zip  *.ovpn *.crt *.key
        cp $SERVER_NAME.ovpn $SERVER_NAME.certs.embedded.ovpn
        echo "<ca>" >> $SERVER_NAME.certs.embedded.ovpn
	sed -i -e '/<ca>/r ca-'$SERVER_NAME'.crt' $SERVER_NAME.certs.embedded.ovpn
        echo "</ca>" >> $SERVER_NAME.certs.embedded.ovpn
        echo "<cert>" >> $SERVER_NAME.certs.embedded.ovpn
	sed -i -e '/<cert>/r '$CLIENT_CN'.crt' $SERVER_NAME.certs.embedded.ovpn
        echo "</cert>" >> $SERVER_NAME.certs.embedded.ovpn
        echo "<key>" >> $SERVER_NAME.certs.embedded.ovpn
	sed -i -e '/<key>/r '$CLIENT_CN'.key' $SERVER_NAME.certs.embedded.ovpn
        echo "</key>" >> $SERVER_NAME.certs.embedded.ovpn
        echo "<tls-auth>" >> $SERVER_NAME.certs.embedded.ovpn
	sed -i -e '/<tls-auth>/r '$keys_dir'/ta.key' $SERVER_NAME.certs.embedded.ovpn
        echo "</tls-auth>" >> $SERVER_NAME.certs.embedded.ovpn
        chmod -R a+rX .
    )
    
    
    echo "----"
    echo "Generated configuration files are in $TMPDIR/ !"
    echo "----"
}



main "$@"
