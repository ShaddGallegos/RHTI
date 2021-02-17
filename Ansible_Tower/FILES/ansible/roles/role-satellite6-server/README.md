Install and configure Satellite 6 on a RHEL 6 or 7 host. 

This is based on the process outlined here: 

https://access.redhat.com/documentation/en-US/Red_Hat_Satellite/6.0/html-single/Installation_Guide/index.html

=======
Invoke the role using only one of the below three include statements, in order to pass in the data required to register the system with RHN: 

```YAML
- hosts: satellite6
  roles:
    ## use rhn username + password
    - { role: role-satellite6-server rhn_user: my-rhn-username rhn_password: my-rhn-password }
    ## use rhn activation key
    - { role: role-satellite6-server rhn_activationkey: some-key }
    ## use specific pool ids, found via "subscription-manager list --avaialable"
    ##   This is needed when your version of Ansible uses buggy redhat_subscription module prior to PR 1204. Before that, redhat_subscription won't be able to find subs
    - { role: role-satellite6-server rhn_pool_ids: ["somelongpoolid", "someotherlongpoolid"] } 
```
