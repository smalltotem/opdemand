#!/bin/sh -e

# source opdemand common and env vars
. /var/cache/opdemand/inputs.sh

# check for debug flag
if [ $server_debug = "True" ] ; then
    set -x
else
    set +x
fi

# install fail2ban
sudo apt-get install fail2ban -yq --force-yes
