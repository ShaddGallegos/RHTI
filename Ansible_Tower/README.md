The content below is open source, is OPC (Other Peoples Code) in a lot of cases and is provided " no warranty implied or otherwise ".  Use it as reference only.  If you have questions please ping me at shadd.gallegos@gmail.com 

# ANSIBLE-TOWER INSTALLER FOR RHEL 7.x AND RHEL 8.x FOR SETTING UP A SIMPLE SINGLE NODE CONFIGURATION FOR P.O.C.

## ANSIBLE-TOWER BASE HARDWARE REQUIREMENTS

   1. Ansible-Tower will require a RHEL subscription and an Ansible Tower License.
      Please register and download your lincense at http://www.ansible.com/tower-trial

   2. Hardware requirement depends, however whether it is a KVM or physical-Tower 
      will require atleast 1 node with:

          Min Storage 35GB
          Directorys Recommended
             /boot 1024MB
             /swap 8192MB
             / Rest of drive

          Min RAM 4096
          Min CPU 2 (4 Reccomended)

   3. Network Connection to the internet so the installer can download the required packages

          eth0 internal Provisioning network
          eth1 external"

   4. The ANSIBLE_TOWER-x-INSTALLER installer will work on RHEL 7 or RHEL 8 and:

          * verify you are root 
          * Check you are connected to the internet.
          * Provide a breif overview of what the tool is.
          * Help the end user register with Red Hat if not already done.
          * Take of some prep stuff install shut off firewall and selinux and install pip prior to install.
          * Enable required repos for OS and Ansible Tower.
          * Upgrades the OS.
          * Installs the dependencies from the bundle forces them to requirement levels listed in bundle.
          * Installs Tower. (Queries user for tower password) 
          * Gives the end user the option to enable firewall and selinux.

   5. The other items in this repo are Educational tools 

           Ansible_Cheat_Sheets
           Ansible_DOC
           Ansible_PDF
           Ansible_PPT
           Ansible_USECASES
           Ansible_Video_Demos
           Playbook_Examples


