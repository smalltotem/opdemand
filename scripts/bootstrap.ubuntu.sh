
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
  f.write("#!/bin/sh\n")
  for k, v in iter(inputs.items()):
    key = k.replace("/", "_").lower()
    f.write("%s=\"%s\"\n" % (key, v))
'

# link all scripts to public path
for script in `ls /var/lib/opdemand/bin`; do
  ln -fs /var/lib/opdemand/bin/$script /usr/local/bin/$script
done

# /usr/local/bin/opdemand-build will be triggered