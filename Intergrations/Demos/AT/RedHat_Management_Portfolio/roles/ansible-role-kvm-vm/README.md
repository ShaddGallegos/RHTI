ansible-role-kvm-vm
=========

A role for deploying Virtual Machines on KVM.

Requirements
------------

* python >= 2.7


Role Variables
--------------

   | Variable Name | Default Variable | Description |
   |---------------|------------------|-------------|
   | base_img: | rhel7.9.qcow2 | Base image to use for VMs to deploy |    
   | vm_mem: | 2 | Memory to allocate VM in GBs |
   | vm_cpus:| 2 | Number of CPUs to allocate to VM |
   | virtual_machines: | blank | Name or List of VMs to deploy |
   | wait_time: | 60 | Time to wait for VMs to start |
   | bridge_network: | 192.168.1.* | Subnet of VMs |
   | kvm_network: | blank | Set to bridge if KVM is bridged on br0 with network name bridged-network |

Example Playbook
----------------

    - hosts: kvm-host
      tags: deploy
      roles:
        - ansible-role-kvm-vm

    - hosts: kvm-host
      tags: destroy
      roles:
        - ansible-role-kvm-vm

License
-------

MIT/BSD

Author Information
------------------

This role was created by [Michael Tipton](https://ibeta.org).
