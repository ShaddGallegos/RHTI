Role Name
=========
[![license][2i]][2p]
[![twitter][3i]][3p]

An OpenSUSE common self provision.

Description
-----------

The provision is to install the base similar packages installed on most self provisioned machines. It's more tailored focus to the author's needs, but may help others for their own versioning.

Requirements
------------

Currently only works on openSUSE Leap and Tumbleweed. Eventually should foster to holding commons for SLE when disabling GUI applications is added.

Usage
-----

Besides the requirements given above, you only need to append to your *playbook* the following:

``` yaml
- hosts: servers
    roles:
        - abaez.susecommon
```

Author Information
------------------

[Alejandro Baez][1]

[1]: https://keybase.io/baez
[2i]: https://img.shields.io/badge/license-BSD_2-green.svg
[2p]: ./LICENSE
[3i]: https://img.shields.io/badge/twitter-a_baez-blue.svg
[3p]: https://twitter.com/a_baez
