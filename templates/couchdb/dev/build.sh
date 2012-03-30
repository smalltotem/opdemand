#!/bin/sh

# OpDemand bootstrap script for Puppet-managed servers
# This script runs as "root" on first boot typically
# invoked by cloud-init's runcmd.

# source orchestration inputs as environment vars
. /var/cache/opdemand/inputs.sh

# set locale for calls that require encoding
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# prevent dpkg prompting
export DEBIAN_FRONTEND=noninteractive

# write out known hosts for github
cat > /home/ubuntu/.ssh/known_hosts <<EOF
|1|gWjGztJGJJqofFJr+IbLqRXQv2M=|NjW0/CNJgYo58K1JXBZl/md55FI= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
|1|c7geHuPbgSFjBFvrLiDzj1Vk+ck=|fCcYgpcB7KHCEEC1putjjpL+ktw= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
EOF
chown -R ubuntu.ubuntu /home/ubuntu/.ssh
chmod 600 /home/ubuntu/.ssh/known_hosts

#
# puppet-specific bootstrapping
#

# install puppet packages and gems
apt-get install puppet rubygems -yq
gem install puppet-module hiera hiera-json hiera-puppet

# install hiera config file
cat > /etc/puppet/hiera.yaml <<EOF
---
:backends: - json
           - puppet

:logger: console

:hierarchy: - inputs

:json:
   :datadir: /var/cache/opdemand

:puppet:
   :datasource: data
EOF

