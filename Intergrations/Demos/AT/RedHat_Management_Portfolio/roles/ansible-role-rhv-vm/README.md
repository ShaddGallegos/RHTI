ansible-role-rhv-vm
=========

A role for deploying Virtual Machines on RHV/Ovirt.

Requirements
------------

* python >= 2.7
* ovirt-engine-sdk-python >= 4.3.0


Role Variables
--------------

    rhv_cluster: DEMO
    rhv_network_profile: DEMO
    rhv_storage_domain: DEMO-iSCSI

    vm_mem: 2GiB
    vm_cpus: 2
    vm_disk_size: 10GiB
    vm_name: new-vm


Example Playbook
----------------

    - hosts: localhost
      roles:
        - ansible-role-rhv-vm

License
-------

MIT/BSD

Author Information
------------------

This role was created by [Michael Tipton](https://ibeta.org).
