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

# install pyramid prerequisites
sudo apt-get install python-setuptools python-virtualenv gcc python-dev -yq --force-yes

# create buildmaster env
if [ ! -e $HOME/pyramid_dev ]; then
    virtualenv --no-site-packages pyramid_dev
fi

cd pyramid_dev
. bin/activate
bin/easy_install pyramid

cat > helloworld.py <<EOF
from wsgiref.simple_server import make_server
from pyramid.config import Configurator
from pyramid.response import Response

def hello_world(request):
   return Response('Hello %(name)s!' % request.matchdict)

if __name__ == '__main__':
   config = Configurator()
   config.add_route('hello', '/hello/{name}')
   config.add_view(hello_world, route_name='hello')
   app = config.make_wsgi_app()
   server = make_server('0.0.0.0', 8080, app)
   server.serve_forever()

EOF

start pyramid_dev
