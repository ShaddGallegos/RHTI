********************
Ansible Turbo Module
********************

.. note:: Better name welcome.

Current situation
=================

The traditional execution flow of an Ansible module includes
the following steps:

- Upload of a ZIP archive with the module and its dependencies
- Execution of the module, which is just a Python script
- Ansible collects the results once the script is finished

These steps happen for each task of a playbook, and on every host.

Most of the time, the execution of a module is fast enough for
the user. However, sometime the module requires an important
amount of time, just to initialize itself. This is a common
situation with the API based modules. A classic initialization
involves the following steps:

- Load a Python library to access the remote resource (via SDK)
- Open a client
    - Load a bunch of Python modules.
    - Request a new TCP connection.
    - Create a session.
    - Authenticate the client.

All these steps are time consuming and the same operations
will be running again and again.

For instance, here:

- ``import openstack``: takes 0.569s
- ``client = openstack.connect()``: takes 0.065s
- ``client.authorize()``: takes 1.360s

These numbers are from test ran against VexxHost public cloud.

In this case, it's a 2s-ish overhead per task. If the playbook
comes with 10 tasks, the execution time cannot go below 20s.

How Ansible Turbo Module improve the situation
==============================================

``AnsibleTurboModule`` is actually a class that inherites from
the standard ``AnsibleModule`` class that your modules probably
already use.
The big difference is that when an module starts, it also spawns
a little Python daemon. If a daemon already exists, it will just
reuse it.
All the module logic is run inside this Python daemon. This means:

- Python modules are actually loaded one time
- Ansible module can reuse an existing authenticated session.

How can I enable ``AnsibleTurboModule``?
========================================

If you are a collection maintainer and want to enable ``AnsibleTurboModule``, you can
follow these steps.
Your module should inherit from ``AnsibleTurboModule``, instead of ``AnsibleModule``.

.. code-block:: python

  from ansible_module.turbo.module import AnsibleTurboModule as AnsibleModule

You can also use the ``functools.lru_cache()`` decorator to ask Python to cache
the result of an operation, like a network session creation.

Finally, if some of the dependeded libraries are large, it may be nice
to defer your module imports, and do the loading AFTER the
``AnsibleTurboModule`` instance creation.

.. note:: AnsibleTurboModule depends on Python 3.6 or greater

Example
=======

The Ansible module is slightly different while using AnsibleTurboModule.
Here are some examples with OpenStack and VMware.

These examples use ``functools.lru_cache`` that is the Python core since 3.3.
``lru_cache()`` decorator will managed the cache. It uses the function parameters
as unicity criteria.

- Integration with OpenStack Collection: https://github.com/goneri/ansible-collections-openstack/commit/53ce9860bb84eeab49a46f7a30e3c9588d53e367
- Integration with VMware Collection: https://github.com/goneri/vmware/commit/d1c02b93cbf899fde3a4665e6bcb4d7531f683a3
- Integration with Kubernetes Collection: https://github.com/ansible-collections/kubernetes.core/pull/68

Demo
====

In this demo, we run one playbook that do several ``os_keypair``
calls. For the first time, we run the regular Ansible module.
The second time, we run the same playbook, but with the modified
version.


.. raw:: html

    <a href="https://asciinema.org/a/329481?autoplay=1" target="_blank"><img src="https://asciinema.org/a/329481.png" width="835"/></a>

The background service
======================

The daemon kills itself after 15s, and communication are done
through an Unix socket.
It runs in one single process and uses ``asyncio`` internally.
Consequently you can use the ``async`` keyword in your Ansible module.
This will be handy if you interact with a lot of remote systems
at the same time.

Security impact
===============

``ansible_module.turbo`` open an Unix socket to interact with the background service.
We use this service to open the connection toward the different target systems.

This is similar to what SSH does with the sockets.

Keep in mind that:

- All the modules can access the same cache. Soon an isolation will be done at the collection level (https://github.com/ansible-collections/cloud.common/pull/17)
- A task can loaded a different version of a library and impact the next tasks.
- If the same user runs two ``ansible-playbook`` at the same time, they will have access to the same cache.

When a module stores a session in a cache, it's a good idea to use a hash of the authentication information to identify the session.

.. note:: You may want to isolate your Ansible environemt in a container, in this case you can consider https://github.com/ansible/ansible-builder

Error management
================

``ansible_module.turbo`` uses exception to communicate a result back to the module.

- ``EmbeddedModuleFailure`` is raised when ``json_fail()`` is called.
- ``EmbeddedModuleSuccess`` is raised in case of success and return the result to the origin module processthe origin.

Thse exceptions are defined in ``ansible_collections.cloud.common.plugins.module_utils.turbo.exceptions``.
You can raise ``EmbeddedModuleFailure`` exception yourself, for instance from a module in ``module_utils``.

.. note:: Be careful with the ``except Exception:`` blocks.
    Not only they are bad practice, but also may interface with this
    mechanism.


Troubleshooting
===============

You may want to manually start the server. This can be done with the following command:

.. code-block:: shell

  PYTHONPATH=$HOME/.ansible/collections python -m ansible_collections.cloud.common.plugins.module_utils.turbo.server --socket-path $HOME/.ansible/tmp/turbo_mode.foo.bar.socket

Replace ``foo.bar`` with the name of the collection.

You can use the ``--help`` argument to get a list of the optional parameters.
