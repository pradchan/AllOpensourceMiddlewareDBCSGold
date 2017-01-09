#!/bin/bash
config_file="Employee/scripts/config.properties"
while IFS='=' read -r key value
do
  key=$(echo $key | tr '.' '_')
  eval "${key}='${value}'"
done < "$config_file"

cd Employee
sed -i 's/IDENTITY_DOMAIN/'$cloud_domain'/' index.html
sed -i 's/DATACENTER/'$ACCS_DATACENTER'/' index.html
cd ..
