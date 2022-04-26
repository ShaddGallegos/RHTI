ansible-role-ansible-automation-platform
=========

A role for deploying Red Hat Ansible Automation Platform.

Requirements
------------

* python >= 2.7


Role Variables
--------------

    tower_password: redhat
    pg_password: redhat

Fill out optional vars to subscribe system.

    rhn_username: user
    rhn_password: redhat

Example Playbook
----------------

    - hosts: all
      roles:
        - ansible-role-ansible-automation-platform

License
-------

MIT/BSD

Author Information
------------------

This role was created by [Michael Tipton](https://ibeta.org).
