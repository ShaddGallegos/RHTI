SUSEConnect
===========

Use this role to connect a SUSE Linux system to the SUSE Customer Center or a local SMT server. You can also specify which add-on products are to be registered.

Requirements
------------

You'll need the registration key that came with your SUSE subscription. For some products you'll need extra registration keys. You'll also need to know the internal product name of the product you're trying to register. I'll try to provide a full list in [PRODUCTS.md](PRODUCTS.md).

Role Variables
--------------

You can set the following variables:

| Variable                            | Type   | Description                                                                                 |
|-------------------------------------|--------|---------------------------------------------------------------------------------------------|
| `suseconnect_products:`             | list   | products that should be activated on the target system                                      |
| `  - product:`                      | string | internal product name, see [PRODUCTS.md](PRODUCTS.md) for a list                            |
| `    version:`                      | string | product version that should be activated, defaults to the major version of the base os      |
| `    arch:`                         | string | architecture of the product to be actived, defaults to the arch of the OS (ansible_machine) |
| `    key:`                          | string | if the product needs an additional registration key                                         |
| `suseconnect_reregister:`           | bool   | register all products regardless of current status                                          |
| `suseconnect_remove_subscriptions:` | bool   | remove currently registered products, absent in `suseconnect_products`                      |

This variable is used, but should not be set by the user:

| Variable                            | Type   | Description                                                                                 |
|-------------------------------------|--------|---------------------------------------------------------------------------------------------|
| `suseconnect_binary:`               | string | path of the SUSEConnect binary                                                              |

Dependencies
------------

None.

Example Task
------------

Register a SLES system and activate a bunch of extensions:

```yaml
- name: Register with SCC
  include_role:
    name: b1-systems.suseconnect
  vars:
    suseconnect_products:
      - product: 'SLES'
        version: '{{ ansible_distribution_version }}'
        key: '{{ sles_registration_key }}'
      - product: 'sle-module-basesystem'
        version: '{{ ansible_distribution_version }}'
      - product: 'sle-module-server-applications'
        version: '{{ ansible_distribution_version }}'
      - product: 'sle-module-desktop-applications'
        version: '{{ ansible_distribution_version }}'
      - product: 'sle-module-development-tools'
        version: '{{ ansible_distribution_version }}'
      - product: 'sle-module-containers'
        version: '{{ ansible_distribution_version }}'
      - product: 'sle-module-server-applications'
        version: '{{ ansible_distribution_version }}'
      - product: 'sle-module-web-scripting'
        version: '{{ ansible_distribution_version }}'
      - product: 'PackageHub'
        version: '{{ ansible_distribution_version }}'
```

License
-------

GPLv3

Author Information
------------------

Sebastian Meyer (meyer@b1-systems.de)
B1 Systems GmbH
