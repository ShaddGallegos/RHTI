# Setup
Ensure AWS CLI is installed and configured properly.

Create hosts file in the following format. Complete sections in `< >` with your environment details.
```
tower ansible_host=<TOWER FQDN> ansible_user=admin ansible_password=<TOWER PASSWORD> userid=<USERID> guid=<GUID>
satellite ansible_host=<SATELLITE FQDN> ansible_user=admin ansible_password=<SATELLITE PASSWORD>
```

Login to Satellite, ensure that manifest is configured properly and repositories can be selected. If not, remove exiting manifest and re-import.

Run `ansible-playbook -i hosts setup/satellite.yml`

Login to Satellite, navigate to Content > Sync Status and begin sync.

Install Tower CLI and run `tower-cli config host <TOWER FQDN>` followed by `tower-cli login admin` to retrieve authentication token.

Run `ansible-playbook -i hosts setup/tower.yml`

Install apypie package into tower virtual environment 