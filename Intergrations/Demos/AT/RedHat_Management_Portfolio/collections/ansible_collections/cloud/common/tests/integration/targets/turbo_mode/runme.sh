#!/usr/bin/env bash
set -eux
export ANSIBLE_ROLES_PATH=..
exec ansible-playbook playbook.yaml
