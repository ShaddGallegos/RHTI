insights_register - This module registers the insights client
====================================
- [Synopsis](Synopsis)
- [Requirements](Requirements)
- [Parameters](Parameters)
- [Examples](Examples)

## Synopsis
'This module will check the current registration status, unregister if needed, and
    then register the insights client (and update the display_name if needed)

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
<td><b>force_reregister</b></br>
</td>
<td></td>
<td></td>
<td> This option should be set to true if you wish to force a reregister of the insights-client. Note that this will remove the existing machine-id and create a new one. Only use this option if you are okay with creating a new machine-id.
</td>
</tr>
<tr>
<td><b>state</b></br>
</td>
<td><b>Choices:</b><br>
- present
- absent
<b>Default:</b><br> 
present</td>
<td></td>
<td> [u'Determines whether to register or unregister insights-client']</td>
</tr>
<tr>
<td><b>display_name</b></br>
</td>
<td></td>
<td></td>
<td> This option is here to enable registering with a display_name outside of using a configuration file. Some may be used to doing it this way so I left this in as an optional parameter.
</td>
</tr>
<tr>
<td><b>insights_name</b></br>
</td>
<td><b>Default:</b><br> 
insights-client</td>
<td></td>
<td> For now, this is just 'insights-client', but it could change in the future so having it as a variable is just preparing for that
</td>
</tr>
</table>

## Examples
```

# Normal Register
- name: Register the insights client
  insights_register:
    state: present

# Force a Reregister (for config changes, etc)
- name: Register the insights client
  insights_register:
    state: present
    force_reregister: true

# Unregister
- name: Unregister the insights client
  insights_regsiter:
    state: absent

# Register an install of redhat-access-insights (this is not a 100% automated process)
- name: Register redhat-access-insights
  insights_register:
    state: present
    insights_name: 'redhat-access-insights'

#Note: The above example for registering redhat-access-insights requires that the playbook be
#changed to install redhat-access-insights and that redhat-access-insights is also passed into
#the insights_config module and that the file paths be changed when using the file module

```