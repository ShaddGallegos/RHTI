# Linux AppDev Development Setup #

[![Build Status](https://travis-ci.org/irahopkinson/appdev_linux.svg?branch=master)](https://travis-ci.org/irahopkinson/appdev_linux)

Install and configure development environment for developing AppDev plugins.

Install **ansible**
```
sudo apt-get install ansible
```

Copy to a **deploy** folder or clone...
```
git clone https://github.com/irahopkinson/appdev_linux.git deploy
```

You may need to install Ansible role [geerlingguy.nodejs](https://galaxy.ansible.com/detail#/role/465).
```
ansible-galaxy install geerlingguy.nodejs -p ./deploy/roles/
```

then...
```
cd deploy
ansible-playbook -i hosts playbook_appdev.yml --limit localhost -K
```

## License ##

Licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
