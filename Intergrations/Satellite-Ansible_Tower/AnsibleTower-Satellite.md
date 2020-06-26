# Simple Ansible and Satellite Intergration ASI - Proof of Concept

These playbooks use Satellite API to create a node in libvirt 

Satellite then provisions the node 

## What you need
----------

### ANSIBLE

 * Ansible Tower
 * Ansible 2.9 or later
 * Dynamic inventory
 * These playbooks [ASI](./ASI) 
 * Project
 * Satellite 6 Credential
 * Machine Cerdential to manage nodes
 * Template calling 
        main.yml
        Work flow templates (optional)  
 * Survey for:
        sat_server_url: "{{ SATFQDN }}"   <-- should be https://sat.example.com 
        sat_password: "{{ SATPASSWORD }}" <-- Uses the service "admin" account
        name: "{{ newnodez }}"            <-- shortname node to create

### SATELLITE

 * A Satellite 6.7 server (or later)
 * Compute Resourses (libvirt) 
 * DHCP
 * DNS
 * tftp

### LIBVIRT


## How to create new Hosts




