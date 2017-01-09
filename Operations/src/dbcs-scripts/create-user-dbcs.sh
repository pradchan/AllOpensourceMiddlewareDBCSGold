sqlplus sys/DBAAS_ADMIN_PASSWORD@PDB1 as sysdba @sys_commands.sql
sqlplus DBAAS_USER_NAME/DBAAS_USER_PASSWORD@PDB1 @employees.sql