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
puppet apply $debug_flag -e 'include opdemand::database::postgresql'