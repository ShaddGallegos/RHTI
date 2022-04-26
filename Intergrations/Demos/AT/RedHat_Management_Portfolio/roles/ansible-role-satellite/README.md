ansible-role-satellite
=========

A role for deploying Red Hat Satellite 6.9.

Requirements
------------

* python >= 2.7


Role Variables
--------------

    rhn_username: user
    rhn_password: password

    sat_username: admin
    sat_password: redhat

Example Playbook
----------------

    - hosts: all
      roles:
        - ansible-role-satellite

License
-------

MIT/BSD

Author Information
------------------

This role was created by [Michael Tipton](https://ibeta.org).
