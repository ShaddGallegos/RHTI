# README.md
# Ansible Role: suse_sysconfig_proxy

An Ansible role to configure /etc/sysconfig/proxy on openSUSE

It allows a complete configuration to be created from an Ansible 
variable.

## Role Variables

`suse_sysconfig_proxy` is the only variable.  It is a dictionary where each 
item's key is the /etc/sysconfig/proxy configuration parameter and it's value the 
parameter value. e.g.

```yaml
suse_sysconfig_proxy:
  proxy_enabled: "yes"
  http_proxy: "http://10.7.7.1:3128"
  https_proxy: "http://10.7.7.1:3128"
  ftp_proxy: "http://10.7.7.1:3128"
  gopher_proxy: "http://10.7.7.1:3128"
  no_proxy: localhost, 127.0.0.1
```

`suse_sysconfig_proxy` defaults to the default /etc/sysconfig/proxy settings
which are:
```yaml
suse_sysconfig_proxy:
  proxy_enabled: "no"
  http_proxy: ""
  https_proxy: ""
  ftp_proxy: ""
  gopher_proxy: ""
  no_proxy: localhost, 127.0.0.1
```

## Usage

Add the role to a playbook and set `suse_sysconfig_proxy` with /etc/sysconfig/proxy 
parameters and values.  

`yes` or `no` values should be quoted so they are interpreted as strings and 
not booleans.

## Example Playbook

```yaml
---
- hosts: webserver
  roles:
    - role: suse_sysconfig_proxy
      suse_sysconfig_proxy_config:
        proxy_enabled: "yes"
        http_proxy: "http://10.7.7.1:3128"
        https_proxy: "http://10.7.7.1:3128"
        ftp_proxy: "http://10.7.7.1:3128"
        gopher_proxy: ""
        no_proxy: localhost, 127.0.0.1
```
## License

MIT
