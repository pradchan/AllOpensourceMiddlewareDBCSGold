#!/bin/bash
#config_file="Operations/config.properties"
#while IFS='=' read -r key value
#do
  #key=$(echo $key | tr '.' '_')
  #eval "${key}='${value}'"
#done < "$config_file"
cloud_domain=$1;
cloud_zone=$2;
cloud_username=$3;
cloud_password=$4;

if [ "${cloud_zone}" == "em2" ]; then
  cloud_zone='europe';
fi

cloud_paas_rest_url=https://apaas.${cloud_zone}.oraclecloud.com

cat <<EOF >Employee/deployment.json
{
    "memory": "2G",
    "instances": "1",
    "services": [{
        "identifier": "DBService",
        "type": "DBAAS",
        "name": "EmployeeDB",
        "username": "hr_user",
        "password": "welcome1"
    }]
}
EOF

echo "Starting the deployment process...."

echo "Creating a storage container..."
curl -i -X PUT \
  -u ${cloud_username}:${cloud_password} \
https://${cloud_domain}.storage.oraclecloud.com/v1/Storage-${cloud_domain}/employees-service
sleep 15

echo "Uploading the ZIP file in Storage Container..."
curl -i -X PUT \
    -u ${cloud_username}:${cloud_password} \
    https://${cloud_domain}.storage.oraclecloud.com/v1/Storage-${cloud_domain}/employees-service/EmployeesService.zip \
    -T Employee/Employees-dist.zip
sleep 15

# See if application already exists
let httpCode=`curl -i -X GET  \
  -u ${cloud_username}:${cloud_password} \
  -H "X-ID-TENANT-NAME:${cloud_domain}" \
  -H "Content-Type: multipart/form-data" \
  -sL -w "%{http_code}" \
  ${cloud_paas_rest_url}/paas/service/apaas/api/v1.1/apps/${cloud_domain}/EmployeesService \
  -o /dev/null`

# If application exists...
if [ ${httpCode} -eq 200 ]
then
  # Update application
    echo '\n[info] Updating application...\n'
    curl -i -X PUT  \
        -u ${cloud_username}:${cloud_password} \
        -H "X-ID-TENANT-NAME:${cloud_domain}" \
        -H "Content-Type: multipart/form-data" \
        -F archiveURL=employees-service/EmployeesService.zip \
        ${cloud_paas_rest_url}/paas/service/apaas/api/v1.1/apps/${cloud_domain}/EmployeesService
	sleep 60
else
    echo "Deploying the application to ACCS..."
    curl -X POST -u ${cloud_username}:${cloud_password} \
        -H "X-ID-TENANT-NAME:${cloud_domain}" \
        -H "Content-Type: multipart/form-data" \
        -F "name=EmployeesService" -F "runtime=php" -F "subscription=Monthly" \
        -F "deployment=@Employee/deployment.json" \
        -F "archiveURL=employees-service/EmployeesService.zip" -F "notes=Employees Service deploying..."  \
        ${cloud_paas_rest_url}/paas/service/apaas/api/v1.1/apps/${cloud_domain}
	sleep 60
fi

echo "Deployment successfully completed!"
