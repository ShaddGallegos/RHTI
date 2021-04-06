compliance
========

Installs, configures, and runs [OpenSCAP](https://www.open-scap.org) compliance on a system connected to the [Red Hat Insights service](https://access.redhat.com/documentation/en-us/red_hat_insights/).  This role is intended to work on Red Hat Enterprise Linux.

Requirements
------------
- The Insights client must be installed and configured prior to using the compliance service. See the [insights_client](../insights_client/README.md) role for automated deployment and configuration of the client. 

- The host must me configured in the [Insights portal](https://cloud.redhat.com/insights/compliance) prior to running a compliance scan.

Role Variables / Configuration
--------------

N/A

Dependencies
------------

N/A

Example Playbook
----------------

The role can be used in three ways from a playbook, install only, run only, or all-in-one. The all-in-one is most common and recommend usage as it will ensure all pre-requisites are met prior to running a compliance scan.

```
---
- hosts: all
  
  tasks:
  - name: insights compliance
    import_role:
      name: redhat.insights.compliance
```

If you only wish to install pre-requisites without running a compliance scan the role may be used with only the "install" tasks as shown in the example below. 

```
---
- hosts: all

  tasks:
  - name: install insights compliance
    import_role:
      name: redhat.insights.compliance
      tasks_from: install
```

To speed up compliance scans after installation of prerequisites, the role may be run with only the "run" tasks as shown in the example below. Use caution when using this method as it can cause hosts to fail or become inconsistent with other hosts since prerequisites are not being checked and met prior to running a scan.

```
---
- hosts: all

  tasks:
  - name: run insights compliance
    import_role:
      name: redhat.insights.compliance
      tasks_from: run
```
