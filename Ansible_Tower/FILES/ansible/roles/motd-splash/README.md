[![GoKEV](http://GoKEV.com/GoKEV200.png)](http://GoKEV.com/)

<div style="position: absolute; top: 40px; left: 200px;">

# motd-splash

This role lays down a template for /etc/issue (pre-login warning) as well as /etc-motd (post login splash).

This includes two colorful ASCII text logos for CentOS or Red Hat. The role will conditionally determine CentOS or RHEL logo, based on Ansible fact gathering of the target OS. If the target system is neither, a generic and boring template is used. All template options lay down some basic information about the target system for login MOTD display.


## Here's an example of how you could launch this role:
<pre>
ansible-playbook motd-splash.yml
</pre>

## Example Playbook called motd-splash.yml:

<pre>
---
- name: Run this MOTD splash role
  hosts: localhost

# optionally force a specific motd (if you run CentOS but want to show some Red Hat logo love instead!)
#  vars:
#  - motd_template_file: templates/motd_redhat

  roles:
    - GoKEV.motd-splash

</pre>

## With a requirements.yml that looks as such:

<pre>
---
- name: GoKEV.motd-splash
  version: master
  src: https://github.com/GoKEV/motd-splash.git

</pre>

License
-------

Logo artwork is rough ASCII text and was rendered without approval or permission of respective copyright holders.  The original logo, likeness, or usability of these logos is still property of the respective copyright holders and can be revoked at their discretion.  There are probably all sorts of legalese things that I should say here, but in a nutshell... these logos will make your system look cool.  I hope the people that designed and own the artwork will appreciate that intent.



Author Information
------------------

Kevin Holmes :: kev@GoKEV.com



Screen Shots of End Results
------------------

/etc/motd for RHEL systems
![motd_rhel](files/motd_redhat.png?raw=true "/etc/motd_redhat")

/etc/motd for CentOS systems
![motd_centos](files/motd_centos.png?raw=true "/etc/motd_centos")

/etc/motd for systems that have no OS-specific MOTD template
![motd_generic](files/motd_generic.png?raw=true "/etc/motd_generic")

/etc/motd with the legacy Shadowman Red Hat logo (must be declared manually in vars -- see README.md playbook example)
![motd_generic](files/motd_shadowman.png?raw=true "/etc/motd_shadowman")

/etc/motd with the GoKEV in ASCII glory (must be declared manually in vars -- see README.md playbook example)
![motd_generic](files/motd_gokev.gif?raw=true "/etc/motd_gokev")

/etc/issue pre-login warning
![issue](files/issue.png?raw=true "/etc/issue")


This project was created in 2018 by [Kevin Holmes](http://GoKEV.com/).

- Update 2019-05-10 :: After the new Red Hat logo was released at Red Hat Summit 2019, the shadowman style logo was replaced by the new RHT logo

