ansible-role-vmware-vm
=========

A role for deploying Virtual Machines on VMWare.

Requirements
------------

* python >= 2.7
* PyVmomi


Role Variables
--------------

    datacenter: MyDC
    network_profile: DSwitch0-VM Network
    datastore: vsanDatastore

    vm_mem: 2048
    vm_cpus: 2
    vm_disk_size: 40
    vm_name: new-vm


Example Playbook
----------------

    - hosts: localhost
      roles:
        - ansible-role-vmware-vm

License
-------

MIT/BSD

Author Information
------------------

This role was created by [Michael Tipton](https://ibeta.org).
