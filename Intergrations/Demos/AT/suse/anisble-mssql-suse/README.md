# ansible-mssql-suse
Deploy MSSQL Server 2019 on Linux using Ansible 

### Usage
- Copy deploy.mssql to /root/.ansible/roles/ 
- Edit inventory with nodes or ansible clients 

ansible-playbook ./mssql_play.yml -i inventory 

### Description
This role deploy.mssql will perform the following:
 - Install and uninstall of the Microsoft SQL Server
 - Create, delete, or import (from .sql file) a database
 - Optional command line tools for SLES 12. 
 
The role uses MSSQL server and tool repos of SLES 12 only. You may need to change the repo for different distro. 
Also playbook currently stores the vars in itself, but I recommend to use secret vaults. I will update the playbook in my next commit with vaults and a password to access it. 

I have experimented this playbook on two VMware VMs running SLES 12 SP4. 
And finally credit to Ansible Galaxy, Ansible docs and kyleabenson's anisble-role-mssql github repository. 

--
Prabhanjan Gururaj 
ಪ್ರಭಂಜನ್ / प्रभंजन
