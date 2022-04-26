# Ansible Playbooks/Roles/Collections
External connection required
Red Hat Network/Customer Portal credentials
Vars to be changed are located in the individual projects under default/main.yml 


AAP
--- 
- Requirements
  Red Hat Enterprise Linux 8.4 or later 64-bit (x86) installed for all nodes

  16 GB of RAM for controller nodes and execution nodes
  4 CPUs for controller nodes and execution nodes

  8 GB of RAM for private automation hub nodes
  2 CPUs for private automation hub nodes

  20 GB+ disk space for database node

  40 GB+ disk space for non database nodes

  DHCP reservations use infinite leases to deploy the cluster with static IP addresses.
  DNS records for all nodes

  Chrony configurationed for all nodes
  ansible-core version 2.11 or later installed for all nodes


/roles/ansible-role-ansible-automation-platform/defaults/main.yml

tower_password: redhat
pg_password: redhat

rhn_username: 
rhn_password: 


Satellte
---------
- Requirements

* The latest version of Red Hat Enterprise Linux 7 Server x86_64 architecture
* 4-core 2.0 GHz CPU at a minimum
* A minimum of 20 GB RAM is required for Satellite Server to function. In addition, a minimum of 4 GB RAM of swap space is also recommended. Satellite running with less RAM than the minimum value might not operate correctly.
* A unique host name, which can contain lower-case letters, numbers, dots (.) and hyphens (-)
* A current Red Hat Satellite subscription
* Administrative user (root) access
* A system umask of 0022
* Full forward and reverse DNS resolution using a fully-qualified domain name

  /var/log/                                     10 GB

  /var/opt/rh/rh-postgresql12/lib/pgsql         20 GB

  /usr                                           3 GB

  /opt                                           3 GB

  /opt/puppetlabs                              500 MB

  /var/lib/pulp/                               300 GB

  /var/lib/qpidd/                               25 MB


roles/ansible-role-satellite/defaults/main.yml 

sat_username: admin
sat_password: redhat
sat_org: REDHAT
sat_location: Denver
rhn_username:
rhn_password:
