#!/bin/sh -e

# source opdemand common and env vars
. /var/cache/opdemand/inputs.sh

# check for debug flag
if [ $server_debug = "True" ] ; then
    debug_flag="-d"
else
    debug_flag="-v"
fi

# execute puppet apply
apt-get install postfix -yq --force-yes
