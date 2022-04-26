Satellite Installation Automation
==========================

This role will install satellite with basic configuration

Requirements
------------

Ansible 2.9 or higher

The following requirements apply to the networked base operating system:

[Connected Satellite Documentation](https://access.redhat.com/documentation/en-us/red_hat_satellite/6.10/html/installing_satellite_server_from_a_connected_network/index)

x86_64 architecture

The latest version of Red Hat Enterprise Linux 7 Server

4-core 2.0 GHz CPU at a minimum

A minimum of 20 GB RAM is required for Satellite Server to function. In addition, a minimum of 4 GB RAM of swap space is also recommended. Satellite running with less RAM than the minimum value might not operate correctly.

A unique host name, which can contain lower-case letters, numbers, dots (.) and hyphens (-)

A current Red Hat Satellite subscription

Administrative user (root) access

A system umask of 0022

Full forward and reverse DNS resolution using a fully-qualified domain name

Role Variables
--------------
# Satellite default vars
```
satellite_admin_username: "admin"
satellite_admin_password: "{{ lookup('file', 'SATELLITE_PASSWORD') }}"
satellite_organization: "example-org"
satellite_location: "example-location"
satellite_rhn_activation_key: "Satellite-AK"
satellite_server_url: "https://{{ ansible_fqdn }}"
satellite_data_disk: /dev/nvme2n1
satellite_vg_name: sat_vg01
satellite_rhn_org: "0101010"
satellite_rhn_username: "example-satellite"
satellite_rhn_password: "{{ lookup('file', 'RHN_PASSWORD') }}"
satellite_manifest_uuid: "{{ lookup('file', 'MANIFEST_UUID') }}"
satellite_deployment_version: "6.10"
satellite_server_basearch: "x86_64"
satellite_lifecycle: "Dev"
satellite_email: 'admin@example.com'
satellite_tuning: "medium"
satellite_keycloak-server-url: "sso.example.com"
satellite_keycloak-admin-username: "admin"
satellite_keycloak-realm: "EXAMPLE.COM"
satellite_keycloak-admin-realm: "master"
satellite_keycloak-auth-role: "root-admin"
satellite_auth: "sso"
satellite_CSR: "false"
## Only Change this if satellite csr is true
satellite_country: "US"
satellite_state: "CA"
satellite_city: "PARIS"
satellite_company: "Example LLC"
satellite_organizational_unit: "Example"
```
# satellite install role options:
```
satellite_options: >-
  --foreman-initial-admin-password "{{ satellite_admin_password }}"
  --foreman-initial-organization  "{{ satellite_organization }}"
  --foreman-initial-location  "{{ satellite_location }}"
  --foreman-proxy-dns-managed false
  --foreman-proxy-dns false
  --foreman-proxy-dhcp false
  --foreman-proxy-dhcp-managed false
  --foreman-proxy-tftp false
  --foreman-proxy-tftp-managed false #Basic Settings
```
```
satellite_settings:
  - name: "default_download_policy"
    value: "immediate"
```

##LVM Configuration
```
satellite_req_dirs:
  - mount_point: /var/lib/pulp
    lv_name: pulp
    lv_size: 1024g
  - mount_point: /var/opt/rh/rh-postgresql12
    lv_name: rh-postgresql1
    lv_size: 20g

```
```
satellite_rhel7_product:

  - name: "Red Hat Enterprise Linux 7 Server (RPMs)"
    label: rhel-7-server-rpms
    repos:
      - releasever: "7Server"
        basearch: "{{ satellite_server_basearch }}"

  - name: "Red Hat Satellite Tools 6.10 (for RHEL 7 Server) (RPMs)"
    label: rhel-7-server-satellite-tools-6.10-rpms
    all: "true"

  - name: "Red Hat Satellite Capsule 6.10 (for RHEL 7 Server) (RPMs)"
    label: rhel-7-server-satellite-capsule-6.10-rpms
    all: "true"

  - name: "Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server"
    label: rhel-server-rhscl-7-rpms
    repos:
      - releasever: "7Server"
        basearch: "{{ satellite_server_basearch }}"

  - name: "Red Hat Satellite Maintenance 6 (for RHEL 7 Server) (RPMs)"
    label: rhel-7-server-satellite-maintenance-6-rpms
    all: "true"

  - name: "Red Hat Ansible Engine 2.9 RPMs for Red Hat Enterprise Linux 7 Server"
    label: rhel-7-server-ansible-2.9-rpms
    all: "true"


satellite_content_views:
  - name: capsule-cv

satellite_host_collections:
  - name: capsule_hc
    description: "physical KVM servers"
satellite_activation_keys:
  - name: capsule-ak
    lifecycle_environment: "Library"
    content_view: capsule-cv
    host_collections:
      - capsule_hc
    subscriptions:
      - name: "Red Hat Satellite Infrastructure Subscription"
    content_overrides:
      - label: rhel-7-server-ansible-2.9-rpms
        override: enabled
      - label: rhel-7-server-satellite-maintenance-6-rpms
        override: enabled
      - label: rhel-server-rhscl-7-rpms
        override: enabled
      - label: rhel-7-server-satellite-tools-{{ satellite_deployment_version }}-rpms
        override: enabled
      - label: rhel-7-server-satellite-capsule-{{ satellite_deployment_version }}-rpms
        override: enabled
      - label: rhel-7-server-rpms
        override: enabled
    auto_attach: true
    release_version: 7Server
    service_level: "Premium"
```

Dependencies
------------
You must create a Red Hat Enterprise Linux 7 host before you can install and configure Satellite Server. Red Hat Enterprise Linux version 7.5 or later is supported. For more information about installing Red Hat Enterprise Linux 7

Ensure that your environment meets the requirements for installation, including meeting storage requirements, and ensuring that network ports and firewalls are open and configured. For more information

Example Playbooks
-----------------
```
---
- name: satellite
  hosts: satellite
  roles:
    - role:  satellite_installation
```
Example Inventory
-----------------
```
[satellite]
sataws01w-mom.agilesof.org

[satellite:vars]
satellite_manifest_uuid='example'
delegate_host='localhost'
```

License
-------

[GPLv3](LICENSE)

Author Information
------------------
Cory McKee <cmckee@redhat.com>
