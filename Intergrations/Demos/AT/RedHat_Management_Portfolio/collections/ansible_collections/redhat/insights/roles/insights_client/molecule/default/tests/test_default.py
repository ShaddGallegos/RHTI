from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_hosts_file(host):
    if host.package('insights-client').is_installed:
        insights_name = 'insights-client'
    else:
        insights_name = 'redhat-access-insights'

    insights_conf_file = '/etc/' + insights_name + '/' + insights_name + '.conf'
    assert host.package(insights_name).is_installed
    assert host.file(insights_conf_file).exists
