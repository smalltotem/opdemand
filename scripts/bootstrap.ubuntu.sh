#!/bin/sh

# write out inputs for shell sourcing
python -c '
#!/usr/bin/env python
import sys
import json
with open("/var/cache/opdemand/inputs.json") as f:
  data = f.read()
  inputs = json.loads(data)
# write out env vars
with open("/var/cache/opdemand/inputs.sh", "w") as f:
  f.write("/bin/sh\n")
  for k, v in iter(inputs.items()):
    key = k.replace("/", "_").lower()
    f.write("%%(key)s=%%(val)s\n")
'

# link all scripts to public path
for $script in `ls /var/lib/opdemand/bin`; do
  ln -s /var/cache/opdemand/$script /usr/local/bin/$script
done

# run the build
opdemand-build