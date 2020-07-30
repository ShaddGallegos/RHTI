# TOWER-CLI EXAMPLES

        This is a collection of examples of how to set up Tower using tower-cli that I have collected.
        More documentation can be found at:

        https://docs.Ansible.com/Ansible Tower/latest/html/towerapi/tower_cli.html

## Installation & Preparation
----------------

        Install `python2-ansible-tower-cli` from the OS' repos or use `pip install python2-ansible-tower-cli --upgrade `.

### To set up tower-cli you can use any of the methods described in its documentation, like, e.g.,

        $ tower-cli config host tower.example.com
        $ tower-cli config username leeroyjenkins
        $ tower-cli config password myPassw0rd

### If you're creating long scripts (e.q. to set up an entire tower) it makes sense to use

        '#! /bin/bash'
         set -e
         so that the script exits if one of the commands fail

## Config Examples
----------------

        Organization, team, and user

#### Org

        tower-cli organization create -n org-example --force-on-exists

#### User(org-Admin):

        tower-cli user create --username org-admin-username --password "987654321" --email a@example.com --first-name Org --last-name Admin --force-on-exists --is-superuser False --is-system-auditor False
        tower-cli role grant --type admin --user org-admin-username --organization "org-example"

### Create teams for normal users and power users with additional permissions (see below):

#### Teams

        tower-cli team create -n team-example \
         --organization org-example \
         --force-on-exists
        tower-cli team create -n team-PU-example \
         --organization org-example \
         --force-on-exists
            Credentials Creation

        tower-cli credential create -n cred-example --credential-type Machine \
         --organization org-example --team team-PU-example \
         --force-on-exists \
         --inputs 'username: some_user

        become_method: sudo
        ssh_key_data: |
        '"$(sed 's/^/ /' ${TOWER_RSA})"

## Inventories
----------------

### Add an inventory script to tower:

        tower-cli inventory_script create -n custinv-example-ucmdb \
         --organization org-example \
         --script "$(cat ${INVENTORY_SCRIPT})" \
         --force-on-exists

### Create the actual inventory (the Jinja2 templating here is an example that could be used if Ansible's template module would be used to set-up the tower. In that case, `test.inv.vars` would be provided in that context.

        tower-cli inventory create -n inv-example \
         --organization org-example \
         --force-on-exists \
        {% if test.inv.vars is defined %}
         --variables "{ {% for item in test.inv.vars %}{{ item }}, {% endfor %} }"
        {% endif %}

### Add the script created earlier to the inventory:

        tower-cli inventory_source create --name src-example-ucmdb \
         --inventory inv-example \
         --source custom --source-script custinv-example-ucmdb \
         --overwrite true --overwrite-vars true --update-on-launch true \
         --force-on-exists

### Allow teams to access/edit/admin the inventory
        tower-cli role grant --type use --team team-PU-example -i inv-example
        tower-cli role grant --type adhoc --team team-PU-example -i inv-example
        tower-cli role grant --type update --team team-PU-example -i inv-example
        tower-cli role grant --type update --team team-MA-example -i inv-example

## Add Projects
----------------

### This example sets up a project with 'manual' SCM (better use git IRL).

        tower-cli project create -n prj-example \
         -d "Playbooks for example project" \
         --organization org-example --scm-type manual \
         --local-path playbooks-example \
         --force-on-exists

### As with the inventories above, Grant teams particular rights.

        tower-cli role grant --type admin --team team-PU-example --project "prj-example"
        tower-cli role grant --type use --team team-PU-example --project "prj-example"
        tower-cli role grant --type update --team team-PU-example --project "prj-example"

## Create A Job Templates
----------------

        tower-cli job_template create \
         -n creative_job_name \
         -i inv-example --playbook hack_the_planet.yml \
         --job-type run --project prj-example \
         --credential cred-example \
         --host-config-key somerandomhostconfigkey \
         --ask-variables-on-launch true \
         --extra-vars "key1: value1" \
         --extra-vars "key2: value2" \
         --force-on-exists

### Grant access:

        tower-cli role grant --type admin --team team-PU-example --job-template "creative_job_name"
        tower-cli role grant --type execute --team team-example --job-template "creative_job_name"

## Custom Credential Types
----------------

### The following example creates a credential type to store username and password:

        tower-cli credential_type create \
         -n "tower-cli-credential" -d "Custom credential for tower-cli" \
         --kind cloud --inputs '{ "fields": [ { "type": "string", "id": "username", "label": "Username for Tower" }, \
         { "label": "Tower Password", "secret": true, "type": "string", "id": "password" } ], "required": [ "username", "password" ] }' \
         --injectors '{ "extra_vars": { "tower_cli_user": "{{ username }}", "tower_cli_password": "{{password}}" } }' \
         --force-on-exists

### Create an actual credential of that type:

        tower-cli credential create \
         -n "cred-example-tower-cli" --credential-type "tower-cli-credential" \
         --organization org-example \
         --force-on-exists \
         --inputs '{ "username": "tower-cli-cred-user-example","password": "'"${TOWER_CLI_PASSWORD}"'"}'

### Allow the power-users to use that credential

        tower-cli role grant --type use --team team-PU-example --credential "cred-example-tower-cli"

### Associate the credential with a job-template, so that it is actually accessible from there

        tower-cli job_template associate_credential \
         --credential cred-example-tower-cli \
         --job-template creative_job_name

## Add Users To Teams
----------------

        tower-cli user create --username power_user-example --password redhat --email eb@example.example.com \
         --first-name El --last-name Barto --force-on-exists --is-superuser False --is-system-auditor False

        tower-cli team associate --team team-PU-example --user power_user-example

        tower-cli user create --username normal_user-example --password redhat --email bs@example.example.com \
         --first-name Bart --last-name Simpson --force-on-exists --is-superuser False --is-system-auditor False

        tower-cli team associate --team team-example --user normal_user-example
