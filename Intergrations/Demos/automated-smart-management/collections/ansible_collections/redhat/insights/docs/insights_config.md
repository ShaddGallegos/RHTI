insights_config - This module handles initial configuration of the insights client on install
====================================
- [Synopsis](Synopsis)
- [Requirements](Requirements)
- [Parameters](Parameters)
- [Examples](Examples)

## Synopsis
'Supply values for various configuration options that you would like to use. On install
    this module will add those values to the insights-client.conf file prior to registering.

    '

## Requirements
''

## Parameters

<table>
<tr>
<th> Parameter </th>
<th> Choices/Defaults </th>
<th> Configuration </th>
<th> Comments </th>
</tr>
<tr>
<td><b>username</b></br>
</td>
<td></td>
<td></td>
<td> Insights basic auth username. If defined this will change, set, or remove the username in the insights configuration. To remove a username set this value to an empty string.
</td>
</tr>
<tr>
<td><b>insights_name</b></br>
</td>
<td></td>
<td></td>
<td> For now, this is just 'insights-client', but it could change in the future so having it as a variable is just preparing for that.
</td>
</tr>
<tr>
<td><b>display_name</b></br>
</td>
<td></td>
<td></td>
<td> Custom display name to appear in the Insights web UI. Only used on machine registration. Blank by default.
</td>
</tr>
<tr>
<td><b>auto_config</b></br>
</td>
<td></td>
<td></td>
<td> [u'Attempt to auto-configure the network connection with Satellite or RHSM. Default is True.']</td>
</tr>
<tr>
<td><b>authmethod</b></br>
</td>
<td></td>
<td></td>
<td> Authentication method for the Portal (BASIC, CERT). Default is BASIC. Note: when auto_config is enabled, CERT will be used if RHSM or Satellite is detected.
</td>
</tr>
<tr>
<td><b>proxy</b></br>
</td>
<td></td>
<td></td>
<td> This set an optional proxy for the insights client to connect through if the client is behind a firewall or requires a proxy. Default is unspecified (none).
</td>
</tr>
<tr>
<td><b>password</b></br>
</td>
<td></td>
<td></td>
<td> Insights basic auth password. If defined this will change, set, or remove the password in the insights configuration. To remove a password set this value to an empty string.
</td>
</tr>
</table>

## Examples
```

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

```