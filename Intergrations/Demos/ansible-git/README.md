# ansible-git

This role can be used to do a `git pull` and `git push` within a playbook. Below are the variables and sample playbook. 

| Variable | Defaults | Comments |
|-|-|-|
| `git_url` | | (required) The URL of the git repository in the from git@server.com:namespace/repo |
| `git_key` | | (required) The SSH private key used to authenticate to the repo. Use of lookup plugin, ansible vault, or Tower custom credential recommended |
| `git_email` | ansible_git@ansible.com | The email for git to use for commits |
| `git_username` | ansible_git | The username for git to use for commits |
| `git_branch` | master | Branch in the repository |
| `git_msg` | 'update files with ansible' | Git commit message |
| `git_remove_local` | false | remove local copy of repository |

## Example
```
---
- hosts: localhost
  vars:
   git_url: 'git@github.com:willtome/ansible-git.git'
   git_key: "{{ lookup('file','./id_rsa') }}"

  tasks:
  - name: git pull
    include_role:
      name: ansible-git
      tasks_from: pull

  - name: create file in repo
    copy:
      dest: ansible-git/time.yml
      content: "{{ ansible_date_time | to_nice_yaml}}"

  - name: git push
    include_role:
      name: ansible-git
      tasks_from: push
```

**Tested:**
git 1.8.3/2.15.1 