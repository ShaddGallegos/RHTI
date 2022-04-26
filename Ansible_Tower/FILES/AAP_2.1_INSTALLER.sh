#!/bin/bash
# This installer will work on RHEL 7 or RHEL 8 and:
#1.verify you are root 
#2.Check you are connected to the internet.
#3.Provide a breif overview of what the tool is.
#4.Help the end user register with Red Hat if not already done.
#5.Take of some prep stuff install shut off firewall and selinux and install pip prior to install.
#6.Enable required repos for OS and Ansible Controller.
#7.Upgrades the OS.
#8.Installs the dependencies from the bundle forces them to requirement levels listed in bundle.
#9.Installs Tower. (Queries user for tower password) 
#10. Gives the end user the option to enable firewall and selinux.

echo -ne "\e[8;45;120t"
reset
if [ "$(whoami)" != "root" ]
then
echo "This script must be run as root - if you do not have the credentials please contact your administrator"
exit
else
echo '
                                Ansible Controller 2.1 INSTALLER FOR RHEL 7.x AND RHEL 8.x
                              FOR SETTING UP A SIMPLE SINGLE NODE CONFIGURATION FOR P.O.C.'
read -p 

"                             To Continue Press [Enter] or use Ctrl+c to exit the installer"

#-------------------------
function ANSIBLETOWERTXT {
#-------------------------
reset
HNAME=$(hostname)
echo " "
echo " "
echo " "
echo "
                                            Ansible Controller BASE HARDWARE REQUIREMENTS

                        1. Ansible Automation Platform will require a RHEL subscription and an Ansible Controller License.
                           Please register and download your lincense at:
                           https://access.redhat.com/downloads/content/480/ver=2.1/rhel---8/2.1/x86_64/product-software

                        2. Hardware requirement depends, however whether 
                           it is a KVM or physical-Controller will require atleast 1 node with:
                                    
                                  Storage 35GB
                                  Directorys recommended for a P.O.C.
                                       / 
                                       /boot
                                       /swap
                                  Connection to the internet so the installer can download the required packages
                                      eth0 internal (Provisioning network)
                                      eth1 external
                                  4 CPU
                                  8192 RAM"
echo " "
echo " "
echo " "
read -p "Press [Enter] to continue"
reset
echo " "
echo " "

echo "

                                                      REQUIREMENTS CONTINUED

                        4. For this POC you must have a RHN User ID and password with entitlements
                           to channels below. (item 6)

                        5. Install ansible tgz will be downloaded and placed into the FILES directory 
                           created by the sript on the host machine:

                        6.* RHEL_8.x in a KVM environment.
                          * Ansible Controller 2.1 https://releases.ansible.com/Ansible Controller/setup-bundle/Ansible Controller-setup-bundle-latest.el8.tar.gz (will auto download)
                          * Red Hat subscriber channels:
                                ansible-automation-platform-2.1-for-rhel-8-x86_64-rpms
                                rhel-8-for-x86_64-appstream-rpms
                                rhel-8-for-x86_64-baseos-rpms
                                rhel-8-for-x86_64-supplementary-rpms
                                rhel-8-for-x86_64-optional-rpms
                                https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

        URL Resources 
            http://www.ansible.com
            https://www.redhat.com/en/technologies/management/ansible/try-it/success
            https://access.redhat.com/documentation/en-us/red_hat_ansible_automation_platform/2.1
echo " "
echo " "
read -p "        If you have met all of the minimum requirements from above please Press [Enter] to continue"
echo " "
reset
}

#-----------------------------
function ANSIBLECHECKCONNECT {
#-----------------------------
echo " "
echo " "
echo "********************************************"
echo "Verifying the server can get to the internet"
echo "********************************************"
wget -q --tries=10 --timeout=20 --spider http://redhat.com
if [[ $? -eq 0 ]]; then
echo "Online: Continuing to Install"
if [[ -f "~/Downloads/ansible-automation-platform-setup-bundle-2.1.0-1.tar.gz.tar.gz" ]]
echo "Tar available ''~/Downloads/ansible-automation-platform-setup-bundle-2.1.0-1.tar.gz.tar.gz'' continuing... "
sleep 2
else
echo "Offline"
echo "This script requires access to 
 the network to run please fix your settings and try again"
sleep 2
exit 1
echo " "
echo " "
fi
fi
}

#-------------------------
function ANSIBLEREGISTER {
#-------------------------
echo "****************************"
echo "Registering system if needed"
echo "****************************"
subscription-manager status | awk -F ':' '{print $2}'|grep Current > /dev/null
status=$?
if test $status -eq 1
then
echo "System is not registered, Please provide Red Hat CDN username and password when prompted"
subscription-manager register --auto-attach
else
subscription-manager attach --pool=$(subscription-manager list --available --matches "Red Hat Ansible Automation Platform" |grep "Pool ID:"  |awk -F ':             ' '{print $2}')

echo "System is registered with Red Hat or Red Hat Satellite, Continuing!"
sleep 2 
fi
echo " "
echo " "
}

#-------------------------------
function ANSIBLESECURITY {
#-------------------------------
mkdir ~/Downloads
cd ~/Downloads
echo "***************************************************************************"
echo "SET SELINUX TO PERMISSIVE FOR THE INSTALL AND CONFIG OF Ansible Controller 2.1"
echo "***************************************************************************"
sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
setenforce 0
service firewalld stop
echo " "
echo " "
}

#-------------------------------
function YOURUSER {
#-------------------------------
echo "*********************************************************"
echo "Setting up your user on the system if needed"
echo "*********************************************************"
echo " "
YMESSAGE="Adding your user"
NMESSAGE="Skipping"
FMESSAGE="PLEASE ENTER Y or N"
COUNTDOWN=15
DEFAULTVALUE=n
echo " "
read -n1 -p "Do you need to ad your user to the system Y/N " 
INPUT=${INPUT:-$DEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
echo " "
echo "Enter your username: "
read USERNAME
echo " "
echo "Enter the password: "
read PASSWORD
echo " "
adduser "$USERNAME" --group wheel
echo "$PASSWORD" | passwd "$USERNAME" --stdin
echo " "
sudo -u "$USERNAME" ssh-keygen -f /home/"$USERNAME"/.ssh/id_rsa -t rsa -N ''
chown -R "$USERNAME":"$USERNAME" /usr/share/"$USERNAME"
mkdir -p /home/"$USERNAME"/git
chown -R "$USERNAME":"$USERNAME" /home/admin
echo " "
echo " "
fi
}

#-------------------------------
function ADMINUSERS {
#-------------------------------
echo " "
echo "*********************************************************"
echo "SETTING UP ADMIN"
echo "*********************************************************"
echo " "
echo 'What would you like your default Ansible Controller user "admin" password to be?'
read ADMINPASSWORD
export $ADMINPASSWORD
groupadd admin
useradd admin --group admin wheel -p $ADMINPASSWORD
mkdir -p ~/.ssh
mkdir -p ~/git
chown -R admin:admin /home/admin
sudo -u admin ssh-keygen -f ~/.ssh/id_rsa -N ''
echo " "
echo "***********************************************************************"
echo "SETTING UP ROOT KEYS (Please select NO if it prompts you to overwrite "
echo "***********************************************************************"
ssh-keygen -f /root/.ssh/id_rsa -t rsa -N ''
echo " "
echo " "
}

#----------------------------
function ANSIBLESYSTEMREPOS {
#----------------------------
grep -q -i "release 7." /etc/redhat-release
status=$?
if test $status -eq 0
then
echo " Ansible Automaton Platform requires RHEL 8.3^ please install and try again."
elif test $status -eq 1
then
echo '*******************'
echo 'ENABLE REPOS RHEL 8' 
echo '*******************'
subscription-manager repos --disable '*'
subscription-manager repos --enable ansible-automation-platform-2.1-for-rhel-8-x86_64-rpms --enable rhel-8-for-x86_64-appstream-rpms --enable rhel-8-for-x86_64-baseos-rpms --enable rhel-8-for-x86_64-supplementary-rpms 
yum -q list installed epel &>/dev/null && echo "epel is installed" || yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm --skip-broken
yum -q list installed dnf &>/dev/null && echo "dnf is installed" || yum install -y dnf --skip-broken --noplugins
yum -q list installed yum-utils &>/dev/null && echo "yum-utils is installed" || dnf install -y yum-utils --skip-broken --noplugins
dnf config-manager --add-repo https://releases.ansible.com/Ansible Controller/cli/Ansible Controller-cli-el8.repo
yum-config-manager --setopt=\*.skip_if_unavailable=1 --save \*
dnf clean all
rm -rf /var/cache/dnf
echo " "
echo " "
sleep 2
echo "********************************"
echo "CHECKING AND INSTALLING PACKAGES"
echo "********************************"
yum-config-manager --enable epel 
yum clean all 
rm -rf /var/cache/yum
yum -q list installed automation-controller-cli &>/dev/null && echo "automation-controller-cli is installed" || dnf install -y automation-controller-cli --skip-broken --noplugins 
yum -q list installed wget &>/dev/null && echo "wget is installed" || dnf install -y wget --skip-broken --noplugins --best --allowerasing
yum -q list installed python3-pip &>/dev/null && echo "python3-pip is installed" || dnf install -y python3-pip --skip-broken --noplugins --best --allowerasing
yum -q list installed platform-python-pip &>/dev/null && echo "platform-python-pip is installed" || dnf install -y platform-python-pip --skip-broken --noplugins --best --allowerasing
yum -q list installed dconf &>/dev/null && echo "dconf" || dnf install -y dconf* --skip-broken --noplugins --best --allowerasing
yum -q list installed dnf-utils &>/dev/null && echo "dnf-utils is installed" || dnf install -y dnf-utils --skip-broken --noplugins --best --allowerasing
yum -q list installed git &>/dev/null && echo "git is installed" || dnf install -y git --skip-broken --noplugins --best --allowerasing
yum -q list installed screen &>/dev/null && echo "screen is installed" || dnf install -y screen --skip-broken
mkdir -p ~/Downloads/git 
cd ~/Downloads
yum-config-manager --disable epel
echo " "
echo " "
sleep 2
fi
}

#-----------------------------
function ANSIBLELINUXUPGRADE {
#-----------------------------
echo "*******************"
echo "Upgrade RHEL8 "
echo "*******************"
dnf upgrade -y --skip-broken --best --allowerasing 
echo " "
echo " "
}

#---------------------------
function CloudRequirements {
#---------------------------
echo '*********************************************'
echo 'Installing Cloud Requirements (Ignore Errors)'
echo '*********************************************'
dnf install -y python3-pip ansible ansible-doc --skip-broken --best --allowerasing 
source /var/lib/awx/venv/ansible/bin/activate
umask "0022"
 sudo -u  awx pip3 install --user --upgrade pip boto3 boto botocore requests requests-credssp cryptography pywinrm PyVmomi azure-mgmt-compute azure-mgmt-resource azure-keyvault-secrets six netaddr passlib
deactivate
}

#-----------------------------
function ANSIBLEINSTALLCONTROLLER {
#-----------------------------
echo " "
echo '****************************************************************'
echo 'Getting, Expanding, and installing Ansible Controller 2.1 for RHEL8'
echo '****************************************************************'
mkdir ~/Downloads
cd ~/Downloads
wget https://releases.ansible.com/Ansible Controller/setup-bundle/ansible-automation-platform-setup-bundle-2.1.0-1.tar.gz.tar.gz

tar -zxvf ~/Downloads/ansible-automation-platform-setup-bundle-2.1.0-1.tar.gz.tar.gz 
cd ~/Downloads/ansible-automation-platform-setup-bundle-2.1.0-1 
sleep 2
echo " "
echo " "

echo 'What would you like your default Ansible Controller user "admin" password to be?'
read ADMINPASSWORD
export $ADMINPASSWORD
sed -i 's/admin_password='"''"'/admin_password='"'"$ADMINPASSWORD"'"'/g' ~/Downloads/ansible-automation-platform-setup-bundle-2.1.0-1/inventory  
sed -i 's/pg_password='"''"'/pg_password='"'"$ADMINPASSWORD"'"'/g' ~/Downloads/ansible-automation-platform-setup-bundle-2.1.0-1/inventory 
sed -i 's/automationhub_admin_password='"''"'/automationhub_admin_password='"'"$ADMINPASSWORD"'"'/g' ~/Downloads/ansible-automation-platform-setup-bundle-2.1.0-1/inventory 
sed -i 's/automationhub_pg_password='"''"'/automationhub_pg_password='"'"$ADMINPASSWORD"'"'/g' ~/Downloads/ansible-automation-platform-setup-bundle-2.1.0-1/inventory 

echo " "
echo " "
cd ~/Downloads/ansible-automation-platform-setup-bundle-2.1.0-1 /
sh setup.sh
sleep 5
echo " "
echo " "
}

ANSIBLETOWERTXT
ANSIBLECHECKCONNECT
ANSIBLEREGISTER
ANSIBLESECURITY
ANSIBLESYSTEMREPOS
ANSIBLELINUXUPGRADE
ANSIBLEINSTALLCONTROLLER
fi
