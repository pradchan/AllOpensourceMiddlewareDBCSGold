#!/bin/bash
cloud_domain=$1;
ACCS_DATACENTER=$2;

if [ "${ACCS_DATACENTER}" == "em2" ]; then
  ACCS_DATACENTER='em2';
fi

sed -i 's/IDENTITY_DOMAIN/'$cloud_domain'/' Employee/index.html
sed -i 's/DATACENTER/'$ACCS_DATACENTER'/' Employee/index.html
