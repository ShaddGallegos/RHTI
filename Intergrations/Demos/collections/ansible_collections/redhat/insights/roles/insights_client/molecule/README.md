Testing insights-client role with Molecule
==========================================

The role uses [Molecule](https://github.com/metacloud/molecule) for testing.  See below
for installing and running Molecule.

Because of what this role is intended to do, in order to test this role, you need a copy
of Red Hat Enterprise Linux and a subscription to the
[Red Hat Insights service](http://access.redhat.com/insights) service.

Here Molecule is configured to test this role on three libvirt Vagrant boxes named
'rhel68-base', 'rhel72-base', and 'rhel74-base'.  The number or names of the boxes tested
by the default scenario can be changed by editing the 'platforms' section
of the 'molecule/default/molecule.yml' file.  The names can be arbitrary as long as they refer
to Vagrant boxes available on the test machine.  The command 'vagrant box list' will tell you
which boxes are available on the test machine.  The tests should work for any currently supported
version of RHEL.

Vagrant boxes for RHEL are not generally available, though both Red Hat Developer Support and
Red Hat Support sites have instructions for creating Vagrant boxes from RHEL images.

Since this role actually registers with the Insights service, the test boxes must register
with the Red Hat Portal.  Portal credentials must be supplied in the file
'~/redhat-portal-creds.yml', in the format described below.


Installing Molecule
-------------------

The easiest way to install Molecule at the point of writing this, is to use a Python virtual environment and pip.

    ```bash
    $ virtualenv --no-site-packages .venv
    $ source .venv/bin/activate
    $ pip install molecule ansible python-vagrant
    ```

Review or Edit the file 'molecule/default/molecule.yml'
-------------------------------------------------------

Make sure the boxes specified in the 'platforms' section are boxes that are actually available
on the test machine.

Review or Edit the portal creds file: ~/redhat-portal-creds.yml
-------------------------------------------------------

Create a YAML file, ~/redhat-portal-creds.yml, on the test machine containing the following,
with XXXXXX/YYYYYY replaced with our Insights/Portal/RHSM username/password:

    redhat_portal_username: XXXXXX
    redhat_portal_password: YYYYYY

Run the molecule test
---------------------

    ```bash
    $ molecule test
    ```

or if you need more details from the error messages:

    ```bash
    $ molecule test --debug
    ```

