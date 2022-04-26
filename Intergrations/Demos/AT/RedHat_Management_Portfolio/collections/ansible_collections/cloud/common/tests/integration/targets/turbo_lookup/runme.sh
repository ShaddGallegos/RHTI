#!/usr/bin/env bash
set -eux
exec ansible-playbook playbook.yaml -vvv
