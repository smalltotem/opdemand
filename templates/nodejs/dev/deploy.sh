#!/bin/sh -ex

# source opdemand common and env vars
source /var/cache/opdemand/inputs.sh

# check for debug flag
if [ $server_debug ]; then
    puppet_cmd="puppet apply -d"
else
    puppet_cmd="puppet apply -v" 
fi

# execute puppet apply
$puppet_cmd -e 'opdemand::web::nodejs'
