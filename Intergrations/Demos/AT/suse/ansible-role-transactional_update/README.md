![Ansible Lint](https://github.com/johanneskastl/ansible-role-transactional_update/workflows/Ansible%20Lint/badge.svg)

transactional_update
=========

Update a transactional server by running the transactional-update command.

Requirements
------------

Can only be executed on openSUSE/SUSE machines that have the transactional server role, i.e. are prepared for running transactional updates. See the [documentation](https://github.com/openSUSE/transactional-update) and the [manpage](https://kubic.opensuse.org/documentation/man-pages/transactional-update.8.html) for further information.

Role Variables
--------------

None.

Dependencies
------------

Needs the reboot role to trigger a reboot, as the updates will not be in place afterwards, due to the nature of the transactional updates.

Example Playbook
----------------

    - hosts: servers
      roles:
         - { role: 'johanneskastl.transactional_update' }

License
-------

BSD-3-Clause

Author Information
------------------

I am Johannes Kastl, reachable via kastl@b1-systems.de.
