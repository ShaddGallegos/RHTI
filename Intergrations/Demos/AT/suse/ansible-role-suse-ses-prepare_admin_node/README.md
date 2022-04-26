![Ansible Lint](https://github.com/johanneskastl/ansible-role-suse-ses-prepare_admin_node/workflows/Ansible%20Lint/badge.svg)

suse-ses-prepare_admin_node
=========

Prepare the admin node for a SUSE Enterprise Storage Cluster

Requirements
------------

None.

Role Variables
--------------

- `admin_node_salt_packages`: Packages needed to run salt master and minion on the admin node.
- `admin_node_salt_services`: Name of the salt-master service, by default `salt-master`.
- `admin_node_deepsea_packages`: Packages needed for deepsea.
- `public_network`: Which network to use as the public network.
- `cluster_network`: Which network to use as the internal cluster network.

Dependencies
------------

None

Example Playbook
----------------

    - hosts: servers
      roles:
         - { role: 'johanneskastl.suse-ses-prepare_admin_node' }

License
-------

BSD-3-Clause

Author Information
------------------

I am Johannes Kastl, reachable via kastl@b1-systems.de.
