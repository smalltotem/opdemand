#!/usr/bin/env python
import json
import subprocess
import sys

# deserialize dynamic inputs
with open("/var/cache/opdemand/inputs.json") as f:
  data = f.read()
inputs = json.loads(data)

# read inputs
classes = inputs["deployment/classes"]
if len(classes) == 0:
  print 'no deployment/classes specified'
  sys.exit(0)
debug = inputs["deployment/debug"]

# construct `puppet apply` command
includes = [ 'include %s' % c for c in classes]
manifest = str("\n".join(includes))
cmd = []
cmd.extend(["puppet", "apply"])
if debug:
  cmd.extend(["-d"])
else:
  cmd.extend(["-v"])
cmd.extend(["-e", manifest])
print 'executing: ',cmd

# run the deploy
subprocess.check_call(cmd)