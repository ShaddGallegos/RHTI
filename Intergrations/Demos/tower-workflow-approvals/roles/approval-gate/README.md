# approval-gate

## Overview
This role automates the steps that need to be taken that actually represent an approval gate. It handles:
1. Creating a job template that represents the request.
    - This new request will contain all extra_vars that were present on the approval gate job, which does include all workflow artifacts.
2. Granting permission to execute this job template to the team assigned to this gate.
3. Sending notification emails to both the requester and approver of this request.

## Parameters
- `next_workflow_template` (required): This is the name of the next workflow template to launch

## Requirements
[`tower-cli`](http://tower-cli.readthedocs.io/en/latest/) must be installed on the Ansible control host that runs this role. It must be configured to authenticate with the target Ansible Tower server and the associated user account must have system administrator permission so that the necessary resources can be created in Tower.
