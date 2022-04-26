# Ansible role 'ansible-role-patching'

An Ansible role for patching systems (Arch Linux, Redhat family, Suse, Debian).

## Requirements

## Role Variables
| Variable		| Default		| Comments (type) |
| :---			| :---			| :---		  |
| `patch_env` | undefined | Set proxy (see example below |)
| `patch_reboot` | `no` | Set to `yes` to automatically reboot after patching. |

## Dependencies

## Example Playbook
```Yaml
- hosts: foo
  roles:
    - role: ansible-role-patching
  vars:
    patch_env:
      http_proxy: "http://foo:foohash@proxy1.example.com"
      https_proxy: "https://foo:foohash@proxy1.example.com"
```

## Testing


## License

MIT

## Contributors

Issues, feature requests, ideas, suggestions, etc. are appreciated and can be posted in the Issues section. Pull requests are also very welcome. Please create a topic branch for your proposed changes, it's the easiest way to merge back into the project.

- [Oscar Petersson](https://github.com/oscpe262/) (Maintainer)
