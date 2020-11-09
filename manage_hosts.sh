#!/bin/sh

# PATH TO YOUR HOSTS FILE
ETC_HOSTS=/etc/hosts

# DEFAULT IP FOR HOSTNAME
IP="127.0.0.1"

# Hostname to add/remove.
HOSTNAME=$2

green='\033[0;32m'
green_bg='\033[42m'
red='\033[0;31m'
red_bg='\033[0;31m'
yellow='\033[1;33m'
NC='\033[0m'


function removehost() {
    if [ -n "$(grep $HOSTNAME /etc/hosts)" ]
    then
        echo "$HOSTNAME Found in your $ETC_HOSTS, Removing now...";
        sudo sed -i".bak" "/$HOSTNAME/d" $ETC_HOSTS
    else
        echo "$HOSTNAME was not found in your $ETC_HOSTS";
    fi
}

function addhost() {
    HOSTS_LINE="$IP\t$HOSTNAME"
    COMMENT_LINE="## Added by Sasanka - for RC9"
    if [ -n "$(grep $HOSTNAME /etc/hosts)" ]
        then
          	echo ""
            echo "$HOSTNAME already exists : $(grep $HOSTNAME $ETC_HOSTS)"
            echo ""
        else
            echo ""
            echo "-> Adding $HOSTNAME to your $ETC_HOSTS";
            echo ""
            sudo -- sh -c -e "echo 'COMMENT_LINE' >> /etc/hosts";
            sudo -- sh -c -e "echo '$HOSTS_LINE' >> /etc/hosts";

            if [ -n "$(grep $HOSTNAME /etc/hosts)" ]
                then
                  	echo ""
                    echo "{green}$HOSTNAME was added succesfully \n $(grep $HOSTNAME /etc/hosts){NC}";
                    echo ""
                else
                  	echo ""
                    echo "${red}Failed to Add $HOSTNAME, Try again!{NC}";
                    echo ""
            fi
    fi
}

$@
