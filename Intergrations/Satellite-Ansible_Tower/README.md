# Simple Ansible and Satellite Intergration ASI - Proof of Concept

These playbooks use Satellite API to create a node in libvirt 

Satellite then provisions the node 

## What you need
-----

### ANSIBLE

 * Ansible Tower
 * Ansible 2.9 or later
 * Dynamic inventory 
 * Libvirt host
 * These playbooks [ASI](./ASI) 
 * Project
 * Satellite 6 Credential
 * Machine Cerdential to manage nodes
 * Template calling 
        main.yml
        Work flow templates (optional)  
 * Survey for:
        sat_server_url: "{{ SATFQDN }}"   <-- should be FQDN or ip (https://sat.example.com or https://10.168.0.1)
        sat_password: "{{ SATPASSWORD }}" <-- Uses the service user "admin" account that you sign into satellite with 
        name: "{{ newnodez }}"            <-- shortname node to create

### SATELLITE

 * A Satellite 6.7 server (or later)
 * Compute Resourses (libvirt) 
 * DHCP
 * DNS
 * tftp

### LIBVIRT


## Setup Ansible Tower
-----
For convieniance sake I have provided a script that will automaticly install a single node Proof of Concept type system 

[Requirements](https://docs.ansible.com/ansible-tower/latest/html/installandreference/requirements_refguide.html) for Ansible Tower 
        
        eth0 -- Internal network for building, managing, and provisioning nodes
        eth1 -- External so you can get things from the internet like the bundled installer or use the analytics or other tools at cloud.redhat.com
 
        35GB Storage
        4GB RAM
        2 CPU
 
        / root Rest of drive 
        /boot  1024MB 
        /swap  6GB 

        Red Hat Enterprise Linux 8.2 or later 64-bit (x86)
        Red Hat Enterprise Linux 7.7 or later 64-bit (x86)


####Requirements to setup Ansible Tower

        1. Download the script
             
             wget https://github.com/ShaddGallegos/RHTI/raw/master/Ansible_Tower/ANSIBLE_TOWER-3.7.1-1-INSTALLER.sh 
             
                 What this script does 
                    This installer will work on RHEL 7 or RHEL 8 and:
                    1. Verify you are root 
                    2. Check you are connected to the internet.
                    3. Provide a breif overview of what the tool is.
                    4. Help the end user register with Red Hat if not already done.
                    5. Take of some prep stuff install shut off firewall and selinux and install pip prior to install.
                    6. Enable required repos for OS and Ansible Tower.
                    7. Upgrades the OS.
                    8. Installs the dependencies from the bundle forces them to requirement levels listed in bundle.
                    9. Installs Tower. (Queries user for tower password) 
                    10. Gives the end user the option to enable firewall and selinux.
         
        2. Change to root user
    
             sudo su

        3. Run the script

             sh ANSIBLE_TOWER-3.7.1-1-INSTALLER.sh
        
        Enter Password when prompted

        After you set the password you can walk away and 
        Takes 15-20 min to install Ansible Tower





