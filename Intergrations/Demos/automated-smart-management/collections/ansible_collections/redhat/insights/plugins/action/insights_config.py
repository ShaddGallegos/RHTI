from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

from ansible.plugins.action import ActionBase


class ActionModule(ActionBase):

    def run(self, tmp=None, task_vars=None):

        result = super(ActionModule, self).run(tmp, task_vars)

        insights_name = self._task.args.get('insights_name', 'insights-client')

        config_vars = dict(
            username=self._task.args.get('username', None),
            password=self._task.args.get('password', None),
            auto_config=self._task.args.get('auto_config', None),
            authmethod=self._task.args.get('authmethod', None),
            display_name=self._task.args.get('display_name', None),
            proxy=self._task.args.get('proxy', None)
        )

        for k, v in config_vars.items():
            if v:
                new_module_args = dict(
                    path='/etc/' + insights_name + '/' + insights_name + '.conf',
                    section=insights_name,
                    option=k,
                    value=v,
                    no_extra_spaces=True,
                    state="present"
                )
                result.update(self._execute_module(
                    module_name='ini_file',
                    module_args=new_module_args,
                    task_vars=task_vars,
                    tmp=tmp
                ))

        return result
