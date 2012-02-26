# link all scripts to public path
for script in `ls /var/lib/opdemand/bin`; do
  ln -fs /var/lib/opdemand/bin/$script /usr/local/bin/$script
done

# /usr/local/bin/opdemand-build will be triggered