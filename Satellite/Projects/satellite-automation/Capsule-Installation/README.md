capsule_installation
===========

This role will install Red Hat capsule server

[Red Hat Satellite Capsules Documentation](https://access.redhat.com/documentation/en-us/red_hat_satellite/6.7/html/installing_capsule_server/preparing-environment-for-capsule-installation#system-requirements_capsule)

Requirements
------------

The following requirements apply to the networked base operating system:

x86_64 architecture

The latest version of Red Hat Enterprise Linux 7 Server

4-core 2.0 GHz CPU at a minimum

A minimum of 12 GB RAM is required for Capsule Server to function. In addition, a minimum of 4 GB RAM of swap space is also recommended. Capsule running with less RAM than the minimum value might not operate correctly.
A unique host name, which can contain lower-case letters, numbers, dots (.) and hyphens (-)

A current Red Hat Satellite subscription

Administrative user (root) access

A system umask of 0022

Full forward and reverse DNS resolution using a fully-qualified domain name

```
Storage:
OS Drive = 35 Gib
Data Drive = 500 Gib
```

Role Variables
--------------
# capsule default vars
```
satellite_fqdn: "test.example.com"       # Satellite fully qualified domain name
satellite_org: "example"                 # Satellite initial Organization
capsule_ak: "example-ak"                 # Activation key created with the correct entitlements
capsule_data_disk: /dev/vdb              # Capsule servers not partitioned drive
capsule_vg_name: cap_vg01                # Default Volume group on the capsule
capsule_vip: "capsule.example.com"       # Only needed if using load balancers
satellite_CSR: "false"                   # Only needed if using CA signed certs
satellite_country: "US"                  # Only needed if using CA signed certs      
satellite_state: "FL"                    # Only needed if using CA signed certs
satellite_city: "Tampa"                  # Only needed if using CA signed certs
satellite_company: "Example LLC"         # Only needed if using CA signed certs
satellite_organizational_unit: "Cyber Sercurity"     # Only needed if using CA signed certs
satellite_admin_username: "admin"                  # Admin user on satellite
satellite_admin_password: "{{ lookup('env', 'SATELLITE_PASSWORD') }}" # Admin users's password
satellite_ip: "192.168.2.34"             # Satellite's public ip address
satellite_short: "satellite"             # satellite's short name
capsule_fqdn: "{{ ansible_fqdn }}"
capsule_short: "{{ ansible_hostname }}"
capsule_public_ip: "192.168.2.4"         # Capsule server's public ip address
```

capsule_req_dirs:
  - mount_point: /var/lib/pulp
    lv_name: pulp
    lv_size: 320g
  - mount_point: /var/opt/rh/rh-postgresql12/lib/pgsql
    lv_name: pgsql
    lv_size: 20g
```

Dependencies
------------
You must create a Red Hat Enterprise Linux 7 host before you can install capsule server you must have a satellite server up and running. Red Hat Enterprise Linux version 7.5 or later is supported. For more information about installing Red Hat Enterprise Linux 7

Ensure that your environment meets the requirements for installation, including meeting storage requirements, and ensuring that network ports and firewalls are open and configured. For more information

Example Playbooks
-----------------
```
---
- name: capsule
  hosts: blue
  roles:
    - role: Capsule-Installation
```
Example inventory
-----------------
```
[capsule]
capsule.example.com

[capsule-us-east-1:vars]
satellite_fqdn="satellite.example.com"
satellite_org="Example"
capsule_ak="AK_CAPSULE"                 
capsule_data_disk="/dev/vdb"          
satellite_ip: "192.168.1.30"             
satellite_short: "satellite"
capsule_fqdn: "{{ ansible_fqdn }}"
capsule_short: "{{ ansible_hostname }}"
capsule_public_ip: "182.168.1.35"

```



License
-------

[GPLv3](LICENSE)

Author Information
------------------
Cory McKee <cmckee@redhat.com>
