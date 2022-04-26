![Ansible Lint](https://github.com/johanneskastl/ansible-role-prepare_SUSE_HA_clusternode/workflows/Ansible%20Lint/badge.svg)

prepare_SUSE_HA_clusternode
=========

Prepare and configure a clusternode for SUSE HA (pacemaker, corosync, ...)

Currently only creates the file `/etc/modules-load.d/watchdog.conf` to use the `softdog` watchdog.

Requirements
------------

None.

Role Variables
--------------

None.

Dependencies
------------

None

Example Playbook
----------------

    - hosts: servers
      roles:
         - { role: 'johanneskastl.prepare_SUSE_HA_clusternode' }

License
-------

BSD-3-Clause

Author Information
------------------

I am Johannes Kastl, reachable via kastl@b1-systems.de.
