# README.md
# Ansible Role: susefirewall

An Ansible role to install and configure SuSEfirewall2 on openSUSE.

It allows a complete SuSEfirewall2 configuration to be created from an Ansible 
variable.

## Role Variables

`susefirewall_config` is the only variable.  It is a dictionary where each 
item's key is the SuSEfirewall2 configuration parameter and it's value the 
parameter value. e.g.

```yaml
susefirewall_config:
  FW_DEV_EXT: eth0
  FW_DEV_INT: eth1 
  FW_SERVICES_EXT_TCP: ssh
  FW_PROTECT_FROM_INT: 'yes'
```

`susefirewall_config` defaults to an empty dictionary.

## Usage

Add the role to a playbook and set `susefirewall_config` with SuSEfirewall2 
parameters and values.  

All the configuration parameters and values are specified in 
`/usr/share/doc/packages/SuSEfirewall2/SuSEfirewall2.sysconfig` 

Example configurations can be found in `/usr/share/doc/packages/SuSEfirewall2/EXAMPLES`

`yes` or `no` values should be quoted so they are interpreted as strings and 
not booleans.

Because `susefirewall_config` defaults to an empty dictionary, if this role is 
used with no user defined `susefirewall_config` a valid but very limited 
firewall is still created by SuSEfirewall2. Make sure configuration is used that 
allows you to still access the host or ensure console access is available.

## Example Playbook

```yaml
---
- hosts: webserver
  roles:
    - role: susefirewall
      susefirewall_config:
        FW_DEV_EXT: eth0
        FW_DEV_INT: eth1
        FW_SERVICES_EXT_TCP: www
        FW_PROTECT_FROM_INT: 'yes'
```
## License

MIT
