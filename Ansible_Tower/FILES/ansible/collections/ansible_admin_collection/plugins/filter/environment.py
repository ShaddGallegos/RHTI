from __future__ import absolute_import, division, print_function
__metaclass__ = type

from ansible.errors import AnsibleFilterError
from ansible.module_utils.six import iteritems, string_types

from numbers import Number


def environment(environment, exclude=[]):
    if not isinstance(environment, dict):
        raise AnsibleFilterError('environment expects a dict but was given a %s' % type(environment))
    [environment.pop(key, None) for key in exclude]
    result = environment_parameters(environment)
    return result.lstrip()


def environment_parameters(parameters, exclude=[]):
    if not isinstance(parameters, dict):
        raise AnsibleFilterError('environment_parameters expects a dict but was given a %s' % type(parameters))
    [parameters.pop(key, None) for key in exclude]
    result = ''
    for key in sorted(parameters):
        parameter = environment_parameter(parameters, key)
        if parameter:
            result += '\n%s' % parameter
    return result


def environment_parameter(parameters, key, default=None, comment=False):
    if not isinstance(parameters, dict):
        raise AnsibleFilterError('environment_parameter parameters expects a dict but was given a %s' % type(parameters))
    if not isinstance(key, string_types):
        raise AnsibleFilterError('environment_parameter key expects a string but was given a %s' % type(key))
    result = ''
    value = parameters.get(key, default)
    if isinstance(value, string_types):
        result = '%s="%s"' % (key, value)
    elif isinstance(value, Number):
        result = '%s=%s' % (key, value)
    else:
        AnsibleFilterError('environment_parameter value of an unknown type %s' % type(value))
    if comment and key not in parameters:
        result = '#%s' % result
    return result


class FilterModule(object):
    ''' Manala environment jinja2 filters '''

    def filters(self):
        filters = {
            'environment': environment,
            'environment_parameters': environment_parameters,
            'environment_parameter': environment_parameter,
        }

        return filters
