# approval-base

## Overview
This role sets up the minimal config that enables Tower to implement gating approvals within Workflow Templates. It handles:
1. Creating a project that points to the repository where this content lives.
2. Creating a machine credential and inventory for use with approval-related job templates.
3. Creating a special credential type for use with approval gate job templates.
    - This is basically a regular Ansible Tower credential with an additional input for gate name.
    - Additional injectors are defined based on the gate name that pass critical information from gate to the following workflow. 
4. Creating a Tower credential for administrative tasks.
5. Creates a job template that is used for destroying approval requests.

## Requirements
[`tower-cli`](http://tower-cli.readthedocs.io/en/latest/) must be installed on the Ansible control host that runs this role. It must be configured to authenticate with the target Ansible Tower server and the associated user account must have system administrator permission so that the necessary resources can be created in Tower.
