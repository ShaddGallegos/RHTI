#!/usr/bin/python

# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

ANSIBLE_METADATA = {'metadata_version': '1.1',
                    'status': ['preview'],
                    'supported_by': 'community'}

DOCUMENTATION = '''
---
module: insights_config
short_description: This module handles initial configuration of the insights client on install
description: >
    Supply values for various configuration options that you would like to use.
    On install this module will add those values to the insights-client.conf file prior to registering.
options:
  username:
    description: >
      Insights basic auth username. If defined this will change, set, or remove the username
      in the insights configuration. To remove a username set this value to an empty string.
    required: false
  password:
    description: >
      Insights basic auth password. If defined this will change, set, or remove the password
      in the insights configuration. To remove a password set this value to an empty string.
    required: false
  auto_config:
    description:
    - Attempt to auto-configure the network connection with Satellite or RHSM. Default is True.
    required: false
  authmethod:
    description: >
      Authentication method for the Portal (BASIC, CERT). Default is BASIC. Note: when
      auto_config is enabled, CERT will be used if RHSM or Satellite is detected.
    required: false
  display_name:
    description: >
      Custom display name to appear in the Insights web UI. Only used on machine registration.
      Blank by default.
    required: false
  insights_name:
    description: >
      For now, this is just 'insights-client', but it could change in the future so having
      it as a variable is just preparing for that.
    required: false
  proxy:
    description: >
      This set an optional proxy for the insights client to connect through if the client
      is behind a firewall or requires a proxy. Default is unspecified (none).
    required: false

author:
    - Jason Stephens (@Jason-RH)
'''

EXAMPLES = '''
- name: Configure the insights client to register with username and password stored in Ansible Tower Custom Credential
  insights_config:
    username: "{{ lookup('env', INSIGHTS_USER) }}"
    password: "{{ lookup('env', INSIGHTS_PASSWORD) }}"
    auto_config: "{{ auto_config }}"
    authmethod: "{{ authmethod }}"
    proxy: "{{ insights_proxy }}"
  become: true

- name: Configure the insights client to register with RHSM and no display name
  insights_config:
  become: true

# Note: The above example calls the insights_config module with no parameters. This is because auto_config defaults to True
# which in turn forces the client to try RHSM (or Satellite)

- name: Configure the insights client to register with RHSM and a display name
  insights_config:
    display_name: "{{ insights_display_name }}"
  become: true
'''
