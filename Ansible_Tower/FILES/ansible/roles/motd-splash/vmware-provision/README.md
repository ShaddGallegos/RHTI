[![GoKEV](http://GoKEV.com/GoKEV200.png)](http://GoKEV.com/)

<div style="position: absolute; top: 40px; left: 200px;">

# GoKEV-vmware-provision role

This project is an Ansible role to deploy to a local ESXi server or VCenter.
  - This role assumes you're feeding credentials through an Ansible Tower credential type
  - This role saves the newly provisioned VM to a temporary inventory name defined in the `defaults/main.yml`
  - localhost.target (inventory)


## Example Playbooks
Here's an example of how you could launch this role


<pre>---
- name: Build a VMware guest from template
  hosts: localhost
  gather_facts: no

  roles:
    - GoKEV.vmware-provision

- hosts: newlyprovisionedvm
  roles:
    - kev-role-post-build-one
    - kev-role-post-build-two
</pre>

## With a requirements.yml that looks as such:

<pre>
---
- name: GoKEV.vmware-provision
  version: latest
  src: https://github.com/GoKEV/GoKEV-vmware-provision.git
</pre>

## Troubleshooting & Improvements

- Not enough testing yet

## Notes

  - Not enough testing yet

## Author

This project was created in 2018 by [Kevin Holmes](http://GoKEV.com/).


