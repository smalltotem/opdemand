#!/bin/sh -e
#
# sample build script
#

# turn on shell debugging
set -x

# source orchestration inputs as environment variables
source /var/cache/opdemand/inputs.sh

# call apt dist-upgrade
apt-get update && apt-get dist-upgrade -y --force-yes
