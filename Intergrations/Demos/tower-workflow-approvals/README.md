Ansible Tower now supports approval gates for workflows! [This blog post](https://www.ansible.com/blog/how-to-add-approval-steps-to-ansible-tower-workflows) is a great place to start. I have archived this repository since the native approval gates should be used.

# tower-workflow-approvals
> An experiment for implementing workflow approval gates within Ansible Tower.

![Flow diagram showing how workflow approvals work.](https://raw.githubusercontent.com/wtcross/tower-workflow-approvals/master/images/flow-diagram.png)

## Use Case Examples
> An enterprise architect wants to insert approval gates into the workflows they are responsible for managing that run playbooks from various different teams.

> At the end of a workflow approval is required in order to make a change in production.

> A system build team wants to require approval before launching a workflow that provisions machines.

## Overview
The idea behind this project is that a workflow can be split at any edge that
requires an approval to traverse. This means there will be multiple workflows
that actually function as a larger one. Each approval gate creates an approval
request that is represented by a job template that only the approval team specific
to the approval gate that created it can execute. The approval request job template
will launch the next workflow and set all current workflow artifacts as extra
variables. The [set_stats module](http://docs.ansible.com/ansible/latest/set_stats_module.html) is used to create [artifacts](http://docs.ansible.com/ansible-tower/latest/html/userguide/workflows.html#extra-variables). Any extra
variables set on the approval gate job template itself will also be passed on to
the next workflow.

Each role also has its own README:
- [`approval-base`](roles/approval-base/README.md)
- [`approval-gate-config`](roles/approval-gate-config/README.md)
- [`approval-gate`](roles/approval-gate/README.md)

## Requirements
[`tower-cli`](http://tower-cli.readthedocs.io/en/latest/) must be installed on the Ansible control host that runs this role.
It must be configured to authenticate with the target Ansible Tower server and
the associated user account must have system administrator type so that the
necessary resources can be created in Tower.

## Usage
All configuration of Tower has been automated. The very first thing that needs to
be done is configuring your `tower-cli` to use a [system administrator user](http://docs.ansible.com/ansible-tower/latest/html/userguide/users.html). It
is recommended to create a new user specifically for this project. The automation
will actually create credentials in Tower (keep in mind these are encrypted) so
that job templates can leverage them.

### Adding a Gate
1. Ensure `tower-cli` is configurd with the system administrator user created for workflow approvals.
2. Run `ansible-playbook create-approval-gate.yml -e approval_gate_name="Approval Required"`

This will configure Tower with all necessary resources to enable creating an approval gate job template.
To create an approval gate job template perform the following:
1. Add a new job template to Tower
    - Set the name to something meaningful that indicates it is a gate
    - Set necessary credentials
        - `Workflow Approvals` machine credential
        - `Approval Gate / {{ approval_gate_name }}` Workflow Approval Gate credential
    - Set inventory to the `Workflow Approvals` inventory
    - Set Project to the `Workflow Approvals` project
    - Select the `approval-gate.yml` playbook
    - Ensure the extra_vars section has the following variables defined:
        - `next_workflow_template`: This is the name of the next workflow template to launch
2. Navigate to the worfklow where a gate needs to be added and enter its workflow editor.
3. Add a job template at the location where the gate needs to be.
4. Select the created gate job template

After performing these steps when a user launches the workflow the gate job template will create
an approval request job template that is configured to launch the next job. The next job is only
launched if the approver actually approves the request.
