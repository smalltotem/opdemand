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

# install buildbot prerequisites
sudo apt-get install python-setuptools -yq --force-yes
sudo apt-get install python-twisted python-twisted-bin python-twisted-conch python-twisted-core python-twisted-mail python-twisted-runner python-twisted-web python-twisted-words python-jinja2 python-markupsafe python-zope.interface python-tempita python-sqlalchemy python-sqlalchemy-ext python-decorator -yq --force-yes
# Install latest buildbot from the cheeseshop
sudo easy_install buildbot buildbot-slave

BUILDBOT_PASSWORD=`python -c "import random, string; print ''.join(random.choice(string.letters+string.digits) for _ in xrange(12))"`

# create buildmaster env
if [ ! -e /home/buildmaster/master ]; then
    useradd buildmaster -c "Build Master" -m -s /bin/bash
    sudo -u buildmaster mkdir /home/buildmaster/master
    sudo -u buildmaster buildbot create-master -f -r /home/buildmaster/master
    echo '@reboot /usr/local/bin/buildbot start /home/buildmaster/master' | crontab -u buildmaster -
fi

# create buildslave env
if [ ! -e /home/buildslave/slave ]; then
    useradd buildslave -c "Build Slave" -m -s /bin/bash
    sudo -u buildslave mkdir /home/buildslave/slave
    sudo -u buildslave buildslave create-slave -f -r /home/buildslave/slave localhost:9989 buildslave1 $BUILDBOT_PASSWORD
    sudo -u buildslave echo `uname -a` > /home/buildslave/slave/info/host
    echo '@reboot /usr/local/bin/buildslave start /home/buildslave/slave' | crontab -u buildslave -
fi

sudo -u buildmaster cat > /home/buildmaster/master/master.cfg <<EOF
# -*- python -*-
# ex: set syntax=python:

# This is a sample buildmaster config file. It must be installed as
# 'master.cfg' in your buildmaster's base directory.

# This is the dictionary that the buildmaster pays attention to. We also use
# a shorter alias to save typing.
c = BuildmasterConfig = {}

####### BUILDSLAVES

# The 'slaves' list defines the set of recognized buildslaves. Each element is
# a BuildSlave object, specifying a unique slave name and password.  The same
# slave name and password must be configured on the slave.
from buildbot.buildslave import BuildSlave
c['slaves'] = [BuildSlave("buildslave1", "$BUILDBOT_PASSWORD")]

# 'slavePortnum' defines the TCP port to listen on for connections from slaves.
# This must match the value configured into the buildslaves (with their
# --master option)
c['slavePortnum'] = 9989

####### CHANGESOURCES

# the 'change_source' setting tells the buildmaster how it should find out
# about source code changes.  Here we point to the buildbot clone of pyflakes.

from buildbot.changes.gitpoller import GitPoller
c['change_source'] = GitPoller(
        'git://github.com/buildbot/pyflakes.git',
        workdir='gitpoller-workdir', branch='master',
        pollinterval=300)

####### SCHEDULERS

# Configure the Schedulers, which decide how to react to incoming changes.  In this
# case, just kick off a 'runtests' build

from buildbot.schedulers.basic import SingleBranchScheduler
from buildbot.changes import filter
c['schedulers'] = []
c['schedulers'].append(SingleBranchScheduler(
                            name="all",
                            change_filter=filter.ChangeFilter(branch='master'),
                            treeStableTimer=None,
                            builderNames=["runtests"]))

####### BUILDERS

# The 'builders' list defines the Builders, which tell Buildbot how to perform a build:
# what steps, and which slaves can execute them.  Note that any particular build will
# only take place on one slave.

from buildbot.process.factory import BuildFactory
from buildbot.steps.source import Git
from buildbot.steps.shell import ShellCommand

factory = BuildFactory()
# check out the source
factory.addStep(Git(repourl='git://github.com/buildbot/pyflakes.git', mode='copy'))
# run the tests (note that this will require that 'trial' is installed)
factory.addStep(ShellCommand(command=["trial", "pyflakes"]))

from buildbot.config import BuilderConfig

c['builders'] = []
c['builders'].append(
    BuilderConfig(name="runtests",
      slavenames=["buildslave1"],
      factory=factory))

####### STATUS TARGETS

# 'status' is a list of Status Targets. The results of each build will be
# pushed to these targets. buildbot/status/*.py has a variety to choose from,
# including web pages, email senders, and IRC bots.

c['status'] = []

from buildbot.status import html
from buildbot.status.web import authz
authz_cfg=authz.Authz(
    # change any of these to True to enable; see the manual for more
    # options
    gracefulShutdown = False,
    forceBuild = True, # use this to test your slave once it is set up
    forceAllBuilds = False,
    pingBuilder = False,
    stopBuild = False,
    stopAllBuilds = False,
    cancelPendingBuild = False,
)
c['status'].append(html.WebStatus(http_port=8010, authz=authz_cfg))

####### PROJECT IDENTITY

# the 'title' string will appear at the top of this buildbot
# installation's html.WebStatus home page (linked to the
# 'titleURL') and is embedded in the title of the waterfall HTML page.

c['title'] = "My Buildbot"
c['titleURL'] = "http://www.opdemand.com/"

# the 'buildbotURL' string should point to the location where the buildbot's
# internal web server (usually the html.WebStatus page) is visible. This
# typically uses the port number set in the Waterfall 'status' entry, but
# with an externally-visible host name which the buildbot cannot figure out
# without some help.

c['buildbotURL'] = "http://localhost:8010/"

####### DB URL

# This specifies what database buildbot uses to store change and scheduler
# state.  You can leave this at its default for all but the largest
# installations.
c['db_url'] = "sqlite:///state.sqlite"

EOF

sudo -u buildmaster buildbot restart /home/buildmaster/master
sudo -u buildslave buildslave restart /home/buildslave/slave
