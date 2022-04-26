ansible-role-kvm
=========

A role for deploying KVM on RHEL based hosts.

Requirements
------------

* python >= 2.7


Role Variables
--------------

Fill out optional var to deploy via bridged network.

    kvm_network: bridged

Example Playbook
----------------

    - hosts: kvm-host
      roles:
        - ansible-role-kvm

License
-------

MIT/BSD

Author Information
------------------

This role was created by [Michael Tipton](https://ibeta.org).
