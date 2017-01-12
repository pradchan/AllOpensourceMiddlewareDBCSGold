#!/bin/bash
config_file="Operations/config.properties"
while IFS='=' read -r key value
do
  key=$(echo $key | tr '.' '_')
  eval "${key}='${value}'"
done < "$config_file"

if [ ${ACCS_DATACENTER} != "em2" ]; then
	sed -i 's/dbcs.emea.oraclecloud.com/dbaas.oraclecloud.com/g' Operations/src/opc-dbcs-ws.ref
fi

dbname="EmployeeDB"
dbviewoutput=`python Operations/src/opc-dbcs.py -i ${cloud_domain} -u ${cloud_username} -p ${cloud_password} -o VIEW -w Operations/src/opc-dbcs-ws.ref -c Operations/src/cacert.pem -n ${dbname}`

if test "${dbviewoutput#*$dbname}" != "$dbviewoutput"
    then
        # $dbname is in $dbviewoutput
		echo "Database ${dbname} already exists."
		echo "Schema would be refreshed.."
    else
        # $dbname is not in $dbviewoutput
		echo "Database ${dbname} does not exists. Creating new instance..."
		publickey=`cat Operations/cloudnative.pub`
		
		sed -i 's/IDENTITY_DOMAIN/'$cloud_domain'/' Operations/src/create-dbcs-img.json
		sed -i 's/CLOUD_USER/'$cloud_username'/' Operations/src/create-dbcs-img.json
		sed -i 's/CLOUD_PASSWORD/'$cloud_password'/' Operations/src/create-dbcs-img.json
		sed -i 's/DBAAS_ADMIN_PASSWORD/'$DBAAS_ADMIN_PASSWORD'/' Operations/src/create-dbcs-img.json
		#sed -i 's|PUBLIC_KEY|'$publickey'|' Operations/src/create-dbcs-img.json
		
		python Operations/src/opc-dbcs.py -i ${cloud_domain} -u ${cloud_username} -p ${cloud_password} -o BUILD -w Operations/src/opc-dbcs-ws.ref -l Operations/opc_dbcs.log -c Operations/src/cacert.pem -d Operations/src/create-dbcs-img.json
fi

python Operations/src/opc-dbcs.py -i ${cloud_domain} -u ${cloud_username} -p ${cloud_password} -o VIEW -w Operations/src/opc-dbcs-ws.ref -l Operations/opc_dbcs_view.log -c Operations/src/cacert.pem -n ${dbname}

dbcs_public_ip=`grep -m 1 'connect_descriptor_with_public_ip' Operations/opc_dbcs_view.log | cut -d: -f2 | awk '{print substr($1,2)}'`

if [ ${#dbcs_public_ip} -gt 0 ]; then
	echo "Have valid Public IP ${dbcs_public_ip}."
	
	#while (true); do exec 3>/dev/tcp/${dbcs_public_ip}/22; if [ $? -eq 0 ]; then echo "SSH up..." ; break ; else echo "SSH still down..." ; sleep 30 ; fi done

	#sed -i 's/DBAAS_ADMIN_PASSWORD/'$DBAAS_ADMIN_PASSWORD'/' Operations/src/dbcs-scripts/create-user-dbcs.sh
	#sed -i 's/DBAAS_USER_NAME/'$DBAAS_USER_NAME'/' Operations/src/dbcs-scripts/create-user-dbcs.sh
	#sed -i 's/DBAAS_USER_PASSWORD/'$DBAAS_USER_PASSWORD'/' Operations/src/dbcs-scripts/create-user-dbcs.sh
	
	#scp -i Operations/cloudnative -o StrictHostKeyChecking=no -r Operations/src/dbcs-scripts/  oracle@${dbcs_public_ip}:/tmp
	#ssh -i Operations/cloudnative -tt -o StrictHostKeyChecking=no oracle@${dbcs_public_ip} "cd /tmp/dbcs-scripts; chmod +x create-user-dbcs.sh; ./create-user-dbcs.sh; exit;"
else
	echo "Public IP is not valid."
fi
