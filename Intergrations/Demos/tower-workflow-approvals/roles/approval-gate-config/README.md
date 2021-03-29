# approval-gate-config

## Overview
This role adds approval gate specific resources to Tower. Each approval gate has a team and a workflow approval gate credential. When approval requests are created they will be represented as job templates that the approval gate team is able to execute.

## Parameters
- `approval_gate_name` (required): The name of the approval gate that is being created.

## Requirements
[`tower-cli`](http://tower-cli.readthedocs.io/en/latest/) must be installed on the Ansible control host that runs this role. It must be configured to authenticate with the target Ansible Tower server and the associated user account must have system administrator permission so that the necessary resources can be created in Tower.
