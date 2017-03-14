#!/bin/bash
cloud_domain=$1;
ACCS_DATACENTER=$2;

ms_url="https://employeesservice-${cloud_domain}.apaas.${ACCS_DATACENTER}.oraclecloud.com/api.php/"
sed -i 's#MICROSERVICE_URL#'${ms_url}'#' Employee/index.html
