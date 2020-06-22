REDHATTOOLSINSTALLER
--------------------

This code is meant to inspire!

This tool was built to aid in the install Red Hat Satellite 6.7 or the Ansible Tower 3.7.0-4 for Proof Of Concept and Education purposes.

This tool was built and tested by the team of :

* Shadd Gallegos of Red Hat 

**DISCLAIMER**
----------------------------------------------

*DO NOT RUN THIS SCRIPT ON YOUR PRODUCTION SYSTEM. THIS IS FOR ONLY NEWLY BUILT OR TEST SYSTEM YOU CAN RE-PROVISION!*

*THIS SCRIPT IS NOT SUPPORTED AND THERE IS NO IMPLIED WARRANTY - USE AT OWN RISK!*

----------------------------------------------

## SYSTEM REQUIREMENTS

**System Resources**

I can set up a full satellite for a P.O.C in 3 to 4 hours with:

* 8 CPU
* 22 GB ram 
* 300 GB storage
* 2 Ethernet
    * eth0 internal - provisioning node communication
    * eth1 external - connection to Red Hat CDN

**OS:**
* RHEL 7.6^

**Provides:** 

* tftp
* dhcp
* dns
* red hat insights
* ansible 
* puppet
      
**NOTE:** *You can stop/disable any service you don't want after the install.*

**Running REDHATTOOLSINSTALLER-XXXsh:** 

![REDHATTOOLSINSTALLER-6.7](./PNG/REDHATTOOLSINSTALLER-6.7.png)

* git clone https://github.com/ShaddGallegos/RedHatToolsInstaller.git
* cd RedHatToolsInstaller
* sh REDHATTOOLSINSTALLER-XXX.sh
* Follow prompts to completion 

## Why this installer

I believe all products should have an "installer" that guides end users to success. 

What this does is:

* reduces TtP (Time to Productivity)
* reduction in deployment cost
* reduction in support costs
* increase in margin
* easy to reproduce 
* easy to deploy 
      
Setting up satellite 6.x can be quite difficult, between the documentation and the speed at which the product developed can make it trick to deploy and adopt. I want to make it easier 

This works in a graphical or headless environment to help you install red hat satellite 6.4 and the latest ansible tower.

The script does use the epel to install components needed to run the script and i have provided the xdialog rpm if you want it to run the cool dialog box.

## Who is this script for?

* Anyone who wants to set up a proof of concept Satellite or Ansible Tower on a RHEL7 system or and admin that wants to deploy satellite quickly
* Anyone that wants to make the Red Hat experience an even better one 


  
