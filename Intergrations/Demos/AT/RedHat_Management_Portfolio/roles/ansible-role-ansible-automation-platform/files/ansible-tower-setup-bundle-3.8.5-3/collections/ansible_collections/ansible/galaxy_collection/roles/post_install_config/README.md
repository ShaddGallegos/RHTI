Post Install Config
===================
Perform post install configuration steps for [GalaxyNG](https://github.com/ansible/galaxy_ng).

Variables
---------
* `pulp_install_source`: Set to "packages" for an RPM install, or "pip" for a Python install. Defaults to "pip".
* `pulp_config_dir`: Directory which will contain Pulp configuration files. Defaults to "/etc/pulp".
* `pulp_install_dir`: Location of Pulp and dependencies. Defaults to "/usr/local/lib/pulp" for Python installs, or "/usr/bin" for RPM installs.
* `pulp_user`: System user that owns and runs Pulp. Defaults to "pulp".
* `pulp_default_admin_password`: Initial password for the Pulp admin. Defaults to "password".
* `pulp_url`: URL for connecting to the Pulp API server. Defaults to "http://127.0.0.1:24817/".
* `pulp_settings_file`: Location of the Django setings files. Defaults to "{{ pulp_config_dir }}/settings.py".
* `pulp_validate_certs`: Whether or not the TLS certificates should be verified. Defaults to "true".
* `galaxy_importer_settings`: Key value dictionnary that contains the content of `galaxy-importer.cfg` to be overwritten.
