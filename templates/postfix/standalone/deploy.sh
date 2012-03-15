#!/bin/sh -e

# source opdemand common and env vars
. /var/cache/opdemand/inputs.sh

# check for debug flag
if [ $server_debug = "True" ] ; then
    debug_flag="-d"
else
    debug_flag="-v"
fi

# lookup hostnames
public_hostname=`curl http://169.254.169.254/latest/meta-data/public-hostname`
local_hostname=`curl http://169.254.169.254/latest/meta-data/local-hostname`

# install required packages
apt-get install -yq --force-yes debconf-utils

# preseed debconf for postfix
echo "postfix postfix/main_mailer_type select Internet Site
postfix postfix/mailname string $public_hostname
postfix postfix/destination string $public_hostname, $local_hostname, localhost.ec2.internal, localhost" | debconf-set-selections

# install postfix
apt-get install postfix -yq --force-yes
