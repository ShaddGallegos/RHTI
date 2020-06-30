#!/bin/bash
#POC/Demo
#This Script is for setting up a basic Satellite 6.7 on RHEL 7 or Ansible Tower 6.3.1 on RHEL 7

echo -ne "\e[8;40;170t"

# Hammer referance to assist in modifing the script can be found at 
# https://www.gitbook.com/book/abradshaw/getting-started-with-satellite-6-command-line/details

#-------------------------
function CHECKONLINE {
#-------------------------
reset
echo 'REDHAT TOOLS INSTALLER – FOR RHEL 7.X AND RHEL 8.X'
wget -q --tries=10 --timeout=20 --spider http://redhat.com
if [[ $? -eq 0 ]]; then
echo "Online: Continuing to Install"
else
echo "Offline"
echo "This script requires access to the network to run please fix your settings and try again"
sleep 3
exit 1
fi
sleep 1 
reset
if [ "$(whoami)" != "root" ]
then
echo "This script must be run as root - if you do not have the credentials please contact your administrator"
exit
else
echo ' '
echo ' '

echo '

                                                   REDHAT TOOLS INSTALLER
             FOR RHEL 7.X FOR SETTING UP SINGLE NODE CONFIGURATIONS OF RED HAT MANAGEMENT PORTFOLIO APPLICATIONS FOR P.O.C.'
echo ''
read -p "To Continue Press [Enter] or use Ctrl+c to exit the installer"
fi
sleep 3 
reset
}
CHECKONLINE

#--------------------------required packages for script to run----------------------------
#-------------------------
function SETUPHOSTFILE {
#-------------------------
HNAME=$(hostname)
SHNAME=$(hostname -s)
DOM="$(hostname -d)"
mkdir -p RHTI
mkdir /run/user/1000/dconf/ &>/dev/null
touch /run/user/1000/dconf/user &>/dev/null
chmod 777 /run/user/1000/dconf/user &>/dev/null
chmod -R 777 RHTI &>/dev/null
chown -R nobody:nobody RHTI &>/dev/null
echo ''
cp -p /root/.bashrc /root/.bashrc.bak
export INTERNAL=$(ip -o link | head -n 2 | tail -n 1 | awk '{print $2}' | sed s/:// )
export EXTERNAL=$(ip route show | sed -e 's/^default via [0-9.]* dev \(\w\+\).*/\1/' | head -1)
export INTERNALIP=$(ifconfig "$INTERNAL" | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."$3"."$4}')
export INTERNALSUBMASK=$(ifconfig "$INTERNAL" |grep netmask |awk -F " " {'print $4'})
export INTERNALGATEWAY=$(ip route list type unicast dev $(ip -o link | head -n 2 | tail -n 1 | awk '{print $2;}' | sed s/:$//) |awk -F " " '{print $7}')
echo "INTERNALIP=$INTERNALIP" >> /root/.bashrc
echo ''$INTERNALIP' '$HNAME' '$SHNAME'' >> /etc/hosts
echo ' '
echo ' '
echo '********************************************************'
echo 'ENSURE INTERNAL/PROVISIONING (eth0/ens3) GW CONNICTIVITY'
echo '********************************************************'
echo ' '
echo 'what is the IP of your eth0 GATEWAY ?'
read GWFQDN
echo 'what is the FQDN of your eth0 GATEWAY ?'
read GWINIP
echo ''$GWINIP'  '$GWFQDN'' >> /etc/hosts
ping -c 5 $GWINIP |exit 1
sudo touch RHTI/SETUPHOSTFILE
}

ls RHTI/SETUPHOSTFILE &>/dev/null
if [ $? -eq 0 ]; then
echo '/etc/host has already been run Skipping'
sleep 1
else
echo "Setting up /etc/hostfile to include this '$(hostname)' and the GW for your internal provisioning (eth0/ens3)  interface"
SETUPHOSTFILE
sleep 1
echo " "
fi

#-------------------------
function DISABLESECURITY {
#-------------------------
HNAME=$(hostname)
DOM="$(hostname -d)"
echo "************************************************************"
echo "Installing Script configuration requirements for this server"
echo "************************************************************"
echo "*****************************************************************"
echo "SET SELINUX TO PERMISSIVE AND DISABLING FIREWALL 
 FOR THE INSTALL AND CONFIG, You will have the option 
 to reenable once the system completes "
echo "*****************************************************************"
sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
setenforce 0
service firewalld stop
chkconfig firewalld off
sleep 5
echo " "
echo " "
}
DISABLESECURITY

#---------------------
function SYSREGISTER {
#---------------------
echo "*********************************************************"
echo "REGESTERING RHEL SYSTEM"
echo "*********************************************************"
echo "***********************************"
echo "Registering RHEL 7 system if needed"
echo "***********************************"
subscription-manager status | awk -F ':' '{print $2}'|grep Current > /dev/null
status=$?
if test $status -eq 1
then
echo "System is not registered, Please provide Red Hat CDN username and password when prompted"
subscription-manager register --auto-attach
else
echo "System is registered with Red Hat or a Red Hat Satellite, Continuing!"
sleep 1 
fi
echo " "
echo " "
}
SYSREGISTER

#---------------------
function SYSREPOS {
#---------------------
echo " "
echo "*********************************************************"
echo "SET REPOS ENABLING SCRIPT TO RUN"
echo "*********************************************************"
echo "*********************************************************"
echo "FIRST DISABLE REPOS"
echo "*********************************************************"
subscription-manager repos --disable '*'
echo " "
echo " "
echo "*********************************************************"
echo "ENABLE PROPER REPOS"
echo "*********************************************************"
subscription-manager repos --enable=rhel-7-server-rpms || exit 1
subscription-manager repos --enable=rhel-7-server-extras-rpms || exit 1
subscription-manager repos --enable=rhel-7-server-optional-rpms || exit 1
subscription-manager repos --enable=rhel-7-server-rpms || exit 1
echo " "
echo " "
echo " "
echo "*********************************************************"
echo "ENABLE EPEL FOR A FEW PACKAGES"
echo "*********************************************************"
yum -q list installed epel-release-latest-7 &>/dev/null && echo "epel-release-latest-7 is installed" || yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm --skip-broken
yum-config-manager --enable epel || exit 1
subscription-manager repos --enable=rhel-7-server-extras-rpms || exit 1
yum-config-manager --save --setopt=*.skip_if_unavailable=true
yum clean all
rm -fr /var/cache/yum/*
sudo touch RHTI/SYSREPOS
echo " "
echo " "
}

ls RHTI/SYSREPOS &>/dev/null
if [ $? -eq 0 ]; then
echo 'Repos Enabled'
else
echo ' Enabling Repos'
SYSREPOS
fi

#-----------------------------
function INSTALLERPACKAGES {
#---------------------------
echo " "
echo "*********************************************************"
echo "INSTALLING PACKAGES ENABLING SCRIPT TO RUN"
echo "*********************************************************"
yum-config-manager --enable epel
yum -q list installed yum-utils &>/dev/null && echo "yum-utils is installed" || yum install -y yum-util* --skip-broken
yum -q list installed wget &>/dev/null && echo "wget is installed" || yum install -y wget --skip-broken
wget https://github.com/ShaddGallegos/RedHatToolsInstaller/raw/master/xdialog-2.3.1-13.el7.centos.x86_64.rpm
chmod 777 /home/admin/Downloads/xdialog-2.3.1-13.el7.centos.x86_64.rpm 
yum -q list installed xdialog &>/dev/null && echo "xdialog is installed" || yum localinstall -y xdialog-2.3.1-13.el7.centos.x86_64.rpm –skip-broken
yum -q list installed ansible &>/dev/null && echo "ansible is installed" || yum install -y ansible --skip-broken 
yum -q list installed dconf-devel &>/dev/null && echo "dconf-devel is installed" || yum install -y dconf-devel dconf --skip-broken
yum -q list installed deltarpm &>/dev/null && echo "deltarpm is installed" || yum install -y deltarpm --skip-broken
yum -q list installed dialog &>/dev/null && echo "dialog is installed" || yum install -y dialog --skip-broken
yum -q list installed firefox &>/dev/null && echo "firefox is installed" || yum install -y firefox --skip-broken
yum -q list installed firewalld &>/dev/null && echo "firewalld is installed" || yum install -y firewalld --skip-broken
yum -q list installed gnome-terminal &>/dev/null && echo "gnome-terminal is installed" || yum install -y gnome-terminal --skip-broken
yum -q list installed gtk2-devel &>/dev/null && echo "gtk2-devel is installed" || yum install -y gtk2-devel --skip-broken
yum -q list installed hiera &>/dev/null && echo "hiera is installed" || yum install -y hiera --skip-broken
yum -q list installed perl &>/dev/null && echo "perl is installed" || yum install -y perl --skip-broken
yum -q list installed python-deltarpm &>/dev/null && echo "python-deltarpm is installed" || yum install -y python-deltarpm --skip-broken
yum -q list installed ruby &>/dev/null && echo "ruby is installed" || yum install -y ruby --skip-broken
yum -q list installed diskimage-builder &>/dev/null && echo "diskimage-builder is installed" || yum install -y diskimage-builder --skip-broken
yum -q list installed dracut &>/dev/null && echo "dracut is installed" || yum install -y dracut --skip-broken
yum -q list installed ntfs-3g &>/dev/null && echo "ntfs-3g is installed" || yum install -y ntfs-3g --skip-broken
yum -q list installed cifs &>/dev/null && echo "cifs is installed" || yum install -y cifs --skip-broken
yum -q list installed cifs-utils &>/dev/null && echo "cifs-utils is installed" || yum install -y cifs-utils --skip-broken
yum-config-manager --disable epel
subscription-manager repos --disable=rhel-7-server-extras-rpms
mkdir -p /run/user/1000/dconf
sudo touch /run/user/1000/dconf/user
sudo touch RHTI/INSTALLERPACKAGES
echo " "
echo " "
}

ls RHTI/INSTALLERPACKAGES &>/dev/null
if [ $? -eq 0 ]; then
echo 'The requirements to run this script have been met, proceeding'
sleep 1
else
echo "Installing requirements to run script please stand by"
INSTALLERPACKAGES
sleep 1
echo " "
fi

#-------------------------------
function SERVICEUSER {
#-------------------------------
echo "*********************************************************"
echo "ADMIN PASSWORD - WRITE DOWN OR REMEMBER THIS YOU WILL BE PROMPTED FOR 
FORMAN USER CREDINTIALS: admin AND THIS PASSWORD WHEN WE IMPORT THE MANIFEST
OR WHEN YOU LOGIN TO SATELLITE OR TOWER, YOU CAN CHANGE THIS INFORMATION 
AFTER YOU LOG IN TO WHICHEVER SYSTEM YOU CREATE"
echo "*********************************************************"
echo 'ADMIN=admin'  >> /root/.bashrc
echo 'What will the password be for your admin user?'
read  ADMIN_PASSWORD
echo 'ADMIN_PASSWORD='$ADMIN_PASSWORD'' >> /root/.bashrc
export $ADMIN_PASSWORD
echo "*********************************************************"
echo "SETTING UP ADMIN"
echo "*********************************************************"
source /root/.bashrc
useradd admin
sleep 5
usermod admin -p "$ADMIN_PASSWORD"
usermod admin -G wheel
mkdir -p /home/admin/git
mkdir -p /home/admin/.ssh
chown -R admin:admin /home/admin
sudo -u admin ssh-keygen -f /home/admin/.ssh/id_rsa -N ''
echo 'admin ALL = NOPASSWD: ALL' >> /etc/sudoers
sleep 10 
echo " "
touch RHTI/SERVICEUSER
}

ls RHTI/SERVICEUSER &>/dev/null
if [ $? -eq 0 ]; then
echo 'The requirements to run this script have been met, proceeding'
sleep 1
else
echo "Installing service account please stand by"
SERVICEUSER
sleep 1
echo " "
fi

#--------------------------Define Env----------------------------

#configures dialog command for proper environment

if [[ -n $DISPLAY ]]
then
# Assume script running under X:windows
DIALOG=`which Xdialog`
RC=$?
if [[ $RC != 0 ]]
then
DIALOG=`which dialog`
RC=$?
if [[ $RC != 0 ]]
then
echo "Error:: Could not locate suitable dialog command: Please install dialog or if running in a desktop install Xdialog."
exit 1
fi
fi
else
# If Display is not set assume ok to use dialog
DIALOG=`which dialog`
RC=$?
if [[ $RC != 0 ]]
then
echo "Error:: Could not locate suitable dialog command: Please install dialog or if running in a desktop install Xdialog."
exit 1
fi
fi
#-----------------------------------------------------SCRIPT BEGINS-----------------------------------------------------
#------------------------------------------------------ Functions ------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
#-------------------------------
function SATELLITEREQUIREMENTS {
#-------------------------------
echo "************************************************************************************************************************************"
echo "
                                              **************************
                                              SATELLITE 6.7 REQUIREMENTS
                                              **************************
                                    Hardware Requirements
                                        22GB Ram
                                        300 GB Storage
                                        8 CPU

                                    Official Storage Requirements https://url.corp.redhat.com/SAT-6-7-Storage-Requirements
                                    Filesystems Required for this script to run
                                        /              Rest of Drive
                                        /boot          1024 MB
                                        /swap          18 GB

                                    2 etthernet ports
                                        eth0 internal for provisioning
                                        eth1 external for syncing to cdn

                                    The Server
                                        Basic system or System with GUI

           A user "admin" (I usualy set up an admin user during my initial install)
                  useradd admin (Script will add this user for you if you dont do it already)

           Your manifest from https://access.redhat.com/management/subscription_allocations

           A /home/admin/Downloads directory (should be there by default if you have already created the user)

           Copy this script, the attached xdialog rpm and your manifest into /home/admin/Downloads/

           To run it
           change to root user
           sudo su

           cd into the admin downloads dir
           cd /home/admin/Downloads

           Run the script
           sh REDHATTOOLSINSTALLER-6.7.sh"
echo " "
echo "************************************************************************************************************************************"
read -p "Press [Enter] to continue"
reset
}

#-------------------------
function SATELLITEREADME {
#-------------------------
echo " "
echo " "
echo " "
echo " "
echo "************************************************************************************************************************************"
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo "

                                              P.O.C Satellite 6.7 ONLY, RHEL 7.X KVM, or RHEL 7 Physical Host 
                                                   THIS SCRIPT CONTAINS NO CONFIDENTIAL INFORMATION

                                           This script is designed to set up a basic standalone Satellite 6.X system

                                    Disclaimer: This script was written for education, evaluation, and/or testing purposes. 
                    This helper script is Licensed under GPL and there is no implied warranty and is not officially supported by anyone.
 
                                ...SHOULD NOT BE USED ON A CURRENTlY OPERATING PRODUCTION SYSTEM - USE AT YOUR OWN RISK...


                    However the if you have an issue with the products installed and have a valid subscription please contact Red Hat at:

                          RED HAT Inc..
                          1-888-REDHAT-1 or 1-919-754-3700, then select the Menu Prompt for Customer Service
                          Spanish: 1-888-REDHAT-1 Option 5 or 1-919-754-3700 Option 5
                          Fax: 919-754-3701 (General Corporate Fax)
                          Email address: customerservice@redhat.com "

echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo "************************************************************************************************************************************"
read -p "Press [Enter] to continue"
reset
if [ "$(whoami)" != "root" ]
then
echo "This script must be run as root - if you do not have the credentials please contact your administrator"
exit
fi
}

#---------------------
function SATREGISTER {
#---------------------
echo "*********************************************************"
echo "REGESTERING RHEL SYSTEM"
echo "*********************************************************"
echo "***********************************"
echo "Registering RHEL 7 system if needed"
echo "***********************************"
subscription-manager status | awk -F ':' '{print $2}'|grep Current > /dev/null
status=$?
if test $status -eq 1
then
echo "*********************************************************"
echo "System is not registered, Please provide Red Hat CDN 
 username and password when prompted"
echo "*********************************************************"
echo ' '
subscription-manager register
sleep 5
echo ' '
echo "*******************************************************************"
echo 'Verifying that the system is attached to a Satellite Subscription'
echo "*******************************************************************"
echo ' '
subscription-manager attach --pool=`subscription-manager list --available --matches 'Red Hat Satellite Infrastructure Subscription' --pool-only`  || exit 1
sleep 5
echo ' '
else
echo "*******************************************************************"
echo "System is registered with Red Hat or Red Hat Satellite, Continuing!"
echo "*******************************************************************"
echo ' '
echo "*******************************************************************"
echo 'Verifying that the system is attached to a Satellite Subscription'
echo "*******************************************************************"
echo 'If you do not have a Satellite sub this step will fail and it will boot you from the installer'
subscription-manager attach --pool=`subscription-manager list --available --matches 'Red Hat Satellite Infrastructure Subscription' --pool-only`  || exit 1
sleep 2
fi
echo " "
echo " "
sudo touch RHTI/SATREGISTER
}

#-------------------------------
function VARIABLES1 {
#-------------------------------
reset 
YMESSAGE="Adding to /root/.bashrc vars"
NMESSAGE="Skipping"
FMESSAGE="PLEASE ENTER Y or N"
COUNTDOWN=10
DEFAULTVALUE=n
HNAME=$(hostname)
SHNAME=$(hostname -s)
DOM="$(hostname -d)"
echo "*********************************************************"
echo "COLLECT VARIABLES FOR SAT 6.X"
echo "*********************************************************"
cp -p /root/.bashrc /root/.bashrc.bak
export INTERNAL=$(ip -o link | head -n 2 | tail -n 1 | awk '{print $2}' | sed s/:// )
export EXTERNAL=$(ip route show | sed -e 's/^default via [0-9.]* dev \(\w\+\).*/\1/' | head -1)
export INTERNALIP=$(ifconfig "$INTERNAL" | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."$3"."$4}')
export INTERNALSUBMASK=$(ifconfig "$INTERNAL" |grep netmask |awk -F " " {'print $4'})
export INTERNALGATEWAY=$(ip route list type unicast dev $(ip -o link | head -n 2 | tail -n 1 | awk '{print $2;}' | sed s/:$//) |awk -F " " '{print $7}')
echo " "
echo "*********************************************************"
echo "ORGANIZATION"
echo "*********************************************************"
echo 'What is the name of your Organization?'
read ORG
echo 'ORG='$ORG'' >> /root/.bashrc
echo " "
echo " "
echo "*********************************************************"
echo "LOCATION OF YOUR SATELLITE"
echo "*********************************************************"
echo 'What is the location of your Satellite server. Example DENVER'
read LOC
echo 'LOC='$LOC'' >> /root/.bashrc
echo " "
echo " "
echo "*********************************************************"
echo "SETTING DOMAIN"
echo "*********************************************************"
echo 'what is your domain name Example:'$(hostname -d)''
read DOM
echo 'DOM='$DOM'' >> /root/.bashrc
echo " "
echo " "

echo " "
echo " "
echo "*********************************************************"
echo "NAME OF FIRST SUBNET"
echo "*********************************************************"
echo 'What would you like to call your first subnet for systems you are regestering to satellite?'
read  SUBNET
echo 'SUBNET_NAME='$SUBNET'' >> /root/.bashrc
echo " "
echo " "
echo "*********************************************************"
echo "PROVISIONED NODE PREFIX"
echo "*********************************************************"
# The host prefix is used to distinguish the demo hosts created at the end of this script.
echo 'What would you like the prefix to be for systems you are provisioning with Satellite Example poc- kvm- vm-? enter to skip'
read  PREFIX
echo 'HOST_PREFIX='$PREFIX'' >> /root/.bashrc
echo " "
echo " "
echo "*********************************************************"
echo "NODE PASSWORD"
echo "*********************************************************"
echo 'PROVISIONED HOST PASSWORD'
echo 'Please enter the default password you would like to use for root for your newly provisioned nodes'
read PASSWORD
for i in $(echo "$PASSWORD" | openssl passwd -apr1 -stdin); do echo NODEPASS=$i >> /root/.bashrc ; done
echo " "
echo " "
echo "*********************************************************"
echo "GATHERING VARIABLES SPECIFIC TO THIS SYSTEM, NO INPUT REQUIRED"
echo "*********************************************************"
export "DHCPSTART=$(ifconfig $INTERNAL | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."$3"."2}')"
export "DHCPEND=$(ifconfig $INTERNAL | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."$3"."254}')"
echo "*********************************************************"
echo "FINDING NETWORK"
echo "*********************************************************"
echo 'INTERNALNETWORK='$(ifconfig "$INTERNAL" | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."0"."0}')'' >> /root/.bashrc
echo "*********************************************************"
echo "FINDING SAT INTERFACE"
echo "*********************************************************"
echo 'SAT_INTERFACE='$(ip -o link | head -n 2 | tail -n 1 | awk '{print $2;}' | sed s/:$//)'' >> /root/.bashrc
echo "*********************************************************"
echo "FINDING SAT IP"
echo "*********************************************************"
echo 'SAT_IP='$(ifconfig "$INTERNAL" | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."$3"."$4}')'' >> /root/.bashrc
echo "*********************************************************"
echo "*********************************************************"
echo "SETTING RELM"
echo "*********************************************************"
echo 'REALM='$(hostname -d)'' >> /root/.bashrc
echo "*********************************************************"
echo "SETTING DNS"
echo "*********************************************************"
echo 'DNS='$(ip route list type unicast dev $(ip -o link | head -n 2 | tail -n 1 | awk '{print $2;}' | sed s/:$//) |awk -F " " '{print $7}')'' >> /root/.bashrc
echo 'DNS_REV='$(ifconfig $INTERNAL | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $3"."$2"."$1".""in-addr.arpa"}')'' >> /root/.bashrc
echo "*********************************************************"
echo "DNS PTR RECORD"
echo "*********************************************************"
'PTR='$(ifconfig "$INTERNAL" | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $4}')''  >> /root/.bashrc
echo "*********************************************************"
echo "SETTING SUBNET VARS"
echo "*********************************************************"
echo 'SUBNET='$(ifconfig $INTERNAL | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."0"."0}')'' >> /root/.bashrc
echo 'SUBNET_MASK='$(ifconfig $INTERNAL |grep netmask |awk -F " " {'print $4'})'' >> /root/.bashrc
echo "*********************************************************"
echo "SETTING BGIN AND END IPAM RANGE"
echo "*********************************************************"
echo 'SETTING BEGIN AND END IPAM RANGE'
echo 'SUBNET_IPAM_BEGIN='$DHCPSTART'' >> /root/.bashrc
echo 'SUBNET_IPAM_END='$DHCPEND'' >> /root/.bashrc
echo "*********************************************************"
echo "DHCP"
echo "*********************************************************"
echo 'DHCP_RANGE=''"'$DHCPSTART' '$DHCPEND'"''' >> /root/.bashrc
echo 'DHCP_GW='$(ip route list type unicast dev $(ip -o link | head -n 2 | tail -n 1 | awk '{print $2;}' | sed s/:$//) |awk -F " " '{print $7}')'' >> /root/.bashrc
echo 'DHCP_DNS='$(ifconfig $INTERNAL | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."$3"."$4}')'' >> /root/.bashrc
sed -i 's/DHCP_GW=100 /DHCP_GW=/g' /root/.bashrc
sed -i 's/DNS=100 /DNS=/g' /root/.bashrc

touch RHTI/VARIABLES1
}

#-------------------------------
function IPA {
#-------------------------------
YMESSAGE="Adding to /root/.bashrc vars"
NMESSAGE="Skipping"
FMESSAGE="PLEASE ENTER Y or N"
COUNTDOWN=10
DEFAULTVALUE=n
echo "*********************************************************"
echo "IPA SERVER"
echo "*********************************************************"
read -n1 -p "Do you have an IPA server? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
yum install -y ipa-client ipa-admintools
echo " "
echo " "
echo 'What is the FQDN of the IPA Server?'
read FQDNIPA
echo 'IPA_SERVER='$FQDNIPA'' >> /root/.bashrc
echo " "
echo " "
echo 'What is the ip address of your IPA host?'
read IPAIP
echo 'IPA_IP='$IPAIP'' >> /root/.bashrc
echo " "
echo " "
source /root/.bashrc
echo '$IPA_IP $FQDNIPA' >> /etc/hosts
#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
fi
sudo touch RHTI/IPA
}

#-------------------------------
function CAPSULE {
#-------------------------------
YMESSAGE="Adding to /root/.bashrc vars"
NMESSAGE="Skipping"
FMESSAGE="PLEASE ENTER Y or N"
COUNTDOWN=10
DEFAULTVALUE=n
echo "*********************************************************"
echo "CAPSULE"
echo "*********************************************************"
read -n1 -p "Would you like to install a secondary capsule ? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
echo 'PREPARE_CAPSULE=true' >> /root/.bashrc
echo 'What will the FQDN of the Capsule be?'
read CAPNAME
echo 'CAPSULE_NAME='$CAPNAME'' >> /root/.bashrc
echo 'What is the location of the Capsule?'
read CAPLOC
echo 'CAPSULE_LOC='$CAPLOC'' >> /root/.bashrc
#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
fi
sudo touch RHTI/CAPSULE
}

#-------------------------------
function SATLIBVIRT {
#-------------------------------
YMESSAGE="Adding to /root/.bashrc vars"
NMESSAGE="Skipping"
FMESSAGE="PLEASE ENTER Y or N"
COUNTDOWN=10
DEFAULTVALUE=n
echo "*********************************************************"
echo "LIBVIRT COMPUTE RESOURCE"
echo "*********************************************************"
read -n1 -p "Would you like to set up LIBVIRT as a compute resourse ? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
echo 'CONFIGURE_LIBVIRT_RESOURCE=true' >> /root/.bashrc
echo 'What is the fqdn of your libvirt host?'
read LIBVIRTFQDN
echo 'COMPUTE_RES_FQDN='$LIBVIRTFQDN'' >> /root/.bashrc
echo 'What is the ip address of your libvirt host?'
read LIBVIRTIP
echo 'COMPUTE_RES_IP='$LIBVIRTIP'' >> /root/.bashrc
echo 'What would you like to name your libvirt satellite resource? Example KVM'
read KVM
echo 'COMPUTE_RES_NAME='$KVM'' >> /root/.bashrc
source /root/.bashrc
echo ''$COMPUTE_RES_IP' '$COMPUTE_RES_FQDN'' >> /etc/hosts
#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
echo 'CONFIGURE_LIBVIRT_RESOURCE=false' >> /root/.bashrc
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
fi
sudo touch RHTI/SATLIBVIRT
}

#-------------------------------
function SATRHV {
#-------------------------------
echo "*********************************************************"
echo "RHV COMPUTE RESOURCE"
echo "*********************************************************"
read -n1 -p "Would you like to set up RHV as a compute resourse ? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
echo 'CONFIGURE_RHEV_RESOURCE=true' >> /root/.bashrc
echo 'What is the fqdn of your RHV host?'
read RHVQDN
echo 'COMPUTE_RES_FQDN=$RHVFQDN' >> /root/.bashrc
echo 'What is the ip address of your RHV host?'
read RHVIP
echo 'COMPUTE_RES_IP=$RHVIP' >> /root/.bashrc
echo 'What would you like to name your RHV satellite resource? Example RHV'
read RHV
echo 'COMPUTE_RES_NAME=$RHV' >> /root/.bashrc
echo 'RHV_VERSION_4=true' >> /root/.bashrc
echo 'RHV_RES_USER=admin@internal' >> /root/.bashrc
echo 'RHV_RES_PASSWD='$ADMIN_PASSWORD'' >> /root/.bashrc
echo 'RHV_RES_UUID=Default' >> /root/.bashrc
source /root/.bashrc
echo '$COMPUTE_RES_IP " " $COMPUTE_RES_FQDN' >> /etc/hosts
#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
echo 'CONFIGURE_RHEV_RESOURCE=false' >> /root/.bashrc
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
fi
sudo touch RHTI/SATRHV

}

# This script alternatively allows to use a RHV virtualization backend using the following parameters
#-------------------------------
function RHVORLIBVIRT {
#-------------------------------
echo "*********************************************************"
echo "RHV or LIBVIRT=TRUE"
echo "*********************************************************"
source /root/.bashrc
if [ $CONFIGURE_RHEV_RESOURCE = 'true' -a $CONFIGURE_LIBVIRT_RESOURCE = 'true' ]; then
echo "Only one of CONFIGURE_RHEV_RESOURCE and CONFIGURE_LIBVIRT_RESOURCE may be true."
exit 1
fi
# FIRST_SATELLITE matters only if you want to have more than one Sat work with the same IPAREALM infrastructure.
# If this is the case, you need to make sure to set this to false for all subsequent Satellite instances.
echo 'FIRST_SATELLITE=false ' >> /root/.bashrc
echo ' '
echo 'In another terminal please check/correct any variables in /root/.bashrc
that are nopt needed or are wrong'
read -p "Press [Enter] to continue"
sudo touch RHTI/RHVORLIBVIRT
reset
}

#-------------------------------
function SYNCREL5 {
#-------------------------------
echo "*********************************************************"
echo "SYNC RHEL 5?"
echo "*********************************************************"
read -n1 -p "Would you like to enable RHEL 5 content " INPUT
INPUT=${INPUT:-$RHEL5DEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
echo 'RHEL5DEFAULTVALUE=y' >> /root/.bashrc
#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
echo 'RHEL5DEFAULTVALUE=n' >> /root/.bashrc
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"

fi
sudo touch RHTI/SYNCREL5
}

#-------------------------------
function SYNCREL6 {
#-------------------------------
echo "*********************************************************"
echo "SYNC RHEL 6?"
echo "*********************************************************"
read -n1 -p "Would you like to enable RHEL 6 content " INPUT
INPUT=${INPUT:-$RHEL6DEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
echo 'RHEL6DEFAULTVALUE=y' >> /root/.bashrc
#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
echo 'RHEL6DEFAULTVALUE=n' >> /root/.bashrc
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
fi
sudo touch RHTI/SYNCREL6
}

#---END OF VARIABLES 1 SCRIPT---

#---------------------------------START OF SAT 6.X INSTALL SCRIPT---------------------------------
#------------------------------
function INSTALLREPOS {
#------------------------------
echo "****************************************************"
echo "SET REPOS FOR INSTALLING AND UPDATING SATELLITE 7"
echo "***************************************************"
echo -ne "\e[8;40;170t"
subscription-manager repos --disable '*'
echo " "
echo " "
echo " "
echo "**************************"
echo "ENABLE Satellite 6.7 REPOS"
echo "**************************"
subscription-manager repos --enable=rhel-7-server-rpms
subscription-manager repos --enable=rhel-server-rhscl-7-rpms
subscription-manager repos --enable=rhel-7-server-optional-rpms
subscription-manager repos --enable=rhel-7-server-satellite-6.7-rpms || exit 1
subscription-manager repos --enable=rhel-7-server-satellite-maintenance-6-rpms || exit 1
subscription-manager repos --enable=rhel-7-server-ansible-2.9-rpms
yum clean all 
rm -rf /var/cache/yum
echo " "
echo " "
echo " "
sudo touch RHTI/INSTALLREPOS
}

#------------------------------
function INSTALLDEPS {
#------------------------------
echo "************************************************************************"
echo "INSTALLING DEPENDENCIES AND UPDATING FOR SATELLITE OPERATING ENVIRONMENT"
echo "************************************************************************"
echo -ne "\e[8;40;170t"
yum-config-manager --enable epel
subscription-manager repos --enable=rhel-7-server-extras-rpms
yum clean all ; rm -rf /var/cache/yum
sleep 1
yum install -y qemu-kvm libvirt virt-install bridge-utils screen syslinux python-pip python3-pip rubygems lorax yum-utils vim gcc gcc-c++ git make automake kernel-devel libvirt-client bind dhcp tftp libvirt augeas ruby git --skip-broken
sleep 1
echo " "
echo " "
echo " "
echo "*****************************************************"
echo "INSTALLING DEPENDENCIES FOR CONTENT VIEW AUTO PUBLISH"
echo "*****************************************************"
 yum -y install python-pip python2-pip rubygem-builder --skip-broken
 pip install --upgrade wheel
 pip install --upgrade pip
#gem install bundler
echo " "
echo " "
echo " "
echo "*********************************************************"
echo "UPGRADING OS"
echo "*********************************************************"
 yum-config-manager --disable epel
 subscription-manager repos --disable=rhel-7-server-extras-rpms
 yum clean all ; rm -rf /var/cache/yum
 yum upgrade -y; yum update -y
 sudo touch RHTI/INSTALLDEPS
}

#----------------------------------
function GENERALSETUP {
#----------------------------------
echo "*********************************************************"
echo 'GENERAL SETUP'
echo "*********************************************************"
echo -ne "\e[8;40;170t"
source /root/.bashrc
echo " "

echo "*********************************************************"
echo "GENERATE USERS AND SYSTEM KEYS FOR REQUIRED USERS"
echo "*********************************************************"

echo "*********************************************************"
echo "SETTING UP FOREMAN-PROXY"
echo "*********************************************************"
useradd foreman-proxy -U -d /usr/share/foreman-proxy/ 
sleep 1
mkdir -p /usr/share/foreman-proxy/.ssh
sleep 1
sudo -u foreman-proxy ssh-keygen -f /usr/share/foreman-proxy/.ssh/id_rsa_foreman_proxy -N ''
chown -R foreman-proxy:foreman-proxy /usr/share/foreman-proxy
echo " "

echo "*********************************************************"
echo "ROOT"
echo "*********************************************************"
ssh-keygen -f /root/.ssh/id_rsa -t rsa -N ''
echo " "

echo "*********************************************************"
echo “SET DOMAIN”
echo "*********************************************************"
cp /etc/sysctl.conf /etc/sysctl.conf.bak
echo 'inet.ipv4.ip_forward=1' >> /etc/sysctl.conf
echo "kernel.domainname=$DOM" >> /etc/sysctl.conf
echo " "

echo "*********************************************************"
echo "GENERATE /ETC/HOSTS"
echo "*********************************************************"
cp /etc/hosts /etc/hosts.bak
echo "${SAT_IP} $(hostname)" >>/etc/hosts
echo " "

echo "*********************************************************"
echo "ADDING KATELLO-CVMANAGER TO /HOME/ADMIN/GIT "
echo "*********************************************************"
cd /home/admin/git
git clone https://github.com/RedHatSatellite/katello-cvmanager.git
cd /home/admin/Downloads/
mkdir -p /root/.hammer
echo " "

echo "*********************************************************"
echo "SETTING ADMIN/FOREMAN USERS TO NO PASSWORD FOR SUDO"
echo "*********************************************************"
cp /etc/sudoers /etc/sudoers.bak
echo 'foreman ALL = NOPASSWD: ALL' >> /etc/sudoers
echo " "
sudo touch RHTI/GENERALSETUP
}

# --------------------------------------
function SYSCHECK {
# --------------------------------------
echo "*********************************************************"
echo "CHECKING ALL REQUIREMENTS HAVE BEEN MET"
echo "*********************************************************"
echo " "
echo "*********************************************************"
echo "CHECKING FQDN"
echo "*********************************************************"
hostname -f 
if [ $? -eq 0 ]; then
echo 'The FQDN is as expected '$(hostname)''
else
echo "The FQDN is not defined please correct and try again"
mv /root/.bashrc.bak /root/.bashrc
mv /etc/sudoers.bak /etc/sudoers
mv /etc/hosts.bak /etc/hosts
mv /etc/sysctl.conf.bak /etc/sysctl.conf
sleep 10
exit
sleep 1
echo " "
fi
echo "*********************************************************"
echo "CHECKING FOR ADMIN USER"
echo "*********************************************************"
getent passwd admin > /dev/null 2&>1
if [ $? -eq 0 ]; then
echo "yes the admin user exists"
else
echo "No, the admin user does not exist
please create a admin user and try again."
exit
sleep 1
echo " "
fi
sudo touch RHTI/SYSCHECK
}

# --------------------------------------
function INSTALLNSAT {
# --------------------------------------
echo -ne "\e[8;40;170t"
source /root/.bashrc
echo " "
echo " "
echo " "
echo "*********************************************************"
echo "VERIFING REPOS FOR Satellite 6.7"
echo "*********************************************************"
yum-config-manager --disable epel
subscription-manager repos --disable=rhel-7-server-extras-rpms
yum clean all
rm -rf /var/cache/yum
subscription-manager repos --enable=rhel-7-server-rpms
subscription-manager repos --enable=rhel-server-rhscl-7-rpms
subscription-manager repos --enable=rhel-7-server-optional-rpms
subscription-manager repos --enable=rhel-7-server-satellite-6.7-rpms
subscription-manager repos --enable=rhel-7-server-satellite-maintenance-6-rpms
subscription-manager repos --enable=rhel-7-server-ansible-2.9-rpms 
yum clean all
rm -rf /var/cache/yum
sleep 1
echo " "
echo " "
echo " "
echo "*********************************************************"
echo "INSTALLING SATELLITE COMPONENTS"
echo "*********************************************************"
echo "INSTALLING SATELLITE"
yum-config-manager --disable epel
yum -q list installed satellite &>/dev/null && echo "satellite is installed" || time yum install -y 'satellite' --skip-broken 
echo " "
echo "INSTALLING PUPPET"
yum -q list installed puppetserver &>/dev/null && echo "puppetserver is installed" || time yum install puppetserver -y --skip-broken
yum -q list installed puppet-agent-oauth &>/dev/null && echo "puppet-agent-oauth is installed" || time yum install puppet-agent-oauth -y --skip-broken
yum -q list installed puppet-agent &>/dev/null && echo "puppet-agent is installed" || time yum install puppet-agent -y --skip-broken
yum -q list installed rh-mongodb34-syspaths &>/dev/null && echo "rh-mongodb34-syspaths is installed" || time yum install rh-mongodb34-syspaths -y --skip-broken
yum -q list installed fio &>/dev/null && echo "fio is installed" || time yum install fio -y --skip-broken
echo " "
echo " "
echo "INSTALLING ANSIBLE ROLES"
subscription-manager repos --enable=rhel-7-server-extras-rpms
yum-config-manager --enable epel
yum clean all
rm -rf /var/cache/yum
yum -q list installed rhel-system-roles &>/dev/null && echo "rhel-system-roles is installed" || time yum install rhel-system-roles -y --skip-broken
sleep 1
subscription-manager repos --disable=rhel-7-server-extras-rpms
yum-config-manager --disable epel
sudo touch RHTI/INSTALLNSAT
}

#
#---START OF SAT 6.X CONFIGURE SCRIPT---
#--------------------------------------
function CONFSAT {
#--------------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo " "
echo " "
echo "*********************************************************"
echo "CONFIGURING SATELLITE"
echo "*********************************************************"
echo " "
echo "*********************************************************"
echo "CONFIGURING SATELLITE BASE"
echo "*********************************************************"
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo " "
echo " "
yum clean all
rm -rf /var/cache/yum
sleep 1
foreman-maintain packages unlock

satellite-installer --scenario satellite -v \
--no-lock-package-versions \
--foreman-cli-username=$ADMIN \
--foreman-cli-password=$ADMIN_PASSWORD \
--foreman-initial-admin-username=$ADMIN \
--foreman-initial-admin-password=$ADMIN_PASSWORD \
--foreman-proxy-plugin-remote-execution-ssh-install-key true \
--foreman-initial-organization=$ORG \
--foreman-initial-location=$LOC \
--foreman-proxy-dns true \
--foreman-proxy-dns-managed=true \
--foreman-proxy-dns-provider=nsupdate \
--foreman-proxy-dns-server="127.0.0.1" \
--foreman-proxy-dns-interface $SAT_INTERFACE \
--foreman-proxy-dns-zone=$DOM \
--foreman-proxy-dns-forwarders $DNS \
--foreman-proxy-dns-reverse $DNS_REV \
--foreman-proxy-dns-listen-on both \
--foreman-proxy-bmc-listen-on both \
--foreman-proxy-logs-listen-on both \
--foreman-proxy-realm-listen-on both \
--foreman-proxy-plugin-remote-execution-ssh-install-key 

foreman-maintain packages unlock
systemctl enable named.service
systemctl start named.service

read -p "^^^ Take note of you credentials above ^^^
(you will use this to import your manifest in a moment) 
Now, Press [Enter] to continue"

#--foreman-proxy-dns-tsig-principal="foreman-proxy $(hostname)@$DOM" \
#--foreman-proxy-dns-tsig-keytab=/etc/foreman-proxy/dns.key \
sudo touch RHTI/CONFSAT
}


#--------------------------------------
function CONFSATDHCP {
#--------------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo " "
echo " "
echo "*********************************************************"
echo "CONFIGURING SATELLITE DHCP"
echo "*********************************************************"
yum clean all
rm -rf /var/cache/yum
katello-service stop
foreman-maintain packages unlock
foreman-installer -v \
--no-lock-package-versions \
--foreman-proxy-dhcp true \
--foreman-proxy-dhcp-server=$INTERNALIP \
--foreman-proxy-dhcp-interface=$SAT_INTERFACE \
--foreman-proxy-dhcp-range="$DHCP_RANGE" \
--foreman-proxy-dhcp-gateway=$DHCP_GW \
--foreman-proxy-dhcp-nameservers=$DHCP_DNS \
--foreman-proxy-dhcp-listen-on both

systemctl enable dhcpd.service
systemctl start dhcpd.service
sleep 5
sudo touch RHTI/CONFSATDHCP
}

#--------------------------------------
function CONFSATTFTP {
#--------------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo " "
echo " "
echo "*********************************************************"
echo "CONFIGURING SATELLITE TFTP"
echo "*********************************************************"
yum clean all
rm -rf /var/cache/yum
sleep 1
katello-service stop
foreman-maintain packages unlock
yum -q list installed foreman-discovery* &>/dev/null && echo "foreman-discovery-image is installed" || yum install -y foreman-discovery-image* --skip-broken
yum -q list installed rubygem-smart_proxy_discovery &>/dev/null && echo "rubygem-smart_proxy_discovery is installed" || yum install -y rubygem-smart_proxy_discovery* --skip-broken 
foreman-installer -v \
--no-lock-package-versions \
--foreman-proxy-tftp true \
--foreman-proxy-tftp-listen-on both \
--foreman-proxy-tftp-servername="$(hostname)"

systemctl start tftp.service
systemctl enable tftp.service
sudo touch RHTI/CONFSATTFTP
}

#--------------------------------------
function FOREMANPROXY {
#--------------------------------------
yum clean all
rm -rf /var/cache/yum
sleep 1
katello-service stop
foreman-maintain packages unlock
yum -q list installed tfm-rubygem-foreman_discovery &>/dev/null && echo "tfm-rubygem-foreman_discovery is installed" || yum install -y tfm-rubygem-foreman_discovery* --skip-broken
yum -q list installed foreman-discovery-image &>/dev/null && echo "foreman-discovery-image_client is installed" || yum install -y foreman-discovery* --skip-broken
yum -q list installed rubygem-smart_proxy_discovery &>/dev/null && echo "rubygem-smart_proxy_discovery is installed" || yum install -y rubygem-smart_proxy_discovery* --skip-broken
yum -q list installed rubygem-smart_proxy_discovery_image &>/dev/null && echo "rubygem-smart_proxy_discovery_image y is installed" || yum install -y rubygem-smart_proxy_discovery_image --skip-broken
foreman-installer -v
--enable-foreman-proxy \
--enable-foreman-proxy-content \
--enable-foreman-proxy-plugin-ansible \
--enable-foreman-proxy-plugin-dhcp-remote-isc \
--enable-foreman-proxy-plugin-discovery \
--enable-foreman-proxy-plugin-openscap \
--enable-foreman-proxy-plugin-pulp \
--enable-foreman-proxy-plugin-remote-execution-ssh
sudo touch RHTI/FOREMANPROXY
}

#--------------------------------------
function CONFSATPLUGINS {
#--------------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo " "
echo " "
echo "*********************************************************"
echo "CONFIGURING ALL SATELLITE PLUGINS"
echo "*********************************************************"
katello-service stop
foreman-maintain packages unlock
subscription-manager repos --enable=rhel-7-server-rpms
subscription-manager repos --enable=rhel-server-rhscl-7-rpms
subscription-manager repos --enable=rhel-7-server-optional-rpms
subscription-manager repos --enable=rhel-7-server-satellite-6.7-rpms
subscription-manager repos --enable=rhel-7-server-satellite-maintenance-6-rpm
subscription-manager repos --enable rhel-7-server-ansible-2.9-rpms
subscription-manager repos --enable=rhel-7-server-extras-rpms
yum clean all 
rm -rf /var/cache/yum
yum -q list installed puppet-foreman_scap_client &>/dev/null && echo "puppet-foreman_scap_client is installed" || yum install -y puppet-foreman_scap_client* --skip-broken
yum -q list installed tfm-rubygem-hammer_cli_foreman_discovery &>/dev/null && echo "tfm-rubygem-hammer_cli_foreman_discovery is installed" || yum install -y tfm-rubygem-hammer_cli_foreman_discovery --skip-broken

source /root/.bashrc
foreman-maintain packages unlock

foreman-installer -v \
--enable-foreman-cli-kubevirt \
--enable-foreman-compute-ec2 \
--enable-foreman-compute-gce \
--enable-foreman-compute-libvirt \
--enable-foreman-compute-openstack \
--enable-foreman-compute-ovirt \
--enable-foreman-compute-rackspace \
--enable-foreman-compute-vmware \
--enable-foreman-plugin-ansible \
--enable-foreman-plugin-bootdisk \
--enable-foreman-plugin-discovery \
--enable-foreman-plugin-hooks \
--enable-foreman-plugin-kubevirt \
--enable-foreman-plugin-openscap \
--enable-foreman-plugin-remote-execution \
--enable-foreman-plugin-tasks \
--enable-foreman-plugin-templates \
--enable-katello \
--enable-puppet 

sudo touch RHTI/CONFSATPLUGINS
}

#--------------------------------------
function CONFSATDEB {
#--------------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
foreman-maintain packages unlock
echo " "
echo " "
echo " "
echo "*********************************************************"
echo "CONFIGURING DEB SATELLITE PLUGINS"
echo "*********************************************************"
yum clean all 
rm -rf /var/cache/yum
echo " "
echo "*********************************************************"
echo "ENABLE DEB"
echo "*********************************************************"
foreman-maintain packages unlock
#yum install https://yum.theforeman.org/releases/latest/el7/x86_64/foreman-release.rpm
#satellite-installer -v --katello-enable-deb true
#foreman-installer -v --foreman-proxy-content-enable-deb --katello-enable-deb
sudo touch RHTI/CONFSATDEB
}

#--------------------------------------
function CONFSATCACHE {
#--------------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
sleep 1
echo "*********************************************************"
echo "CONFIGURING SATELLITE CACHE"
echo "*********************************************************"
foreman-rake apipie:cache:index --trace
echo " "
echo " "
echo " "
sudo touch RHTI/CONFSATCACHE
}

#--------------------------------------
function CHECKDHCP {
#--------------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
sleep 1
echo "*********************************************************"
echo "VERIFYING DHCP IS WANTED FOR NEW SYSTEMS "
echo "*********************************************************"
echo " "
DEFAULTDHCP=y
COUNTDOWN=15
read -n1 -t "$COUNTDOWN" -p "Would like to use the DHCP server provided by Satellite? y/n " INPUT
INPUT=${INPUT:-$DEFAULTDHCP}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo " "
echo "DHCPD ENABLED"
#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo " "
echo "DHCPD DISABLED"
chkconfig dhcpd off
service dhcpd stop
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
fi
sudo touch RHTI/CHECKDHCP
}

#--------------------------------------
function DISABLEEXTRAS {
#--------------------------------------
echo "*********************************************************"
echo "DISABLING EXTRA REPO "
echo "*********************************************************"
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
subscription-manager repos --disable=rhel-7-server-extras-rpms
yum clean all 
rm -rf /var/cache/yum
sudo touch RHTI/DISABLEEXTRAS
}

#------------------------------
function HAMMERCONF {
#------------------------------
echo " "
echo " "
echo " "
echo "*********************************************************"
echo "CONFIGURING HAMMER"
echo "*********************************************************"
echo -ne "\e[8;40;170t"
source /root/.bashrc
echo "*********************************************************"
echo "Enabling Hammer for Satellite configuration tasks"
echo "Setting up hammer will list the Satellite username and password in the /root/.hammer/cli_config.yml file
with default permissions set to -rw-r--r--, if this is a security concern it is recommended the file is
deleted once the setup is complete"
echo "*********************************************************"
read -p "Press [Enter] to continue"
sleep 10
cat > /root/.hammer/cli_config.yml<< EOF
:foreman:
 :host: 'https://$(hostname -f)'
 :username: '$ADMIN'
 :password: '$ADMIN_PASSWORD'
:log_dir: '/var/log/foreman'
:log_level: 'error'
EOF
sed -i 's/example/redhat/g' /etc/hammer/cli.modules.d/foreman.yml
sed -i 's/#:password/:password/g' /etc/hammer/cli.modules.d/foreman.yml
sudo touch RHTI/HAMMERCONF
}

# --------------------------------------
function CONFIG2 {
# --------------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo " "
echo " "
echo "*********************************************************"
echo '
Pulling up the url so you can build and export the manifest
This must be saved into the /home/admin/Downloads directory
'
echo "*********************************************************"
echo " "
echo " "
echo " "
read -p "Press [Enter] to continue"
echo " "
echo " "
echo " "
echo "*********************************************************"
echo 'If you have put your manafest into /home/admin/Downloads/'
echo "*********************************************************"
read -p "Press [Enter] to continue"
sleep 1
echo " "
echo " "
echo " "
echo "*********************************************************"
echo 'WHEN PROMPTED PLEASE ENTER YOUR SATELLITE ADMIN USERNAME AND PASSWORD'
echo "*********************************************************"
hammer organization update --name $ORG
hammer location update --name $LOC
sleep 1
chown -R admin:admin /home/admin
source /root/.bashrc
for i in $(find /home/admin/Downloads/ |grep manifest* ); do sudo -u admin hammer subscription upload --file $i --organization $ORG ; done || exit 1
hammer subscription refresh-manifest --organization $ORG
echo " "
echo " "
echo " "
echo "*********************************************************"
echo 'REFRESHING THE CAPSULE CONTENT'
echo "*********************************************************"
for i in $(hammer capsule list |awk -F '|' '{print $1}' |grep -v ID|grep -v -) ; do hammer capsule refresh-features --id=$i ; done 
sleep 1
echo " "
echo " "
echo " "
echo "*********************************************************"
echo 'SETTING SATELLITE ENV SETTINGS'
echo "*********************************************************"
hammer settings set --name default_download_policy --value on_demand
hammer settings set --name default_organization --value "$ORG"
hammer settings set --name default_location --value "$LOC"
hammer settings set --name discovery_organization --value "$ORG"
hammer settings set --name root_pass --value "$NODEPASS"
hammer settings set --name query_local_nameservers --value true
#hammer settings set --name lab_features --value true
hammer settings set --name discovery_location --value "$LOC"
hammer settings set --name content_view_solve_dependencies --value true
hammer settings set --name remote_execution_by_default --value true
hammer settings set --name ansible_ssh_private_key_file --value /root/.ssh/id_rsa
hammer settings set --name unregister_delete_host --value true
hammer settings set --name default_puppet_environment --value common
hammer settings set --name ansible_verbosity --value "Level 3(-vvv)"

mkdir -p /etc/puppet/environments/production/modules

echo " "
echo " "
echo " "
sudo touch RHTI/CONFIG2
}

#-------------------------------
function STOPSPAMMINGVARLOG {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "STOP THE LOG SPAMMING OF /VAR/LOG/MESSAGES WITH SLICE"
echo "*********************************************************"
echo 'if $programname == "systemd" and ($msg contains "Starting Session" or $msg contains "Started Session" or $msg contains "Created slice" or $msg contains "Starting user-" or $msg contains "Starting User Slice of" or $msg contains "Removed session" or $msg contains "Removed slice User Slice of" or $msg contains "Stopping User Slice of") then stop' > /etc/rsyslog.d/ignore-systemd-session-slice.conf
systemctl restart rsyslog 
sudo touch RHTI/STOPSPAMMINGVARLOG
}


#NOTE: Jenkins, CentOS Linux 7.6 Puppet Forge, Icinga, and Maven are examples of setting up a custom repository
#---START OF REPO CONFIGURE AND SYNC SCRIPT---
source /root/.bashrc
QMESSAGE5="Would you like to enable and sync RHEL 5 Content
This will enable
 Red Hat Enterprise Linux 5 Server (Kickstart)
 Red Hat Enterprise Linux 5 Server
 Red Hat Satellite Tools 6.7 (for RHEL 5 Server)
 Red Hat Software Collections RPMs for Red Hat Enterprise Linux 5 Server
 Red Hat Enterprise Linux 5 Server - Extras
 Red Hat Enterprise Linux 5 Server - Optional
 Red Hat Enterprise Linux 5 Server - Supplementary
 Red Hat Enterprise Linux 5 Server - RH Common
 Extra Packages for Enterprise Linux 5"

QMESSAGE6="Would you like to enable and sync RHEL 6 Content
This will enable
 Red Hat Enterprise Linux 6 Server (Kickstart)
 Red Hat Enterprise Linux 6 Server
 Red Hat Satellite Tools 6.7 (for RHEL 6 Server)
 Red Hat Software Collections RPMs for Red Hat Enterprise Linux 6 Server
 Red Hat Enterprise Linux 6 Server - Extras
 Red Hat Enterprise Linux 6 Server - Optional
 Red Hat Enterprise Linux 6 Server - Supplementary
 Red Hat Enterprise Linux 6 Server - RH Common
 Extra Packages for Enterprise Linux 6"

QMESSAGE7="Would you like to enable and sync RHEL 7 Content
This will enable:
 Red Hat Enterprise Linux 7 Server (Kickstart)
 Red Hat Enterprise Linux 7 Server
 Red Hat Satellite Tools 6.7 (for RHEL 7 Server)
 Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server
 Red Hat Enterprise Linux 7 Server - Extras
 Red Hat Enterprise Linux 7 Server - Optional
 Red Hat Enterprise Linux 7 Server - Supplementary
 Red Hat Enterprise Linux 7 Server - RH Common
 Extra Packages for Enterprise Linux 7"

QMESSAGE8="Would you like to enable and sync RHEL 8 Content
This will enable:
Red Hat Storage Native Client for RHEL 8 (RPMs)
Red Hat Enterprise Linux 8 for x86_64 - AppStream (RPMs)
Red Hat Enterprise Linux 8 for x86_64 - BaseOS (Kickstart)
Red Hat Enterprise Linux 8 for x86_64 - AppStream (Kickstart)
Red Hat Enterprise Linux 8 for x86_64 - Supplementary (RPMs)
Red Hat Enterprise Linux 8 for x86_64 - BaseOS (RPMs)
Red Hat Satellite Tools 6.7 for RHEL 8 x86_64 (RPMs)"

QMESSAGEJBOSS="Would you like to download JBoss Enterprise Application Platform 7 (RHEL 7 Server) content"
QMESSAGEVIRTAGENT="Would you like to download Red Hat Virtualization 4 Management Agents for RHEL 7 content"
QMESSAGESAT65="Would you like to download Red Hat Satellite 6.7 (for RHEL 7 Server) content"
QMESSAGECAP65="Would you like to download Red Hat Satellite Capsule 6.7 (for RHEL 7 Server) content"
QMESSAGEOSC="Would you like to download Red Hat OpenShift Container Platform 3.10 content"
QMESSAGECEPH="Would you like to download Red Hat Ceph Storage Tools 3.0 for Red Hat Enterprise Linux 7 Server content"
QMESSAGESNC="Would you like to download Red Hat Storage Native Client for RHEL 7 content"
QMESSAGECSI="Would you like to download Red Hat Ceph Storage Installer 3.0 for Red Hat Enterprise Linux 7 Server content"
QMESSAGEOSP="Would you like to download Red Hat OpenStack Platform 13 for RHEL 7 content"
QMESSAGEOSPT="Would you like to download Red Hat OpenStack Tools 7.0 for Red Hat Enterprise Linux 7 Server content"
QMESSAGERHVH="Would you like to download Red Hat Virtualization Host 7 content"
QMESSAGERHVM="Would you like to download Red Hat Virtualization Manager 4.2 (RHEL 7 Server) content"
QMESSAGEATOMIC="Would you like to download Red Hat Enterprise Linux Atomic Host content"
QMESSAGETOWER="Would you like to download Ansible Tower custom content"
QMESSAGEPUPPET="Would you like to download Puppet Forge custom content"
QMESSAGEJENKINS="Would you like to download JENKINS custom content"
QMESSAGEMAVEN="Would you like to download Maven custom content"
QMESSAGEICINGA="Would you like to download Icinga custom content"
QMESSAGEICENTOS7="Would you like to download CentOS Linux 7.6 custom content"
QMESSAGEISCIENTIFICLINUX7="Would you like to download SCIENTIFIC LINUX 7.6 custom content"

YMESSAGE="Adding avalable content. This step will take the longest,
(Depending on your network)"
NMESSAGE="Skipping avalable content"
FMESSAGE="PLEASE ENTER Y or N"
COUNTDOWN=15
OTHER7REPOSDEFAULTVALUE=n
RHEL7DEFAULTVALUE=y
RHEL8DEFAULTVALUE=y
PUPPETDEFAULTVALUE=y

#-------------------------------
function REQUESTSYNCMGT {
#-------------------------------
echo "*********************************************************"
echo "Configuring Repositories"
echo "*********************************************************"
echo "*********************************************************"
echo "BY DEFAULT IF YOU JUST LET THIS SCRIPT RUN YOU WILL 
ONLY SYNC THE CORE RHEL 7 (KICKSTART, 7SERVER, OPTIONAL, EXTRAS,
 SAT 6.7 TOOLS, SUPPLAMENTRY, AND RH COMMON ) THE PROGRESS 
 TO THIS STEP CAN BE TRACKED AT $(hostname)/katello/sync_management :"
echo "*********************************************************"
if ! xset q &>/dev/null; then
echo "No X server at \$DISPLAY [$DISPLAY]" >&2
echo 'In a system browser please goto the URL to view progress https://$(hostname)/katello/sync_management'
sleep 10
else 
firefox https://$(hostname)/katello/sync_management &
fi
sudo touch RHTI/REQUESTSYNCMGT
}

#-------------------------------
function REQUEST5 {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RHEL 5 STANDARD REPOS:"
echo "*********************************************************"
read -n1 -t "$COUNTDOWN" -p "$QMESSAGE5 ? Y/N " INPUT
INPUT=${INPUT:-$RHEL5DEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='5.11' --name 'Red Hat Enterprise Linux 5 Server (Kickstart)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 5 Server Kickstart x86_64 5.11' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='5Server' --name 'Red Hat Enterprise Linux 5 Server (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 5 Server (RPMs)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --name 'Red Hat Satellite Tools 6.7 (for RHEL 5 Server) (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Satellite Tools 6.7 (for RHEL 5 Server) (RPMs)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Software Collections for RHEL Server' --basearch='x86_64' --releasever='5Server' --name 'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 5 Server'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Software Collections for RHEL Server' --name 'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 5 Server' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --name 'Red Hat Enterprise Linux 5 Server - Extras (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 5 Server - Extras (RPMs)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='5Server' --name 'Red Hat Enterprise Linux 5 Server - Optional (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 5 Server - Optional (RPMs)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='5Server' --name 'Red Hat Enterprise Linux 5 Server - Supplementary (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 5 Server - Supplementary (RPMs)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='5Server' --name 'Red Hat Enterprise Linux 5 Server - RH Common (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 5 Server - RH Common (RPMs)' 2>/dev/null

wget -q https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-5 /root/RPM-GPG-KEY-EPEL-5
sleep 10
hammer gpg create --key /root/RPM-GPG-KEY-EPEL-5 --name 'GPG-EPEL-5' --organization $ORG
sleep 10
hammer product create --name='Extra Packages for Enterprise Linux 5' --organization $ORG
sleep 10
hammer repository create --name='Extra Packages for Enterprise Linux 5' --organization $ORG --product='Extra Packages for Enterprise Linux 5' --content-type=yum --publish-via-http=true --url=https://archives.fedoraproject.org/pub/archive/epel/5/x86_64/ --checksum-type=sha256 --gpg-key=GPG-EPEL-5
time hammer repository synchronize --organization "$ORG" --product 'Extra Packages for Enterprise Linux 5' --name 'Extra Packages for Enterprise Linux 5' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
fi
sudo touch RHTI/REQUEST5
}

#-------------------------------
function REQUEST6 {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RHEL 6 STANDARD REPOS:"
echo "*********************************************************"
read -n1 -t "$COUNTDOWN" -p "$QMESSAGE6 ? Y/N " INPUT
INPUT=${INPUT:-$RHEL6DEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6Server' --name 'Red Hat Enterprise Linux 6 Server (Kickstart)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6.10'--name 'Red Hat Enterprise Linux 6 Server (Kickstart)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6Server' --name 'Red Hat Enterprise Linux 6 Server (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 6 Server (RPMs)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --name 'Red Hat Satellite Tools 6.7 (for RHEL 6 Server) (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Satellite Tools 6.7 (for RHEL 6 Server) (RPMs)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6Server' --name 'Red Hat Enterprise Linux 6 Server - Optional (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 6 Server - Optional (RPMs)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --name 'Red Hat Enterprise Linux 6 Server - Extras (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 6 Server - Extras (RPMs)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6Server' --name 'Red Hat Enterprise Linux 6 Server - RH Common (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 6 Server - RH Common (RPMs)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6Server' --name 'Red Hat Enterprise Linux 6 Server - Supplementary (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 6 Server - Supplementary (RPMs)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6Server' --name 'RHN Tools for Red Hat Enterprise Linux 6 Server (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'RHN Tools for Red Hat Enterprise Linux 6 Server (RPMs)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6Server' --name 'Red Hat Enterprise Linux 6 Server (ISOs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 6 Server (ISOs)' 2>/dev/null

wget -q https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6 -O /root/RPM-GPG-KEY-EPEL-6
sleep 10
hammer gpg create --key /root/RPM-GPG-KEY-EPEL-6 --name 'GPG-EPEL-6' --organization $ORG
sleep 10
hammer product create --name='Extra Packages for Enterprise Linux 6' --organization $ORG
sleep 10
hammer repository create --name='Extra Packages for Enterprise Linux 6' --organization $ORG --product='Extra Packages for Enterprise Linux 6' --content-type=yum --publish-via-http=true --url=http://dl.fedoraproject.org/pub/epel/6/x86_64/ --checksum-type=sha256 --gpg-key=GPG-EPEL-6
time hammer repository synchronize --organization "$ORG" --product 'Extra Packages for Enterprise Linux 6' --name 'Extra Packages for Enterprise Linux 6' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
fi
sudo touch RHTI/REQUEST6
}

#-------------------------------
function REQUEST7 {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RHEL 7 STANDARD REPOS:"
echo "*********************************************************"
read -n1 -t "$COUNTDOWN" -p "$QMESSAGE7 ? Y/N " INPUT
INPUT=${INPUT:-$RHEL7DEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7.7' --name 'Red Hat Enterprise Linux 7 Server (Kickstart)' 
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 7 Server Kickstart x86_64 7.7' 2>/dev/null
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Enterprise Linux 7 Server (RPMs)'
#time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 7 Server RPMs x86_64 7Server' 2>/dev/null
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Enterprise Linux 7 Server - Supplementary (RPMs)'
#time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 7 Server - Supplementary RPMs x86_64 7Server' 2>/dev/null
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Enterprise Linux 7 Server - Optional (RPMs)'
#time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 7 Server - Optional RPMs x86_64 7Server' 2>/dev/null
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --name 'Red Hat Enterprise Linux 7 Server - Extras (RPMs)'
#time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 7 Server - Extras RPMs x86_64' 2>/dev/null
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --name 'Red Hat Satellite Tools 6.7 (for RHEL 7 Server) (RPMs)'
#time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Satellite Tools 6.7 for RHEL 7 Server RPMs x86_64'
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Enterprise Linux 7 Server - RH Common (RPMs)'
#time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 7 Server - RH Common RPMs x86_64 7Server' 2>/dev/null
hammer repository-set enable --organization "$ORG" --product 'Red Hat Software Collections (for RHEL Server)' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server'
#time hammer repository synchronize --organization "$ORG" --product 'Red Hat Software Collections (for RHEL Server)' --name 'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server x86_64 7Server' 2>/dev/null
wget -q https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7 -O /root/RPM-GPG-KEY-EPEL-7
#wget -q https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7Server -O /root/RPM-GPG-KEY-EPEL-7Server
sleep 10
hammer gpg create --key /root/RPM-GPG-KEY-EPEL-7 --name 'GPG-EPEL-7' --organization $ORG
#hammer gpg create --key /root/RPM-GPG-KEY-EPEL-7Server --name 'GPG-EPEL-7Sever' --organization $ORG
sleep 10
hammer product create --name='Extra Packages for Enterprise Linux 7' --organization $ORG
#hammer product create --name='Extra Packages for Enterprise Linux 7Server' --organization $ORG
sleep 10
hammer repository create --name='Extra Packages for Enterprise Linux 7' --organization $ORG --product='Extra Packages for Enterprise Linux 7' --content-type yum --publish-via-http=true --url=https://dl.fedoraproject.org/pub/epel/7/x86_64/
#time hammer repository synchronize --organization "$ORG" --product 'Extra Packages for Enterprise Linux 7' --name 'Extra Packages for Enterprise Linux 7' 2>/dev/null
#hammer repository create --name='Extra Packages for Enterprise Linux 7Server' --organization $ORG --product='Extra Packages for Enterprise Linux 7Server' --content-type yum --publish-via-http=true --url=https://dl.fedoraproject.org/pub/epel/7Server/x86_64/
#time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Extra Packages for Enterprise Linux 7Server' 2>/dev/null
#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
fi
sudo touch RHTI/REQUEST7
}

#-------------------------------
function REQUEST8 {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RHEL 8 STANDARD REPOS:"
echo "*********************************************************"
read -n1 -t "$COUNTDOWN" -p "$QMESSAGE8 ? Y/N " INPUT
INPUT=${INPUT:-$RHEL8DEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux for x86_64' --basearch='x86_64' --releasever='8.1' --name 'Red Hat Enterprise Linux 8 for x86_64 - BaseOS (Kickstart)' 
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux for x86_64' --basearch='x86_64' --releasever='8.1' --name 'Red Hat Enterprise Linux 8 for x86_64 - AppStream (Kickstart)'
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux for x86_64' --basearch='x86_64' --releasever='8.1' --name 'Red Hat Enterprise Linux 8 for x86_64 - Supplementary (RPMs)'
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux for x86_64' --basearch='x86_64' --releasever='8.1' --name 'Red Hat Enterprise Linux 8 for x86_64 - BaseOS (RPMs)'
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux for x86_64' --basearch='x86_64' --name 'Red Hat Satellite Tools 6.7 for RHEL 8 x86_64 (RPMs)' 
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux for x86_64' --basearch='x86_64' --name 'Red Hat Storage Native Client for RHEL 8 (RPMs)'
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux for x86_64' --basearch='x86_64' --releasever='8.1' --name 'Red Hat Enterprise Linux 8 for x86_64 - AppStream (RPMs)'

wget -q https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-8 -O /root/RPM-GPG-KEY-EPEL-8
sleep 10
hammer gpg create --key /root/RPM-GPG-KEY-EPEL-8 --name 'RPM-GPG-KEY-EPEL-8' --organization $ORG
sleep 10
hammer product create --name='Extra Packages for Enterprise Linux 8' --organization $ORG
sleep 10
hammer repository create --name='Extra Packages for Enterprise Linux 8' --organization $ORG --product='Extra Packages for Enterprise Linux 8' --content-type yum --publish-via-http=true --url=https://dl.fedoraproject.org/pub/epel/8/Everything/x86_64/
#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
fi
sudo touch RHTI/REQUEST8
}

#-------------------------------
function REQUESTJBOSS {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "JBOSS ENTERPRISE APPLICATION PLATFORM 7:"
echo "*********************************************************"
read -n1 -t "$COUNTDOWN" -p "$QMESSAGEJBOSS ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'JBoss Enterprise Application Platform' --basearch='x86_64' --releasever='7Server' --name 'JBoss Enterprise Application Platform 7 (RHEL 7 Server) (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'JBoss Enterprise Application Platform' --name 'JBoss Enterprise Application Platform 7 (RHEL 7 Server) (RPMs)' 2>/dev/null
#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
fi
sudo touch RHTI/REQUESTJBOSS
}

#-------------------------------
function REQUESTVIRTAGENT {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RED HAT VIRTUALIZATION 4 MANAGEMENT AGENTS:"
echo "*********************************************************"
read -n1 -t "$COUNTDOWN" -p "$QMESSAGEVIRTAGENT ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat Virtualization' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Virtualization 4 Management Agents for RHEL 7 (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Virtualization' --name 'Red Hat Virtualization 4 Management Agents for RHEL 7 (RPMs)' 2>/dev/null
#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTIONICINGA
else
echo -e "\n$FMESSAGE\n"
fi
sudo touch RHTI/REQUESTVIRTAGENT
}

#-------------------------------
function REQUESTSAT64 {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RED HAT Satellite 6.7:"
echo "*********************************************************"
read -n1 -t "$COUNTDOWN" -p "$QMESSAGESAT64 ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat Satellite' --basearch='x86_64' --name 'Red Hat Satellite 6.7 (for RHEL 7 Server) (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Satellite' --name 'Red Hat Satellite 6.7 (for RHEL 7 Server) (RPMs)' 2>/dev/null
#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
fi
sudo touch RHTI/REQUESTSAT64
}

#-------------------------------
function REQUESTOSC {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RED HAT OPENSHIFT CONTAINER PLATFORM 3.10:"
echo "*********************************************************"
read -n1 -t "$COUNTDOWN" -p "$QMESSAGEOSC ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat OpenShift Container Platform' --basearch='x86_64' --name 'Red Hat OpenShift Container Platform 3.10 (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat OpenShift Container Platform' --name 'Red Hat OpenShift Container Platform 3.10 (RPMs)' 2>/dev/null
#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
fi
sudo touch RHTI/REQUESTOSC
}

#-------------------------------
function REQUESTCEPH {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RED HAT CEPH:"
echo "*********************************************************"
read -n1 -t "$COUNTDOWN" -p "$QMESSAGECEPH ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat Ceph Storage' --basearch='x86_64' --name 'Red Hat Ceph Storage 3 for Red Hat Enterprise Linux 7 Server (FILEs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Ceph Storage' --name 'Red Hat Ceph Storage 3 for Red Hat Enterprise Linux 7 Server (FILEs)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Ceph Storage Tools 3 for Red Hat Enterprise Linux 7 Server (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Ceph Storage Tools 3 for Red Hat Enterprise Linux 7 Server (RPMs)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Ceph Storage' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Ceph Storage MON 3 for Red Hat Enterprise Linux 7 Server (RPMs)'
time hammer repository synchronize --organization "$ORG" --product ' Red Hat Ceph Storage ' --name 'Red Hat Ceph Storage MON 3 for Red Hat Enterprise Linux 7 Server (RPMs)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Ceph Storage' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Ceph Storage 3 Text-Only Advisories for Red Hat Enterprise Linux 7 Server (RPMs)'
time hammer repository synchronize --organization "$ORG" --product ' Red Hat Ceph Storage' --name 'Red Hat Ceph Storage 3 Text-Only Advisories for Red Hat Enterprise Linux 7 Server (RPMs)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Ceph Storage' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Ceph Storage OSD 3 for Red Hat Enterprise Linux 7 Server (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Ceph Storage' --name 'Red Hat Ceph Storage OSD 3 for Red Hat Enterprise Linux 7 Server (RPMs)' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
fi
sudo touch RHTI/REQUESTCEPH
}

#-------------------------------
function REQUESTSNC {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RED HAT STORAGE NATIVE CLIENT:"
echo "*********************************************************"
read -n1 -t "$COUNTDOWN" -p "$QMESSAGESNC ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Storage Native Client for RHEL 7 (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Storage Native Client for RHEL 7 (RPMs)' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
fi
sudo touch RHTI/REQUESTSNC
}

#-------------------------------
function REQUESTCSI {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RED HAT CEPH STORAGE:"
echo "*********************************************************"
read -n1 -t "$COUNTDOWN" -p "$QMESSAGECSI ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat Ceph Storage' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Ceph Storage Installer 1.3 for Red Hat Enterprise Linux 7 Server (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Ceph Storage' --name 'Red Hat Ceph Storage Installer 1.3 for Red Hat Enterprise Linux 7 Server (RPMs)' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
fi
sudo touch RHTI/REQUESTCSI
}

#-------------------------------
function REQUESTOSP {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "OPENSTACK PLATFORM 13:"
echo "*********************************************************"
read -n1 -t "$COUNTDOWN" -p "$QMESSAGEOSP ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat OpenStack' --basearch='x86_64' --releasever='7Server' --name 'Red Hat OpenStack Platform 13 for RHEL 7 (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat OpenStack' --name 'Red Hat OpenStack Platform 13 for RHEL 7 (RPMs)' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
elsehttps://www.linuxtechi.com/proxy-settings-yum-command-on-rhel-centos-servers/
echo -e "\n$FMESSAGE\n"
fi
sudo touch RHTI/REQUESTRHVH
}

#-------------------------------
function REQUESTRHVM {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RHV:"
echo "*********************************************************"
read -n1 -t "$COUNTDOWN" -p "$QMESSAGERHVM ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat Virtualization' --basearch='x86_64' --name 'Red Hat Virtualization Manager 4.2 (RHEL 7 Server) (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Virtualization' --name 'Red Hat Virtualization Manager 4.2 (RHEL 7 Server) (RPMs)' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
fi
sudo touch RHTI/REQUESTRHVM
}

#-------------------------------
function REQUESTATOMIC {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "ATOMIC:"
echo "*********************************************************"
read -n1 -t "$COUNTDOWN" -p "$QMESSAGEATOMIC ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Atomic Host' --basearch='x86_64' --name 'Red Hat Enterprise Linux Atomic Host (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Atomic Host' --name 'Red Hat Enterprise Linux Atomic Host (RPMs)' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
fi
sudo touch RHTI/REQUESTATOMIC
}

#-------------------------------
function REQUESTTOWER {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "ANSIBLE TOWER:"
echo "*********************************************************"
read -n1 -t "$COUNTDOWN" -p "$QMESSAGETOWER ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer product create --name='Ansible-Tower' --organization $ORG
hammer repository create --name='Ansible-Tower' --organization $ORG --product='Ansible-Tower' --content-type yum --publish-via-http=true --url=http://releases.ansible.com/ansible-tower/rpm/epel-7-x86_64/
time hammer repository synchronize --organization "$ORG" --product 'Ansible-Tower' --name 'Ansible-Tower' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
fi
sudo touch RHTI/REQUESTTOWER
}

#-------------------------------
function REQUESTPUPPET {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "PUPPET FORGE:"
echo "*********************************************************"
read -n1 -t "$COUNTDOWN" -p "$QMESSAGEPUPPET ? Y/N " INPUT
INPUT=${INPUT:-$PUPPETDEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer product create --name='Puppet Forge' --organization $ORG
hammer repository create --name='Puppet Forge' --organization $ORG --product='Puppet Forge' --content-type puppet --publish-via-http=true --url=https://forge.puppetlabs.com
time hammer repository synchronize --organization "$ORG" --product 'Puppet Forge' --name 'Puppet Forge' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
fi
sudo touch RHTI/REQUESTPUPPET
}

#-------------------------------
function REQUESTJENKINS {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "JENKINS:"
echo "*********************************************************"
read -n1 -t "$COUNTDOWN" -p "$QMESSAGEJENKINS ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
wget http://pkg.jenkins.io/redhat-stable/jenkins.io.key
hammer gpg create --organization $ORG --name GPG-JENKINS --key jenkins.io.key
hammer product create --name='JENKINS' --organization $ORG
hammer repository create --organization $ORG --name='JENKINS' --product=$ORG --gpg-key='GPG-JENKINS' --content-type='yum' --publish-via-http=true --url=https://pkg.jenkins.io/redhat/ --download-policy immediate
#time hammer repository synchronize --organization "$ORG" --product 'JENKINS' --name 'JENKINS' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
fi
sudo touch RHTI/REQUESTJENKINS
}

#-------------------------------
function REQUESTMAVEN {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "MAVEN:"
echo "*********************************************************"
read -n1 -t "$COUNTDOWN" -p "$QMESSAGEMAVEN ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer product create --name='Maven' --organization $ORG
hammer repository create --organization $ORG --name='Maven 7Server' --product='Maven' --content-type='yum' --publish-via-http=true --url=https://repos.fedorapeople.org/repos/dchen/apache-maven/epel-7Server/x86_64/ --download-policy immediate
#time hammer repository synchronize --organization "$ORG" --product 'Maven 7Server' --name 'Maven 7Server' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
fi
sudo touch RHTI/REQUESTMAVEN
}

#-------------------------------
function REQUESTICINGA {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "ICINGA:"
echo "*********************************************************"
read -n1 -t "$COUNTDOWN" -p "$QMESSAGEICINGA ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
wget http://packages.icinga.org/icinga.key
hammer gpg create --organization $ORG --name GPG-ICINGA --key icinga.key
hammer product create --name='Icinga' --organization $ORG
hammer repository create --organization $ORG --name='Icinga 7Server' --product='Icinga' --content-type='yum' --gpg-key='GPG-ICINGA' --publish-via-http=true --url=http://packages.icinga.org/epel/7Server/release --download-policy immediate
#time hammer repository synchronize --organization "$ORG" --product 'Icinga 7Server' --name 'Icinga 7Server' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
fi
sudo touch RHTI/REQUESTICINGA
}

#-------------------------------
function REQUESTCENTOS7 {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "CentOS Linux 7.6:"
echo "*********************************************************"
read -n1 -t "$COUNTDOWN" -p "$QMESSAGEICENTOS7 ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
cd /root/Downloads
wget http://mirror.centos.org/centos/7.6.1810/os/x86_64/RPM-GPG-KEY-CentOS-7
hammer gpg create --organization $ORG --name RPM-GPG-KEY-CentOS-Linux-7.6 --key RPM-GPG-KEY-CentOS-7
hammer product create --name='CentOS Linux 7.6' --organization $ORG

hammer repository create --organization $ORG --name='CentOS Linux 7.6 (Kickstart)' --product='CentOS Linux 7.6' --content-type='yum' --gpg-key=RPM-GPG-KEY-CentOS-Linux-7.6 --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/os/x86_64/ 
time hammer repository synchronize --organization "$ORG" --product 'CentOS Linux 7.6' --name 'CentOS Linux 7.6 (Kickstart)' 2>/dev/null

hammer repository create --organization $ORG --name='CentOS Linux 7.6 CentOS Plus' --product='CentOS Linux 7.6' --content-type='yum' --gpg-key=RPM-GPG-KEY-CentOS-Linux-7.6 --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/centosplus/x86_64/ --checksum-type=sha256
time hammer repository synchronize --organization "$ORG" --product 'CentOS Linux 7.6' --name 'CentOS Linux 7.6 CentOSplus' 2>/dev/null

hammer repository create --organization $ORG --name='CentOS Linux 7.6 DotNET' --product='CentOS Linux 7.6' --content-type='yum' --gpg-key=RPM-GPG-KEY-CentOS-Linux-7.6 --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/dotnet/x86_64/ --checksum-type=sha256
time hammer repository synchronize --organization "$ORG" --product 'CentOS Linux 7.6' --name 'CentOS Linux 7.6 DotNET' 2>/dev/null

hammer repository create --organization $ORG --name='CentOS Linux 7.6 Extras' --product='CentOS Linux 7.6' --content-type='yum' --gpg-key=RPM-GPG-KEY-CentOS-Linux-7.6 --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/extras/x86_64/ --checksum-type=sha256
time hammer repository synchronize --organization "$ORG" --product 'CentOS Linux 7.6' --name 'CentOS Linux 7.6 Extras' 2>/dev/null

hammer repository create --organization $ORG --name='CentOS Linux 7.6 Fasttrack' --product='CentOS Linux 7.6' --content-type='yum' --gpg-key=RPM-GPG-KEY-CentOS-Linux-7.6 --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/fasttrack/x86_64/ --checksum-type=sha256
time hammer repository synchronize --organization "$ORG" --product 'CentOS Linux 7.6' --name 'CentOS Linux 7.6 Fasttrack' 2>/dev/null

hammer repository create --organization $ORG --name='CentOS Linux 7.6 Openshift-Origin' --product='CentOS Linux 7.6' --content-type='yum' --gpg-key=RPM-GPG-KEY-CentOS-Linux-7.6 --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/paas/x86_64/openshift-origin/ --checksum-type=sha256
time hammer repository synchronize --organization "$ORG" --product 'CentOS Linux 7.6' --name 'CentOS Linux 7.6 Openshift-Origin' 2>/dev/null

hammer repository create --organization $ORG --name='CentOS Linux 7.6 OpsTools' --product='CentOS Linux 7.6' --content-type='yum' --gpg-key=RPM-GPG-KEY-CentOS-Linux-7.6 --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/opstools/x86_64/ --checksum-type=sha256
time hammer repository synchronize --organization "$ORG" --product 'CentOS Linux 7.6' --name 'CentOS Linux 7.6 OpsTools' 2>/dev/null

hammer repository create --organization $ORG --name='CentOS Linux 7.6 Gluster 5' --product='CentOS Linux 7.6' --content-type='yum' --gpg-key=RPM-GPG-KEY-CentOS-Linux-7.6 --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/storage/x86_64/gluster-5/ --checksum-type=sha256
time hammer repository synchronize --organization "$ORG" --product 'CentOS Linux 7.6' --name 'CentOS Linux 7.6 Gluster 5' 2>/dev/null

hammer repository create --organization $ORG --name='CentOS Linux 7.6 Ceph-Luminous' --product='CentOS Linux 7.6' --content-type='yum' --gpg-key=RPM-GPG-KEY-CentOS-Linux-7.6 --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/storage/x86_64/ceph-luminous/ --checksum-type=sha256
time hammer repository synchronize --organization "$ORG" --product 'CentOS Linux 7.6' --name 'CentOS Linux 7.6 Ceph-Luminous' 2>/dev/null

hammer repository create --organization $ORG --name='CentOS Linux 7.6 Updates' --product='CentOS Linux 7.6' --content-type='yum' --gpg-key=RPM-GPG-KEY-CentOS-Linux-7.6 --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/updates/x86_64/ --checksum-type=sha256
time hammer repository synchronize --organization "$ORG" --product 'CentOS Linux 7.6' --name 'CentOS Linux 7.6 Updates' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
fi
sudo touch RHTI/REQUESTCENTOS7
}

#-------------------------------
function REQUESTSCIENTIFICLINUX {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "CentOS Linux 7.6:"
echo "*********************************************************"
read -n1 -t "$COUNTDOWN" -p "$QMESSAGEISCIENTIFICLINUX7 ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
cd /root/Downloads
wget http://mirror.cpsc.ucalgary.ca/mirror/scientificlinux.org/7x/x86_64/os/RPM-GPG-KEY-sl7

hammer gpg create --organization $ORG --name RPM-GPG-KEY-sl7 --key RPM-GPG-KEY-sl7
hammer product create --name='Scientific Linux 7.6' --organization $ORG

hammer repository create --organization $ORG --name='Scientific Linux 7.6 (Kickstart)' --product='Scientific Linux 7.6' --content-type='yum' --gpg-key='RPM-GPG-KEY-sl7' --publish-via-http=true --url=http://mirror.cpsc.ucalgary.ca/mirror/scientificlinux.org/7.6/x86_64/os/
time hammer repository synchronize --organization "$ORG" --product='Scientific Linux 7.6' --name='Scientific Linux 7.6 (Kickstart)' 2>/dev/null

hammer repository create --organization $ORG --name='Scientific Linux 7.6 Updates Fastbugs' --product='Scientific Linux 7.6' --content-type='yum' --gpg-key='RPM-GPG-KEY-sl7' --publish-via-http=true --url=http://mirror.cpsc.ucalgary.ca/mirror/scientificlinux.org/7.6/x86_64/updates/fastbugs/
time hammer repository synchronize --organization "$ORG" --product='Scientific Linux 7.6' --name='Scientific Linux 7.6 Updates Fastbugs' 2>/dev/null

hammer repository create --organization $ORG --name='Scientific Linux 7.6 Updates Security' --product='Scientific Linux 7.6' --content-type='yum' --gpg-key='RPM-GPG-KEY-sl7' --publish-via-http=true --url=http://mirror.cpsc.ucalgary.ca/mirror/scientificlinux.org/7.6/x86_64/updates/security/
time hammer repository synchronize --organization "$ORG" --product='Scientific Linux 7.6'--name 'Scientific Linux 7.6 Updates Security' 2>/dev/null

hammer repository create --organization $ORG --name='Scientific Linux 7.6 External Products Extras' --product='Scientific Linux 7.6' --content-type='yum' --gpg-key='RPM-GPG-KEY-sl7' --publish-via-http=true --url=http://mirror.cpsc.ucalgary.ca/mirror/scientificlinux.org/7x/external_products/extras/x86_64/
time hammer repository synchronize --organization "$ORG" --product='Scientific Linux 7.6' --name='Scientific Linux 7.6 External Products Extras' 2>/dev/null

hammer repository create --organization $ORG --name='Scientific Linux 7.6 External Products HC' --product='Scientific Linux 7.6' --content-type='yum' --gpg-key='RPM-GPG-KEY-sl7' --publish-via-http=true --url=http://mirror.cpsc.ucalgary.ca/mirror/scientificlinux.org/7x/external_products/hc/x86_64/
time hammer repository synchronize --organization "$ORG" --product='Scientific Linux 7.6' --name='Scientific Linux 7.6 External Products HC' 2>/dev/null

hammer repository create --organization $ORG --name='Scientific Linux 7.6 Software Collections' --product='Scientific Linux 7.6' --content-type='yum' --gpg-key='RPM-GPG-KEY-sl7' --publish-via-http=true --url=http://mirror.cpsc.ucalgary.ca/mirror/scientificlinux.org/7x/external_products/softwarecollections/x86_64/
time hammer repository synchronize --organization "$ORG" --product='Scientific Linux 7.6' --name='Scientific Linux 7.6 Software Collections' 2>/dev/null

hammer repository create --organization $ORG --name='Scientific Linux 7.6 3rd Party Repos' --product='Scientific Linux 7.6' --content-type='yum' --gpg-key='RPM-GPG-KEY-sl7' --publish-via-http=true --url=http://mirror.cpsc.ucalgary.ca/mirror/scientificlinux.org/7x/repos/x86_64/
time hammer repository synchronize --organization "$ORG" --product='Scientific Linux 7.6' --name='Scientific Linux 7.6 3rd Party Repos' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
fi
sudo touch RHTI/REQUESTSCIENTIFICLINUX
}

#-------------------------------
function SYNC {
#------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "SYNC ALL REPOSITORIES (WAIT FOR THIS TO COMPLETE BEFORE CONTINUING):"
echo "*********************************************************"
for i in $(hammer --csv repository list |grep -i kickstart | awk -F ',' '{print $1}') ; do hammer repository update --id $i --download-policy immediate ; done
for i in $(hammer --csv repository list --organization $ORG | awk -F, {'print $1'} | grep -vi '^ID' |grep -v -i puppet); do hammer repository synchronize --id ${i} --organization $ORG --async; done

sleep 1
echo " "
sudo touch RHTI/SYNC
pkill firfox
}

#-------------------------------
function SYNCMSG {
#------------------------------
if ! xset q &>/dev/null; then
echo "No X server at \$DISPLAY [$DISPLAY]" >&2
echo 'In a system browser please goto the URL to view progress https://$(hostname)/katello/sync_management'
sleep 10
else 
firefox https://$(hostname)/katello/sync_management &
fi
echo " "
sudo touch RHTI/SYNCMSG
}

#-------------------------------
function PRIDOMAIN {
#------------------------------
for i in $(hammer --csv domain list |grep -v Id | awk -F ',' '{print $1}') ; do hammer domain update --id $i ; done
sudo touch RHTI/PRIDOMAIN
}

#-------------------------------
function CREATESUBNET {
#------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "CREATE THE FIRST OR PRIMARY SUBNET TO CONNECT THE NODES TO THE SATELLITE:"
echo "*********************************************************"
echo " "
hammer subnet create --name $SUBNET_NAME --network $INTERNALNETWORK --mask $SUBNET_MASK --gateway $DHCP_GW --dns-primary $DNS --ipam 'Internal DB' --from $SUBNET_IPAM_BEGIN --to $SUBNET_IPAM_END --tftp-id 1 --dhcp-id 1 --domain-ids 1 --organizations $ORG --locations "$LOC"
sudo touch RHTI/CREATESUBNET
}

#-------------------------------
function ENVIRONMENTS {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "CREATE ENVIRONMENTS DEV_RHEL->TEST_RHEL->PROD_RHEL:"
echo "*********************************************************"
echo "DEVLOPMENT_RHEL_7"
hammer lifecycle-environment create --name='DEV_RHEL_7' --prior='Library' --organization $ORG
echo "TEST_RHEL_7"
hammer lifecycle-environment create --name='TEST_RHEL_7' --prior='DEV_RHEL_7' --organization $ORG
echo "PRODUCTION_RHEL_7"
hammer lifecycle-environment create --name='PROD_RHEL_7' --prior='TEST_RHEL_7' --organization $ORG
echo "DEVLOPMENT_RHEL_8"
hammer lifecycle-environment create --name='DEV_RHEL_8' --prior='Library' --organization $ORG
echo "TEST_RHEL_8"
hammer lifecycle-environment create --name='TEST_RHEL_8' --prior='DEV_RHEL_8' --organization $ORG
echo "PRODUCTION_RHEL_8"
hammer lifecycle-environment create --name='PROD_RHEL_8' --prior='TEST_RHEL_8' --organization $ORG
#echo "DEVLOPMENT_RHEL_6"
#hammer lifecycle-environment create --name='DEV_RHEL_6' --prior='Library' --organization $ORG
#echo "TEST_RHEL_6"
#hammer lifecycle-environment create --name='TEST_RHEL_6' --prior='DEV_RHEL_6' --organization $ORG
#echo "PRODUCTION_RHEL_6"
#hammer lifecycle-environment create --name='PROD_RHEL_6' --prior='TEST_RHEL_6' --organization $ORG
#echo "DEVLOPMENT_RHEL_5"
#hammer lifecycle-environment create --name='DEV_RHEL_5' --prior='Library' --organization $ORG
#echo "TEST_RHEL_5"
#hammer lifecycle-environment create --name='TEST_RHEL_5' --prior='DEV_RHEL_5' --organization $ORG
#echo "PRODUCTION_RHEL_5"
#hammer lifecycle-environment create --name='PROD_RHEL_5' --prior='TEST_RHEL_5' --organization $ORG
#echo "DEVLOPMENT_CentOS_7"
#hammer lifecycle-environment create --name='DEV_CentOS_7' --prior='Library' --organization $ORG
#echo "TEST_CentOS_7"
#hammer lifecycle-environment create --name='TEST_CentOS_7' --prior='DEV_CentOS_7' --organization $ORG
#echo "PRODUCTION_CentOS_7"
#hammer lifecycle-environment create --name='PROD_CentOS_7' --prior='TEST_CentOS_7' --organization $ORG
#echo " "
#hammer lifecycle-environment list --organization $ORG
#echo " "
sudo touch RHTI/ENVIRONMENTS
}

#-------------------------------
function SYNCPLANS {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "Create a daily sync plan:"
echo "*********************************************************"
hammer sync-plan create --name 'Daily_Sync' --description 'Daily Synchronization Plan' --organization $ORG --interval daily --sync-date $(date +"%Y-%m-%d")" 00:00:00" --enabled no
hammer sync-plan create --name 'Weekly_Sync' --description 'Weekly Synchronization Plan' --organization $ORG --interval weekly --sync-date $(date +"%Y-%m-%d")" 00:00:00" --enabled yes
#hammer sync-plan create --name 'Scientific Linux 7.6 Weekly Sync' --description 'Weekly Sync sl_76 Plan' --organization $ORG --interval weekly --sync-date $(date +"%Y-%m-%d")" 00:00:00" --enabled yes
hammer sync-plan list --organization $ORG
echo " "
sudo touch RHTI/SYNCPLANS
}

#-------------------------------
function SYNCPLANCOMPONENTS {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
for i in $(hammer --csv product list --enabled yes --organization $ORG |grep -v "-" |grep -v ID| awk -F ',' '{print $1}') ; do hammer product set-sync-plan --id $i --organization $ORG --sync-plan 'Weekly_Sync' ; done
sudo touch RHTI/SYNCPLANCOMPONENTS
}

#-------------------------------
function ASSOCPLANTOPRODUCTS {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "Associate plan to products:"
echo "*********************************************************"
for i in $(hammer --csv product list --enabled yes --organization $ORG |grep -v "-" |grep -v ID| awk -F ',' '{print $1}') ; do hammer product set-sync-plan --sync-plan-id=2 --organization $ORG --id=$i; done
#hammer product set-sync-plan --sync-plan-id=$(hammer --csv sync-plan list --organization $ORG |grep 'Scientific Linux 7.6 Weekly Sync'|awk -F ',' '{print $1}') --organization $ORG --name='Scientific Linux 7.6'
sudo touch RHTI/ASSOCPLANTOPRODUCTS
}

#-------------------------------
function CONTENTVIEWS {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "***********************************************"
echo "Create a content view for CentOS Linux 7.6:"
echo "***********************************************"
#hammer content-view create --name='RHEL7-server-x86_64' --organization $ORG
#sleep 10
#for i in $(hammer --csv repository list --organization $ORG | awk -F, {'print $1'} | grep -vi '^ID'); do hammer content-view add-repository --name RHEL7-Base --organization $ORG --repository-id=${i}; done 
hammer content-view create --organization $ORG --name 'CentOS 7' --label 'CentOS7' --description 'CentOS 7'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS Linux 7.6' --repository 'CentOS Linux 7.6 (Kickstart)'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS Linux 7.6' --repository 'CentOS Linux 7.6 Gluster 5'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS Linux 7.6' --repository 'CentOS Linux 7.6 Extras'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS Linux 7.6' --repository 'CentOS Linux 7.6 ISO'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS Linux 7.6' --repository 'CentOS Linux 7.6 Openshift-Origin'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS Linux 7.6' --repository 'CentOS Linux 7.6 DotNET'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS Linux 7.6' --repository 'CentOS Linux 7.6 CentOSplus'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS Linux 7.6' --repository 'CentOS Linux 7.6 Ceph-Luminous'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS Linux 7.6' --repository 'CentOS Linux 7.6 Fasttrack'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS Linux 7.6' --repository 'CentOS Linux 7.6 OpsTools'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS Linux 7.6' --repository 'CentOS Linux 7.6 Updates'
time hammer content-view publish --organization $ORG --name 'CentOS 7' --description 'Initial Publishing' 2>/dev/null
time hammer content-view version promote --organization $ORG --content-view 'CentOS 7' --to-lifecycle-environment DEV_CentOS_7 2>/dev/null
echo "***********************************************"
echo "CREATE A CONTENT VIEW FOR RHEL 7:"
echo "***********************************************"
hammer content-view create --organization $ORG --name 'RHEL7' --label RHEL7 --description 'RHEL 7'
hammer content-view add-repository --organization $ORG --name 'RHEL7' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server Kickstart x86_64 7.7'
hammer content-view add-repository --organization $ORG --name 'RHEL7' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Satellite Tools 6.7 for RHEL7 Server RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7' --product 'Red Hat Software Collections for RHEL Server' --repository 'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Supplementary RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - RH Common RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Optional RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Extras RPMs x86_64'
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7' --author puppetlabs --name stdlib
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7' --author puppetlabs --name concat
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7' --author puppetlabs --name ntp
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7' --author saz --name ssh
time hammer content-view publish --organization $ORG --name 'RHEL7' --description 'Initial Publishing' 2>/dev/null
time hammer content-view version promote --organization $ORG --content-view 'RHEL7' --to-lifecycle-environment DEV_RHEL_7 2>/dev/null
echo "***********************************************"
echo "CREATE A CONTENT VIEW FOR RHEL 7 CAPSULES:"
echo "***********************************************"
hammer content-view create --organization $ORG --name 'RHEL7-Capsule' --label 'RHEL7-Capsule' --description 'Satellite Capsule'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Capsule' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Capsule' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server Kickstart x86_64 7.7'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Capsule' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Satellite Tools 6.7 for RHEL 7 Server RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Capsule' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Optional RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Capsule' --product 'Red Hat Software Collections for RHEL Server' --repository 'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Capsule' --product 'Red Hat Satellite Capsule' --repository 'Red Hat Satellite Capsule 6.7 for RHEL 7 Server RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Capsule' --product 'Red Hat Satellite Capsule' --repository 'Red Hat Satellite Capsule 6.7 - Puppet 4 for RHEL 7 Server RPMs x86_64'
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Capsule' --author puppetlabs --name stdlib
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Capsule' --author puppetlabs --name concat
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Capsule' --author puppetlabs --name ntp
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Capsule' --author saz --name ssh
time hammer content-view publish --organization $ORG --name 'RHEL7-Capsule' --description 'Initial Publishing' 2>/dev/null
time hammer content-view version promote --organization $ORG --content-view 'RHEL7-Capsule' --to-lifecycle-environment DEV_RHEL_7 2>/dev/null
echo "***********************************************"
echo "CREATE A CONTENT VIEW FOR RHEL 7 Hypervisor:"
echo "***********************************************"
hammer content-view create --organization $ORG --name 'RHEL7-Hypervisor' --label 'RHEL7-Hypervisor' --description ''
hammer content-view add-repository --organization $ORG --name 'RHEL7-Hypervisor' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Hypervisor' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Satellite Tools 6.7 for RHEL 7 Server RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Hypervisor' --product 'Red Hat Virtualization' --repository 'Red Hat Virtualization 4 Management Agents for RHEL 7 RPMs x86_64 7Server'
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Hypervisor' --author puppetlabs --name stdlib
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Hypervisor' --author puppetlabs --name concat
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Hypervisor' --author puppetlabs --name ntp
time hammer content-view publish --organization $ORG --name 'RHEL7-Hypervisor' --description 'Initial Publishing' 2>/dev/null
time hammer content-view version promote --organization $ORG --content-view 'RHEL7-Hypervisor' --to-lifecycle-environment DEV_RHEL_7 2>/dev/null
echo "***********************************************"
echo "CREATE A CONTENT VIEW FOR RHEL 7 Builder:"
echo "***********************************************"
hammer content-view create --organization $ORG --name 'RHEL7-Builder' --label RHEL7-Builder --description 'RHEL7-Builder'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server Kickstart x86_64 7.7'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Satellite Tools 6.7 for RHEL 7 Server RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'Red Hat Software Collections for RHEL Server' --repository 'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Supplementary RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - RH Common RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Optional RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Extras RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'JBoss Enterprise Application Platform' --repository 'JBoss Enterprise Application Platform 7 RHEL 7 Server RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'Maven' --repository 'Maven 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'EPEL' --repository 'EPEL 7 - x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product $ORG --repository "Packages"
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product $ORG --repository "Jenkins"
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Builder' --author puppetlabs --name stdlib
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Builder' --author puppetlabs --name concat
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Builder' --author puppetlabs --name ntp
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Builder' --author saz --name ssh
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Builder' --author puppetlabs --name postgresql
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Builder' --author puppetlabs --name java
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Builder' --author rtyler --name jenkins
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Builder' --author camptocamp --name archive
time hammer content-view publish --organization $ORG --name 'RHEL7-Builder' --description 'Initial Publishing'
time hammer content-view version promote --organization $ORG --content-view 'RHEL7-Builder' --to-lifecycle-environment DEV_RHEL_7
echo "***********************************************"
echo "CREATE A CONTENT VIEW FOR RHEL 7 OSCP:"
echo "***********************************************"
hammer content-view create --organization $ORG --name 'RHEL7-Oscp' --label 'RHEL7-Oscp' --description ''
hammer content-view add-repository --organization $ORG --name 'RHEL7-Oscp' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Oscp' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Satellite Tools 6.7 for RHEL 7 Server RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Oscp' --product 'Red Hat Software Collections for RHEL Server' --repository 'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Oscp' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Optional RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Oscp' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Extras RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Oscp' --product 'Red Hat OpenShift Container Platform' --repository 'Red Hat OpenShift Container Platform 3.9 RPMs x86_64'
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Oscp' --author puppetlabs --name stdlib
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Oscp' --author puppetlabs --name concat
hammer content-view puppet-module add --organization $ORG --conten30t-view 'RHEL7-Oscp' --author puppetlabs --name ntp
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Oscp' --author saz --name ssh
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Oscp' --author cristifalcas --name kubernetes
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Oscp' --author cristifalcas --name etcd
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Oscp' --author LunetIX --name docker
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Oscp' --author crayfishx --name firewalld
time hammer content-view publish --organization $ORG --name 'RHEL7-Oscp' --description 'Initial Publishing'
time hammer content-view version promote --organization $ORG --content-view 'RHEL7-Oscp' --to-lifecycle-environment DEV_RHEL_7
echo "***********************************************"
echo "CREATE A CONTENT VIEW FOR RHEL 7 DOCKER:"
echo "***********************************************"
hammer content-view create --organization $ORG --name 'RHEL7-Docker' --label 'RHEL7-Docker' --description ''
hammer content-view add-repository --organization $ORG --name 'RHEL7-Docker' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Docker' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Satellite Tools 6.7 for RHEL 7 Server RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Docker' --product 'Red Hat Software Collections for RHEL Server' --repository 'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Docker' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Optional RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Docker' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Extras RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Docker' --product 'Red Hat OpenShift Container Platform' --repository 'Red Hat OpenShift Container Platform 3.9 RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Docker' --product 'JBoss Enterprise Application Platform' --repository 'JBoss Enterprise Application Platform 7 RHEL 7 Server RPMs x86_64 7Server'
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Docker' --author puppetlabs --name stdlib
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Docker' --author puppetlabs --name concat
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Docker' --author puppetlabs --name ntp
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Docker' --author saz --name ssh
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Docker' --author cristifalcas --name kubernetes
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Docker' --author cristifalcas --name etcd
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Docker' --author cristifalcas --name docker
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Docker' --author crayfishx --name firewalld
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Docker' --author LunetIX --name dockerhost
time hammer content-view publish --organization $ORG --name 'RHEL7-Docker' --description 'Initial Publishing'
time hammer content-view version promote --organization $ORG --content-view 'RHEL7-Docker' --to-lifecycle-environment DEV_RHEL_7
echo '#-------------------------------'
echo 'RHEL6 CONTENT VIEW'
echo '#-------------------------------'
hammer content-view create --organization $ORG --name 'RHEL6' --label 'RHEL6' --description 'Core Build for RHEL 6'
hammer content-view add-repository --organization $ORG --name 'RHEL6_Base' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 6 Server RPMs x86_64 6Server'
hammer content-view add-repository --organization $ORG --name 'RHEL6_Base' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Satellite Tools 6.7 for RHEL 6 Server RPMs x86_64'
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL6_Base' --author puppetlabs --name stdlib
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL6_Base' --author puppetlabs --name concat
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL6_Base' --author puppetlabs --name ntp
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL6_Base' --author saz --name ssh
time hammer content-view publish --organization $ORG --name 'RHEL6_Base' --description 'Initial Publishing' 2>/dev/null
time hammer content-view version promote --organization $ORG --content-view 'RHEL6_Base' --to-lifecycle-environment DEV_RHEL_6 2>/dev/null
echo '#-------------------------------'
echo 'RHEL5 CONTENT VIEW'
echo '#-------------------------------'
hammer content-view create --organization $ORG --name 'RHEL5_Base' --label 'RHEL5_Base' --description 'Core Build for RHEL 5'
hammer content-view add-repository --organization $ORG --name 'RHEL5_Base' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 5 Server RPMs x86_64 6Server'
hammer content-view add-repository --organization $ORG --name 'RHEL5_Base' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Satellite Tools 6.7 for RHEL 5 Server RPMs x86_64'
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL5_Base' --author puppetlabs --name stdlib
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL5_Base' --author puppetlabs --name concat
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL5_Base' --author puppetlabs --name ntp
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL5_Base' --author saz --name ssh
time hammer content-view publish --organization $ORG --name 'RHEL5_Base' --description 'Initial Publishing' 2>/dev/null
time hammer content-view version promote --organization $ORG --content-view 'RHEL5_Base' --to-lifecycle-environment DEV_RHEL_5 2>/dev/null
sudo touch RHTI/CONTENTVIEWS
}

#-------------------------------
function PUBLISHRHEL7CONTENT {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "***********************************************"
echo "CREATE A CONTENT VIEW FOR RHEL 7"
echo "***********************************************"
read -n1 -t "$COUNTDOWN" -p "$QMESSAGE7 ? Y/N " INPUT
INPUT=${INPUT:-$RHEL7DEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer content-view create --organization $ORG --name 'RHEL_7_x86_64' --label RHEL_7_x86_64 --description 'RHEL 7'
hammer content-view add-repository --organization $ORG --name 'RHEL_7_x86_64' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL_7_x86_64' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server Kickstart x86_64 7.7'
hammer content-view add-repository --organization $ORG --name 'RHEL_7_x86_64' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Satellite Tools 6.7 for RHEL 7 Server RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL_7_x86_64' --product 'Red Hat Software Collections for RHEL Server' --repository 'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL_7_x86_64' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Supplementary RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL_7_x86_64' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - RH Common RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL_7_x86_64' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Optional RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL_7_x86_64' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Extras RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL_7_x86_64' --product 'Extra Packages for Enterprise Linux 7' --repository 'Extra Packages for Enterprise Linux 7'
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL_7_x86_64' --author puppetlabs --name stdlib
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL_7_x86_64' --author puppetlabs --name concat
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL_7_x86_64' --author puppetlabs --name ntp
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL_7_x86_64' --author saz --name ssh
time hammer content-view publish --organization $ORG --name 'RHEL_7_x86_64' --description 'Initial Publishing' 2>/dev/null
time hammer content-view version promote --organization $ORG --content-view 'RHEL_7_x86_64' --from-lifecycle-environment Library  --to-lifecycle-environment DEV_RHEL_7 2>/dev/null
time hammer content-view version promote --organization $ORG --content-view 'RHEL_7_x86_64' --from-lifecycle-environment DEV_RHEL_7 --to-lifecycle-environment TEST_RHEL_7 2>/dev/null
time hammer content-view version promote --organization $ORG --content-view 'RHEL_7_x86_64' --from-lifecycle-environment TEST_RHEL_7--to-lifecycle-environment PROD_RHEL_7 2>/dev/null
sudo touch RHTI/PUBLISHRHEL8CONTENT
fi
}

#-------------------------------
function PUBLISHRHEL8CONTENT {
#-------------------------------
read -n1 -t "$COUNTDOWN" -p "$QMESSAGE8 ? Y/N " INPUT
INPUT=${INPUT:-$RHEL7DEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
echo "***********************************************"
echo "CREATE A CONTENT VIEW FOR RHEL 8"
echo "***********************************************"
hammer content-view create --organization $ORG --name 'RHEL_8_x86_64' --label RHEL_8_x86_64 --description 'RHEL 8'
hammer content-view add-repository --organization $ORG --name 'RHEL_8_x86_64' --product 'Red Hat Enterprise Linux for x86_64' --repository 'Red Hat Enterprise Linux 8 for x86_64 - AppStream Kickstart x86_64 8.1'
hammer content-view add-repository --organization $ORG --name 'RHEL_8_x86_64' --product 'Red Hat Enterprise Linux for x86_64' --repository 'Red Hat Enterprise Linux 8 for x86_64 - AppStream RPMs x86_64 8.1'
hammer content-view add-repository --organization $ORG --name 'RHEL_8_x86_64' --product 'Red Hat Enterprise Linux for x86_64' --repository 'Red Hat Enterprise Linux 8 for x86_64 - BaseOS Kickstart x86_64 8.1'
hammer content-view add-repository --organization $ORG --name 'RHEL_8_x86_64' --product 'Red Hat Enterprise Linux for x86_64' --repository 'Red Hat Enterprise Linux 8 for x86_64 - BaseOS RPMs x86_64 8.1'
hammer content-view add-repository --organization $ORG --name 'RHEL_8_x86_64' --product 'Red Hat Enterprise Linux for x86_64' --repository 'Red Hat Satellite Tools 6.7 for RHEL 8 x86_64 RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL_8_x86_64' --product 'Red Hat Enterprise Linux for x86_64' --repository 'Red Hat Enterprise Linux 8 for x86_64 - Supplementary RPMs x86_64 8.1'
hammer content-view add-repository --organization $ORG --name 'RHEL_8_x86_64' --product 'Extra Packages for Enterprise Linux 8' --repository 'Extra Packages for Enterprise Linux 8'
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL_8_x86_64' --author puppetlabs --name stdlib
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL_8_x86_64' --author puppetlabs --name concat
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL_8_x86_64' --author puppetlabs --name ntp
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL_8_x86_64' --author saz --name ssh
time hammer content-view publish --organization $ORG --name 'RHEL_8_x86_64' --description 'Initial Publishing' 2>/dev/null
time hammer content-view version promote --organization $ORG --content-view 'RHEL_8_x86_64' --from-lifecycle-environment Library  --to-lifecycle-environment DEV_RHEL_8 2>/dev/null
time hammer content-view version promote --organization $ORG --content-view 'RHEL_8_x86_64' --from-lifecycle-environment DEV_RHEL_8 --to-lifecycle-environment TEST_RHEL_8 2>/dev/null
time hammer content-view version promote --organization $ORG --content-view 'RHEL_8_x86_6' --from-lifecycle-environment TEST_RHEL_8 --to-lifecycle-environment PROD_RHEL_8 2>/dev/null
sudo touch RHTI/PUBLISHRHEL8CONTENT
fi
}

#-------------------------------
#function PUBLISHCONTENT {
#-------------------------------
#source /root/.bashrc
#echo -ne "\e[8;40;170t"
#echo " "
#echo "********************************"
#echo "Publish content view to Library:"
#echo "********************************"
#echo " "
#echo "********************************"
#echo "
# There may be an error that the (content-view publish) task has failed however the process takes longer to complete than the command timeout.
#Please see https://$(hostname)/content_views/2/versions to watch the task complete.“
# echo "********************************"
# echo " "
# hammer content-view publish --name 'rhel-7-server-x86_64' --organization $ORG --async
# sleep 1000
# echo " "
# echo "*********************************************************"
# echo "Promote content views to DEV_RHEL,TEST_RHEL,PROD_RHEL:"
# echo "*********************************************************"
# hammer content-view version promote --organization $ORG --from-lifecycle-environment ='Library' --to-lifecycle-environment 'DEV_RHEL' --id 2 --async
# sleep 700
# hammer content-view version promote --organization $ORG --from-lifecycle-environment ='DEV_RHEL' --to-lifecycle-environment 'TEST_RHEL' --id 2 --async
# sleep 700
# hammer content-view version promote --organization $ORG --from-lifecycle-environment ='TEST_RHEL' --to-lifecycle-environment 'PROD_RHEL' --id 2 --async
# sleep 700
#sudo touch RHTI/PUBLISHCONTENT
#}

#-------------------------------
function HOSTCOLLECTION {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "***********************************"
echo "Create a host collection for RHEL:"
echo "***********************************"
hammer host-collection create --name='RHEL_7_x86_64' --organization $ORG
hammer host-collection create --name='RHEL_8_x86_64' --organization $ORG
sleep 10
sudo touch RHTI/HOSTCOLLECTION
}

#-------------------------------
function KEYSFORENV {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "Create an activation keys for environments:"
echo "*********************************************************"
hammer activation-key create --name 'DEV_RHEL_7' --organization $ORG --content-view='RHEL_7_x86_64' --lifecycle-environment 'DEV_RHEL_7'
hammer activation-key create --name 'TEST_RHEL_7' --organization $ORG --content-view='RHEL_7_x86_64' --lifecycle-environment 'TEST_RHEL_7'
hammer activation-key create --name 'PROD_RHEL_7' --organization $ORG --content-view='RHEL_7_x86_64' --lifecycle-environment 'PROD_RHEL_7'

hammer activation-key create --name 'DEV_RHEL_8' --organization $ORG --content-view='RHEL_8_x86_64' --lifecycle-environment 'DEV_RHEL_8'
hammer activation-key create --name 'TEST_RHEL_8' --organization $ORG --content-view='RHEL_8_x86_64' --lifecycle-environment 'TEST_RHEL_8'
hammer activation-key create --name 'PROD_RHEL_8' --organization $ORG --content-view='RHEL_8_x86_64' --lifecycle-environment 'PROD_RHEL_8'sudo touch RHTI/KEYSFORENV
}

#-------------------------------
function KEYSTOHOST {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "Associate each activation key to host collection:"
echo "*********************************************************"
for i in $(hammer activation-key list --organization $ORG |grep -v ID |grep -v '-' |awk -F '|' '{print $2}' | grep RHEL_7); do hammer activation-key add-host-collection --name $i --host-collection='RHEL_7_x86_64' --organization $ORG; done
sleep 1
for i in $(hammer activation-key list --organization $ORG |grep -v ID |grep -v '-' |awk -F '|' '{print $2}' | grep RHEL_8); do hammer activation-key add-host-collection --name $i --host-collection='RHEL_8_x86_64' --organization $ORG; done
sleep 1
sudo touch RHTI/KEYSTOHOST
}

#-------------------------------
function SUBTOKEYS {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo " "
echo "*********************************************************"
echo "Add all subscriptions available to keys:"
echo "*********************************************************"
for i in $(hammer --csv activation-key list --organization $ORG | awk -F "," {'print $1'} | grep -vi '^ID'); do for j in $(hammer --csv subscription list --organization $ORG | awk -F "," {'print $1'} | grep -vi '^ID'); do hammer activation-key add-subscription --id ${i} --subscription-id ${j}; done; done
echo " "
echo "*********************************************************"
echo "Enable all the base content for each OS by default:"
echo "*********************************************************"
for i in $(hammer activation-key list --organization $ORG | grep -v ID | grep -v '-' | awk -F '|' '{print $1}') ; do hammer activation-key product-content --content-access-mode-all true --organization $ORG  --id $i ;done
sudo touch RHTI/SUBTOKEYS
}

#-------------------------------
function MEDIUM {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "Create Media:"
echo "*********************************************************"
#RHEL 7
hammer medium create --path=http://repos/${ORG}/Library/content/dist/rhel/server/7/7.6/x86_64/kickstart/ --organizations=$ORG --os-family=Redhat --name="RHEL 7.6 Kickstart" --operatingsystems="RedHat 7.6"
hammer medium create --path=http://repos/${ORG}/Library/content/dist/rhel/server/7/7.7/x86_64/kickstart/ --organizations=$ORG --os-family=Redhat --name="RHEL 7.7 Kickstart" --operatingsystems="RedHat 7.7"

#RHEL 8
hammer medium create --path=http://repos/${ORG}/Library/content/dist/rhel8/8.0/x86_64/baseos/kickstart --organizations=$ORG --os-family=Redhat --name="RHEL 8.0 Kickstart" --operatingsystems="RedHat 8.0"
hammer medium create --path=http://repos/${ORG}/Library/content/dist/rhel8/8.1/x86_64/baseos/kickstart --organizations=$ORG --os-family=Redhat --name="RHEL 8.1 Kickstart" --operatingsystems="RedHat 8.1"
sudo touch RHTI/MEDIUM
}

#----------------------------------
function VARSETUP2 {
#----------------------------------
echo "*********************************************************"
echo "CREATING THE NEXT SET OF VARIABLES."
echo "*********************************************************"
source /root/.bashrc
echo -ne "\e[8;40;170t"

ENVIROMENT=$(hammer --csv environment list |awk -F "," {'print $2'}|grep -v Name |grep -v production)
LEL=$(hammer --csv lifecycle-environment list |awk -F "," {'print $2'} |grep -v NAME)
echo "CAID=1" >> /root/.bashrc
echo "MEDID1=$(hammer --csv medium list |grep 'RHEL 7.7' |awk -F "," {'print $1'} |grep -v Id)" >> /root/.bashrc
#echo "MEDID2=$(hammer --csv medium list |grep 'CentOS 7' |awk -F "," {'print $1'} |grep -v Id)" >> /root/.bashrc
echo "SUBNETID=$(hammer --csv subnet list |awk -F "," {'print $1'}| grep -v Id)" >> /root/.bashrc
echo "OSID1=$(hammer os list |grep -i "RedHat 7.7" |awk -F "|" {'print $1'})" >> /root/.bashrc
#echo "OSID2=$(hammer os list |grep -i "CentOS 7.7" |awk -F "|" {'print $1'})" >> /root/.bashrc
echo "PROXYID=$(hammer --csv proxy list |awk -F "," {'print $1'} |grep -v Id)" >> /root/.bashrc
echo "PARTID=$(hammer --csv partition-table list | grep "Kickstart default" | grep -i -v thin |cut -d, -f1)" >> /root/.bashrc
echo "PXEID=$(hammer --csv template list --per-page=1000 | grep "Kickstart default PXELinux" | cut -d, -f1)" >> /root/.bashrc
echo "SATID=$(hammer --csv template list --per-page=1000 | grep ",Kickstart default,provision" | grep "Kickstart default" | cut -d, -f1)" >> /root/.bashrc
echo "ORGID=$(hammer --csv organization list|awk -F "," {'print $1'}|grep -v Id)" >> /root/.bashrc
echo "LOCID=$(hammer --csv location list|awk -F "," {'print $1'} |grep -v Id)" >> /root/.bashrc
echo "ARCH=$(uname -i)" >> /root/.bashrc
echo "ARCHID=$(hammer --csv architecture list|grep x86_64 |awk -F "," {'print $1'})" >> /root/.bashrc
echo "DOMID=$(hammer --csv domain list |grep -v Id |grep -v Name |awk -F "," {'print $1'})" >> /root/.bashrc
echo "SUBNETID=$(hammer --csv subnet list |awk -F "," {'print $1'}| grep -v Id)" >> /root/.bashrc
echo "CVID=$(hammer --csv content-view list --organization $ORG |grep 'RHEL 7' |awk -F "," {'print $1'})" >> /root/.bashrc
echo "*********************************************************"
echo "VERIFY VARIABLES IN /root/.bashrc"
echo "*********************************************************"
cat /root/.bashrc
echo " "
sleep 1
read -p "Press [Enter] to continue"
sudo touch RHTI/VARSETUP2
}

#-----------------------------------
function PARTITION_OS_PXE_TEMPLATE {
#-----------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "Setting Default Templates."
echo "*********************************************************"
for i in $OSID
do
hammer partition-table add-operatingsystem --id="${PARTID}" --operatingsystem-id="${i}"
hammer template add-operatingsystem --id="${PXEID}" --operatingsystem-id="${i}"
hammer os set-default-template --id="${i}" --config-template-id="${PXEID}"
hammer os add-config-template --id="${i}" --config-template-id="${SATID}"
hammer os set-default-template --id="${i}" --config-template-id="${SATID}"
done
sudo touch RHTI/PARTITION_OS_PXE_TEMPLATE
}

#-------------------------------
function HOSTGROUPS {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "Create a RHEL hostgroup(s):"
echo "*********************************************************"
#MAKES ROOTPASSWORD ON NODES rreeddhhaatt BECAUSE THE SYSTEM REQUIRES IT TO BE 8+ CHAR (--root-pass rreeddhhaatt)
ENVIROMENT=$(hammer --csv lifecycle-environment list |awk -F "," {'print $2'}|grep -v Name |grep -v production)
LEL=$(hammer --csv environment list |awk -F "," {'print $2'}|grep -v Name)
for i in $LEL; do for j in $(hammer --csv environment list |awk -F "," {'print $2'}| awk -F "_" {'print $1'}|grep -v Name); do hammer hostgroup create --name RHEL-7.7-$j --puppet-environments $i --architecture-id $ARCHID --content-view-id $CVID --domain-id $DOMID --location-ids $LOCID --medium-id $MEDID1 --operatingsystem-id $OSID1 --organization-id=$ORGID --partition-table-id $PARTID --puppet-ca-proxy-id $PROXYID --subnet-id $SUBNETID --root-pass=rreeddhhaatt ; done; done
#for i in $LEL; do for j in $(hammer --csv environment list |awk -F "," {'print $2'}| awk -F "_" {'print $1'}|grep -v Name); do hammer hostgroup create --name CentOS Linux 7.6-$j --puppet-environments $i --architecture-id $ARCHID --content-view-id $CVID --domain-id $DOMID --location-ids $LOCID --medium-id $MEDID2 --operatingsystem-id $OSID2 --organization-id=$ORGID --partition-table-id $PARTID --puppet-ca-proxy-id $PROXYID --subnet-id $SUBNETID --root-pass=redhat ; done; done
sudo touch RHTI/HOSTGROUPS
}

#-------------------------------
function MODPXELINUXDEF {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "Setting up and Modifying default template for auto discovery"
echo "*********************************************************"
#sed -i 's/SATELLITE_CAPSULE_URL/'$(hostname)'/g' /usr/share/foreman/app/views/unattended/pxe/PXELinux_default.erb
#hammer template update --id 1
sudo touch RHTI/MODPXELINUXDEF
}

#-------------------------------
function ADD_OS_TO_TEMPLATE {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "ASSOCIATE OS TO TEMPLATE"
echo "*********************************************************"
hammer template add-operatingsystem --operatingsystem-id 1 --id 1
sudo touch RHTI/ADD_OS_TO_TEMPLATE
}

#------------------------------
function SATREENABLEFOIREWALL {
#------------------------------
Service firewalld start
chkconfig firewalld on

firewall-cmd --permanent \
--add-port="80/tcp" --add-port="443/tcp" \
--add-port="5647/tcp" --add-port="8000/tcp" \
--add-port="8140/tcp" --add-port="9090/tcp" \
--add-port="53/udp" --add-port="53/tcp" \
--add-port="67/udp" --add-port="69/udp" \
--add-port="22/udp" --add-port="69/tcp" \
--add-port="5000/tcp" --add-port="5646/tcp" \
--add-port="7/tcp" --add-port="7/udp" \
--add-port="22/tcp" --add-port="16514/tcp" \
--add-port="389/tcp" --add-port="636/tcp" \
--add-port=5900-5930/tcp
sudo touch RHTI/SATREENABLEFOIREWALL
}

#-------------------------------
function SATDONE {
#-------------------------------
echo 'YOU HAVE NOW COMPLETED INSTALLING SATELLITE!'
clear}
sudo touch RHTI/
}

#NOTE You can remove or dissasociate templates Remove is perm (Destricutve) dissasociate you can re associate if you need 

#-------------------------------
function REMOVEUNSUPPORTED {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "REMOVING UNSUPPORTED COMPONENTS DESTRUCTIVE"
echo "*********************************************************"
for i in $(hammer template list |grep -i FreeBSD |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer template list |grep -i CoreOS |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer template list |grep -i salt |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer template list |grep -i waik |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer template list |grep -i NX-OS |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer template list |grep -i Alterator |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer template list |grep -i Junos |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer template list |grep -i Jumpstart |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer template list |grep -i Preseed |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer template list |grep -i chef |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer template list |grep -i AutoYaST |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer partition-table list |grep -i AutoYaST |awk -F "|" {'print $1'}) ; do hammer partition-table delete --id $i ;done
for i in $(hammer partition-table list |grep -i CoreOS |awk -F "|" {'print $1'}) ; do hammer partition-table delete --id $i ;done
for i in $(hammer partition-table list |grep -i FreeBSD |awk -F "|" {'print $1'}) ; do hammer partition-table delete --id $i ;done
for i in $(hammer partition-table list |grep -i Jumpstart |awk -F "|" {'print $1'}) ; do hammer partition-table delete --id $i ;done
for i in $(hammer partition-table list |grep -i Junos |awk -F "|" {'print $1'}) ; do hammer partition-table delete --id $i ;done
for i in $(hammer partition-table list |grep -i NX-OS |awk -F "|" {'print $1'}) ; do hammer partition-table delete --id $i ;done
for i in $(hammer partition-table list |grep -i Preseed |awk -F "|" {'print $1'}) ; do hammer partition-table delete --id $i ;done
for i in $(hammer medium list |grep -i CentOS |awk -F "|" {'print $1'}) ; do hammer medium delete --id $i ;done
for i in $(hammer medium list |grep -i CoreOS |awk -F "|" {'print $1'}) ; do hammer medium delete --id $i ;done
for i in $(hammer medium list |grep -i Debian |awk -F "|" {'print $1'}) ; do hammer medium delete --id $i ;done
for i in $(hammer medium list |grep -i Fedora |awk -F "|" {'print $1'}) ; do hammer medium delete --id $i ;done
for i in $(hammer medium list |grep -i FreeBSD |awk -F "|" {'print $1'}) ; do hammer medium delete --id $i ;done
for i in $(hammer medium list |grep -i OpenSUSE |awk -F "|" {'print $1'}) ; do hammer medium delete --id $i ;done
for i in $(hammer medium list |grep -i Ubuntu |awk -F "|" {'print $1'}) ; do hammer medium delete --id $i ;done
sudo touch RHTI/REMOVEUNSUPPORTED
}

#-------------------------------
function DISASSOCIATE_TEMPLATES {
#------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "DISASSOCIATE UNSUPPORTED COMPONENTS NONDESTRUCTIVE"
echo "*********************************************************"
echo " "
declare -a TEMPLATES=(
"Alterator default"
"Alterator default finish"
"Alterator default PXELinux"
"alterator_pkglist"
"AutoYaST default"
"AutoYaST default user data"
"AutoYaST default iPXE"
"AutoYaST default PXELinux"
"AutoYaST SLES default"
"chef_client"
"coreos_cloudconfig"
"CoreOS provision"
"CoreOS PXELinux"
"Discovery Debian kexec"
"FreeBSD (mfsBSD) finish"
"FreeBSD (mfsBSD) provision"
"FreeBSD (mfsBSD) PXELinux"
"Jumpstart default"
"Jumpstart default finish"
"Jumpstart default PXEGrub"
"Junos default finish"
"Junos default SLAX"
"Junos default ZTP config"
"NX-OS default POAP setup"
"Preseed default"
"Preseed default finish"
"Preseed default PXEGrub2"
"Preseed default iPXE"
"Preseed default PXELinux"
"Preseed default user data"
"preseed_networking_setup"
"saltstack_minion"
"WAIK default PXELinux"
"XenServer default answerfile"
"XenServer default finish"
"XenServer default PXELinux"
 )
for INDEX in "${TEMPLATES[@]}"
do
echo disassoction of ${INDEX} from ${ORG}@${LOC}
hammer organization remove-config-template --config-template "${INDEX}" --name "${ORG}"
hammer location remove-config-template --config-template "${INDEX}" --name "${LOC}"
done
sudo touch RHTI/DISASSOCIATE_TEMPLATES
}

#-------------------------------
function SATUPDATE {
#-------------------------------
echo " "
echo "*********************************************************"
echo "Upgrading/Updating Satellite 6.5 to 6.7"
echo "*********************************************************"
echo " "
subscription-manager repos --disable '*'
echo " "
echo " "
subscription-manager repos --enable=rhel-7-server-rpms
subscription-manager repos --enable=rhel-server-rhscl-7-rpms
subscription-manager repos --enable=rhel-7-server-satellite-6.7-rpms
subscription-manager repos --enable=rhel-7-server-satellite-maintenance-6-rpms
subscription-manager repos --enable=rhel-7-server-ansible-2.9-rpms
yum clean all
yum-config-manager --setopt=\*.skip_if_unavailable=1 --save \* 
foreman-rake foreman_tasks:cleanup TASK_SEARCH='label = Actions::Katello::Repository::Sync' STATES='paused,pending,stopped' VERBOSE=true
foreman-rake katello:delete_orphaned_content --trace
foreman-rake katello:reimport
katello-selinux-disable
setenforce 0
service firewalld stop 
katello-service stop
yum groupinstall -y 'Red Hat Satellite' --skip-broken --setopt=protected_multilib=false
yum upgrade -y --skip-broken --setopt=protected_multilib=false ; yum update -y --skip-broken --setopt=protected_multilib=false
yum -q list installed puppetserver &>/dev/null && echo "puppetserver is installed" || time yum install puppetserver -y --skip-broken --setopt=protected_multilib=false
yum -q list installed puppet-agent-oauth &>/dev/null && echo "puppet-agent-oauth is installed" || time yum install puppet-agent-oauth -y --skip-broken --setopt=protected_multilib=false
yum -q list installed puppet-agent &>/dev/null && echo "puppet-agent is installed" || time yum install puppet-agent -y --skip-broken --setopt=protected_multilib=false
satellite-installer -vv --scenario satellite --upgrade
foreman-rake db:migrate
foreman-rake db:seed
foreman-rake katello:reimport
foreman-rake apipie:cache:index
hammer template build-pxe-default
for i in $(hammer capsule list |awk -F '|' '{print $1}' |grep -v ID|grep -v -) ; do hammer capsule refresh-features --id=$i ; done 
sudo touch RHTI/SATUPDATE
}

#-------------------------------
function INSIGHTS {
#-------------------------------
yum update python-requests -y
yum install redhat-access-insights -y
redhat-access-insights --register
sudo touch RHTI/INSIGHTS
satellite-maintain packages lock
}


#-------------------------------
function CLEANUP {
#-------------------------------
rm -rf /home/admin/FILES
rm -rf /root/FILES
rm -rf /tmp/*
mv -f /root/.bashrc.bak /root/.bashrc
sudo touch RHTI/CLEANUP
}


#-----------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------Ansible Tower---------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------

#-------------------------
function ANSIBLETOWERTXT {
#-------------------------
reset
HNAME=$(hostname)
echo " "
echo " "
echo " "
echo "
ANSIBLE-TOWER BASE HARDWARE REQUIREMENTS

1. Ansible-Tower will require a RHEL subscription and an Ansible Tower License.
Please register and download your lincense at http://www.ansible.com/tower-trial

2. Hardware requirement depends, however whether 
 it is a KVM or physical-Tower will require atleast 1 node with:

Min Storage 35GB
Directorys Recommended
/boot 1024MB
/swap 8192MB
/ Rest of drive


Min RAM 4096
Min CPU 2 (4 Reccomended)

3. Network
Connection to the internet so the installer can download the required packages"
echo " "
echo " "
echo " "
read -p "Press [Enter] to continue"
reset
echo " "
echo "

REQUIREMENTS CONTINUED

4. For this POC you must have a RHN User ID and password with entitlements
 to channels below. (item 6)

5. Install ansible tgz will be downloaded and placed into the FILES directory created by the sript on the host machine:

6. This install was tested with:
* RHEL_7.x in a KVM environment.
* Ansible Tower 3.6.4 https://releases.ansible.com/ansible-tower/setup-bundle/ansible-tower-setup-bundle-3.6.4-1.tar.gz
* Red Hat subscriber channels:
rhel-7-server-ansible-2.8-rpms
rhel-7-server-extras-rpms
rhel-7-server-optional-rpms
rhel-7-server-rpms
https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

URL Resources 
http://www.ansible.com
https://www.ansible.com/tower-trial
http://docs.ansible.com/ansible-tower/latest/html/quickinstall/index.html"
echo " "
echo " "
read -p "If you have met all of the minimum requirements from above please Press [Enter] to continue"
echo " "
reset
}

#-----------------------------
function CHECKCONNECT {
#-----------------------------
echo "********************************************"
echo "Verifying the server can get to the internet"
echo "********************************************"
wget -q --tries=10 --timeout=20 --spider http://google.com
if [[ $? -eq 0 ]]; then
echo "Online: 
 Continuing to Install"
sleep 3
else
echo "Offline"
echo "This script requires access to 
 the network to run please fix your settings and try again"
sleep 3
exit 1
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
echo "System is registered with Red Hat or Red Hat Satellite, Continuing!"
sleep 1 
fi
echo " "
echo " "
}

#-------------------------------
function ANSIBLEPREPFORINSTALL {
#-------------------------------
mkdir ~/Downloads
cd ~/Downloads
echo "***************************************************************************"
echo "SET SELINUX TO PERMISSIVE FOR THE INSTALL AND CONFIG OF Ansible Tower 3.6.4"
echo "***************************************************************************"
sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
setenforce 0
service firewalld stop
echo " "
echo " "
echo "*******************"
echo "FIRST DISABLE REPOS"
echo "*******************"
subscription-manager repos --disable "*"
yum-config-manager --disable "*"
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
echo "*******************"
echo "ENABLE REPOS RHEL7 "
echo "*******************"
yum -q list installed epel &>/dev/null && echo "epel is installed" || yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm --skip-broken
subscription-manager repos --enable rhel-7-server-rh-common-rpms --enable rhel-7-server-extras-rpms --enable rhel-7-server-optional-rpms --enable rhel-7-server-supplementary-rpms --enable rhel-server-rhscl-7-rpms --enable rhel-7-server-rpms --enable rhel-7-server-ansible-2.9-rpms
yum clean all
rm -rf /var/cache/yum
yum-config-manager --setopt=\*.skip_if_unavailable=1 --save \*
echo " "
echo " "
sleep 1
echo "********************************"
echo "CHECKING AND INSTALLING PACKAGES"
echo "********************************"
yum -q list installed wget &>/dev/null && echo "wget is installed" || yum install -y wget --skip-broken --noplugins
yum -q list installed python3-pip-wheel &>/dev/null && echo "wgpython3-pip-wheel is installed" || yum install -y python3-pip-wheel --skip-broken --noplugins
yum -q list installed python3-pip &>/dev/null && echo "python3-pip is installed" || yum install -y python3-pip --skip-broken --noplugins
yum -q list installed platform-python-pip &>/dev/null && echo "platform-python-pip is installed" || yum install -y platform-python-pip --skip-broken --noplugins
yum -q list installed yum-utils &>/dev/null && echo "yum-utils is installed" || yum install -y yum-util* --skip-broken --noplugins
yum -q list installed dialog &>/dev/null && echo "dialog is installed" || yum localinstall -y dialog --skip-broken --noplugins
yum -q list installed bash-completion-extras &>/dev/null && echo "bash-completion-extras" || yum install -y bash-completion-extras --skip-broken --noplugins
yum -q list installed dconf &>/dev/null && echo "dconf" || yum install -y dconf* --skip-broken --noplugins
yum-config-manager --disable epel
echo " "
echo " "
fi
}

#-----------------------------
function ANSIBLELINUXUPGRADE {
#-----------------------------
grep -q -i "release 7." /etc/redhat-release
status=$?
if test $status -eq 0
then
echo "*******************"
echo "Upgrade RHEL7 "
echo "*******************"
yum upgrade -y
echo " "
echo " "
fi
}

#-----------------------------
function ANSIBLEINSTALLTOWER {
#-----------------------------
grep -q -i "release 7." /etc/redhat-release
status=$?
if test $status -eq 0
then
echo '****************************************************************'
echo 'Getting, Expanding, and installing Ansible Tower 3.6.4 for RHEL7'
echo '****************************************************************'
mkdir ~/Downloads
cd ~/Downloads
wget https://releases.ansible.com/ansible-tower/setup-bundle/ansible-tower-setup-bundle-3.6.4-1.tar.gz
tar -zxvf ansible-tower-setup-bundle-3.6.4-1.tar.gz
yum localinstall -y ansible-tower-setup-bundle-3.6.4-1.el7/bundle/ansible-tower-dependencies/repos/*.rpm
cd ~/Downloads/ansible-tower-setup-bundle-3.6.4-1/
sleep 1
reset
echo " "
echo " " 
echo 'What would you like your default Ansible Tower user "admin" password to be?'
read ADMINPASSWORD
export $ADMINPASSWORD
sed -i 's/admin_password='"''"'/admin_password='"'"'$ADMINPASSWORD'"'"'/g' ~/Downloads/ansible-tower-setup-bundle-3.6.4-1/inventory
sed -i 's/pg_password='"''"'/pg_password='"'"'$ADMINPASSWORD'"'"'/g' ~/Downloads/ansible-tower-setup-bundle-3.6.4-1/inventory
sed -i 's/rabbitmq_password='"''"'/rabbitmq_password='"'"'$ADMINPASSWORD'"'"'/g' ~/Downloads/ansible-tower-setup-bundle-3.6.4-1/inventory
sh setup.sh
sleep 1
echo " "
echo " "
fi
}

DEFAULTVALUE=y
NMESSAGE="Disabled"
FMESSAGE="PLEASE ENTER Y or N"
COUNTDOWN=10
#-------------------------
function ANSIBLESELINUX {
#-------------------------
clear
echo '*******'
echo 'SELinux'
echo '*******'
echo 'If you do not know what selinux is please visit
https://www.redhat.com/en/topics/linux/what-is-selinux.
It is Red Hats position that SELinux should be enabled unless 
your enterprise dictates you disable SELinux on your systems.
The default answer is yes'
echo " "
read -n1 -p "Would you like to ENABLE SELinux? Y/n " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
sed -i 's/SELINUX=permissive/SELINUX=enforcing/g' /etc/selinux/config
setenforce 1
getenforce
sleep 3
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
else
echo -e "\n$FMESSAGE\n"
fi
}

#-------------------------
function ANSIBLEFIREWALL {
#-------------------------
clear
echo " "
echo '********'
echo 'Firewall'
echo '********'
echo ''
echo 'The ports used by Ansible Tower and its services are:
 
 80, 443 (normal Tower ports)
 22 (ssh)
 5432 (database instance - if the database is installed on 
 an external instance, needs to be opened to the tower instances)'
echo " "
read -n1 -p "Would you like to ENABLE Firewall? Y/n " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
firewall-cmd --permanent \
--add-port="80/tcp" --add-port="443/tcp" \
--add-port="22/tcp" --add-port="5432/tcp"
sleep 3

elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
service firewalld stop
chkconfig firewalld off
echo -e "\n$NMESSAGE\n"
else
echo -e "\n$FMESSAGE\n"
fi
} 



#--------------------------End Primary Functions--------------------------

#-----------------------
function dMainMenu {
#-----------------------
$DIALOG --stdout --title "Red Hat P.O.C. Tools - RHEL 7.X" --menu "********** Menu ********* \n Please choose [1 -> 4]?" 30 90 10 \
1 "Satellite 6.7 INSTALL" \
2 "ANSIBLE TOWER 3.6.4 INSTALL" \
3 "SATELLITE POST INSTALL CLEANUP" \
4 "EXIT"
}

#----------------------
function dYesNo {
#-----------------------
$DIALOG --title " Prompt " --yesno "$1" 10 80
}

#-----------------------
function dMsgBx {
#-----------------------
$DIALOG --infobox "$1" 10 80
sleep 10
}

#----------------------
function dInptBx {
#----------------------
#Requires 2 mandatory options and 3rd is preset variable 
$DIALOG --title "$1" --inputbox "$2" 20 80 "$3" 
}

#----------------------------------End-Functions-------------------------------
######################
#### MAIN LOGIC ####
######################
#set -o xtrace
clear
# Sets a time value for Xdialog
[[ -z $DISPLAY ]] || TV=3000
$DIALOG --infobox "
**************************
**** Red Hat - Config Tools****
**************************
`hostname`" 20 80 $TV
[[ -z $DISPLAY ]] && sleep 1 

#---------------------------------Menu----------------------------------------
HNAME=$(hostname)
TMPd=RHTI/
while true
do
[[ -e "$TMPd" ]] || mkdir -p $TMPd
TmpFi=$(mktemp $TMPd/xcei.XXXXXXX )
dMainMenu > $TmpFi
RC=$?
[[ $RC -ne 0 ]] && break
Flag=$(cat $TmpFi)
case $Flag in
1) dMsgBx "Satellite 6.7 INSTALL" \
sleep 10
#SCRIPT
CHECKONLINE
echo " "
SATELLITEREADME
SATELLITEREQUIREMENTS
echo " "

SATREGISTER
echo " "

ls RHTI/VARIABLES1 &>/dev/null
if [ $? -eq 0 ]; then
echo 'The Variables complete, proceeding'
sleep 1
else
echo "Setting up Variables for Satellite stand by"
echo " "
VARIABLES1
sleep 1
echo " "
fi
echo " "

ls RHTI/IPA &>/dev/null
if [ $? -eq 0 ]; then
echo 'IPA Complete , proceeding'
sleep 1
else
echo "IPA"
IPA
sleep 1
fi
echo " "

ls RHTI/CAPSULE &>/dev/null
if [ $? -eq 0 ]; then
echo ' CAPSULE Complete skipping'
sleep 1
else
echo "CAPSULE"
CAPSULE
sleep 1
fi
echo " "

ls RHTI/SATLIBVIRT &>/dev/null
if [ $? -eq 0 ]; then
echo ' SATLIBVIRT Complete skipping'
sleep 1
else
echo "SATLIBVIRT"
SATLIBVIRT
sleep 1
fi
echo " "

ls RHTI/SATRHV &>/dev/null
if [ $? -eq 0 ]; then
echo ' SATRHV Complete skipping'
sleep 1
else
echo "SATRHV"
SATRHV
sleep 1
fi
echo " "

ls RHTI/RHVORLIBVIRT &>/dev/null
if [ $? -eq 0 ]; then
echo ' RHVORLIBVIRT Complete skipping'
sleep 1
else
echo "RHVORLIBVIRT"
RHVORLIBVIRT
fi
echo " "

ls RHTI/INSTALLREPOS &>/dev/null
if [ $? -eq 0 ]; then
echo ' INSTALLREPOS Complete skipping'
sleep 1
else
echo "INSTALLREPOS"
INSTALLREPOS
sleep 1
fi
echo " "

ls RHTI/INSTALLDEPS &>/dev/null
if [ $? -eq 0 ]; then
echo ' INSTALLDEPS Complete skipping'
sleep 1
else
echo "INSTALLDEPS"
INSTALLDEPS
fi
echo " "

ls RHTI/GENERALSETUP &>/dev/null
if [ $? -eq 0 ]; then
echo ' GENERALSETUP Complete skipping'
sleep 1
else
echo "GENERALSETUP"
GENERALSETUP
fi
echo " "

ls RHTI/SYSCHECK &>/dev/null
if [ $? -eq 0 ]; then
echo ' SYSCHECK Complete skipping'
sleep 1
else
echo "SYSCHECK"
SYSCHECK
fi
echo " "

ls RHTI/INSTALLNSAT &>/dev/null
if [ $? -eq 0 ]; then
echo ' INSTALLNSAT Complete skipping'
sleep 1
else
echo "INSTALLNSAT"
INSTALLNSAT
fi
echo " "

ls RHTI/CONFSAT &>/dev/null
if [ $? -eq 0 ]; then
echo ' CONFSAT Complete skipping'
sleep 1
else
echo "CONFSAT"
CONFSAT
fi
echo " "

ls RHTI/FOREMANPROXY &>/dev/null
if [ $? -eq 0 ]; then
echo ' FOREMANPROXY Complete skipping'
sleep 1
else
echo "FOREMANPROXY"
FOREMANPROXY
fi
echo " "

ls RHTI/CONFSATDHCP &>/dev/null
if [ $? -eq 0 ]; then
echo ' CONFSATDHCP Complete skipping'
sleep 1
else
echo "CONFSATDHCP"
CONFSATDHCP
fi
echo " "

ls RHTI/CONFSATTFTP &>/dev/null
if [ $? -eq 0 ]; then
echo ' CONFSATTFTP Complete skipping'
sleep 1
else
echo "CONFSATTFTP"
CONFSATTFTP
fi
echo " "

ls RHTI/CONFSATPLUGINS &>/dev/null
if [ $? -eq 0 ]; then
echo ' CONFSATPLUGINS Complete skipping'
sleep 1
else
echo "CONFSATPLUGINS"
CONFSATPLUGINS
fi
echo " "

ls RHTI/CONFSATCACHE &>/dev/null
if [ $? -eq 0 ]; then
echo ' CONFSATCACHE Complete skipping'
sleep 1
else
echo "CONFSATCACHE"
CONFSATCACHE
fi
echo " "

ls RHTI/CHECKDHCP &>/dev/null
if [ $? -eq 0 ]; then
echo ' CHECKDHCP Complete skipping'
sleep 1
else
echo "CHECKDHCP"
CHECKDHCP
fi
echo " "

ls RHTI/DISABLEEXTRAS &>/dev/null
if [ $? -eq 0 ]; then
echo ' DISABLEEXTRAS Complete skipping'
sleep 1
else
echo "DISABLEEXTRAS"
DISABLEEXTRAS
fi
echo " "

ls RHTI/HAMMERCONF &>/dev/null
if [ $? -eq 0 ]; then
echo ' HAMMERCONF Complete skipping'
sleep 1
else
echo "HAMMERCONF"
HAMMERCONF
fi
echo " "

ls RHTI/CONFIG2 &>/dev/null
if [ $? -eq 0 ]; then
echo ' CONFIG2 Complete skipping'
sleep 1
else
echo "CONFIG2"
CONFIG2
fi
echo " "

ls RHTI/STOPSPAMMINGVARLOG &>/dev/null
if [ $? -eq 0 ]; then
echo ' STOPSPAMMINGVARLOG Complete skipping'
sleep 1
else
echo "STOPSPAMMINGVARLOG"
STOPSPAMMINGVARLOG
fi
echo " "

ls RHTI/REQUESTSYNCMGT &>/dev/null
if [ $? -eq 0 ]; then
echo ' REQUESTSYNCMGT Complete skipping'
sleep 1
else
echo "REQUESTSYNCMGT"
REQUESTSYNCMGT
fi
echo " "

ls RHTI/REQUEST7 &>/dev/null
if [ $? -eq 0 ]; then
echo ' REQUEST7 Complete skipping'
sleep 1
else
echo "REQUEST7"
REQUEST7
fi
echo " "

ls RHTI/REQUEST8 &>/dev/null
if [ $? -eq 0 ]; then
echo ' REQUEST8 Complete skipping'
sleep 1
else
echo "REQUEST8"
REQUEST8
fi
echo " "

ls RHTI/SYNC &>/dev/null
if [ $? -eq 0 ]; then
echo ' SYNC Complete skipping'
sleep 1
else
echo "SYNC"
SYNC
fi
echo " "

ls RHTI/SYNCMSG &>/dev/null
if [ $? -eq 0 ]; then
echo ' SYNCMSG Complete skipping'
sleep 1
else
echo "SYNCMSG"
SYNCMSG
fi
echo " "

ls RHTI/REQUESTPUPPET &>/dev/null
if [ $? -eq 0 ]; then
echo ' REQUESTPUPPET Complete skipping'
sleep 1
else
echo "REQUESTPUPPET"
REQUESTPUPPET
fi
echo " "

ls RHTI/PRIDOMAIN &>/dev/null
if [ $? -eq 0 ]; then
echo ' PRIDOMAIN Complete skipping'
sleep 1
else
echo "PRIDOMAIN"
PRIDOMAIN
fi
echo " "

ls RHTI/CREATESUBNET &>/dev/null
if [ $? -eq 0 ]; then
echo ' CREATESUBNET Complete skipping'
sleep 1
else
echo "CREATESUBNET"
CREATESUBNET
fi
echo " "

ls RHTI/ENVIRONMENTS &>/dev/null
if [ $? -eq 0 ]; then
echo ' ENVIRONMENTS Complete skipping'
sleep 1
else
echo "ENVIRONMENTS"
ENVIRONMENTS
fi
echo " "

ls RHTI/SYNCPLANS &>/dev/null
if [ $? -eq 0 ]; then
echo ' SYNCPLANS Complete skipping'
sleep 1
else
echo "SYNCPLANS"
SYNCPLANS
fi
echo " "

ls RHTI/SYNCPLANCOMPONENTS &>/dev/null
if [ $? -eq 0 ]; then
echo ' SYNCPLANCOMPONENTS Complete skipping'
sleep 1
else
echo "SYNCPLANCOMPONENTS"
SYNCPLANCOMPONENTS
fi
echo " "

ls RHTI/ASSOCPLANTOPRODUCTS &>/dev/null
if [ $? -eq 0 ]; then
echo ' ASSOCPLANTOPRODUCTS Complete skipping'
sleep 1
else
echo "ASSOCPLANTOPRODUCTS"
ASSOCPLANTOPRODUCTS
fi
echo " "

PUBLISHRHEL7CONTENT
ls RHTI/PUBLISHRHEL7CONTENT &>/dev/null
if [ $? -eq 0 ]; then
echo ' PUBLISHRHEL7CONTENT Complete skipping'
sleep 1
else
echo "PUBLISHRHEL7CONTENT"
PUBLISHRHEL7CONTENT
fi
echo " "

ls RHTI/PUBLISHRHEL8CONTENT &>/dev/null
if [ $? -eq 0 ]; then
echo ' PUBLISHRHEL8CONTENT Complete skipping'
sleep 1
else
echo "PUBLISHRHEL8CONTENT"
PUBLISHRHEL8CONTENT
fi
echo " "

ls RHTI/HOSTCOLLECTION &>/dev/null
if [ $? -eq 0 ]; then
echo ' HOSTCOLLECTION Complete skipping'
sleep 1
else
echo "HOSTCOLLECTION"
HOSTCOLLECTION
fi
echo " "

ls RHTI/KEYSFORENV &>/dev/null
if [ $? -eq 0 ]; then
echo ' KEYSFORENV Complete skipping'
sleep 1
else
echo "KEYSFORENV"
KEYSFORENV
fi
echo " "

ls RHTI/KEYSTOHOST &>/dev/null
if [ $? -eq 0 ]; then
echo ' KEYSTOHOST Complete skipping'
sleep 1
else
echo "KEYSTOHOST"
KEYSTOHOST
fi
echo " "

ls RHTI/SUBTOKEYS &>/dev/null
if [ $? -eq 0 ]; then
echo ' SUBTOKEYS Complete skipping'
sleep 1
else
echo "SUBTOKEYS"
SUBTOKEYS
fi
echo " "

ls RHTI/MEDIUM &>/dev/null
if [ $? -eq 0 ]; then
echo ' MEDIUM Complete skipping'
sleep 1
else
echo "MEDIUM"
MEDIUM
fi
echo " "

ls RHTI/DISASSOCIATE_TEMPLATES &>/dev/null
if [ $? -eq 0 ]; then
echo ' DISASSOCIATE_TEMPLATES Complete skipping'
sleep 1
else
echo "DISASSOCIATE_TEMPLATES"
DISASSOCIATE_TEMPLATES
fi
echo " " 

ls RHTI/INSIGHTS &>/dev/null
if [ $? -eq 0 ]; then
echo ' INSIGHTS Complete skipping'
sleep 1
else
echo "INSIGHTS"
INSIGHTS
fi
echo " "

#ls RHTI/CLEANUP
#if [ $? -eq 0 ]; then
#echo ' CLEANUP Complete skipping'
#sleep 1
#else
#echo "CLEANUP"
#CLEANUP
#fi
#echo " "

ls RHTI/SATREENABLEFOIREWALL &>/dev/null
echo 'This Script has set up Satellite to the point where it should be basicly 
operational the syntax for some of the items that have been pounded out and require some updating if you plan to use.'
if [ $? -eq 0 ]; then
echo ' SATREENABLEFOIREWALL Complete skipping'
sleep 1
else
echo "SATREENABLEFOIREWALL"
SATREENABLEFOIREWALL
fi
echo " "

sleep 1
;;
2) dMsgBx "ANSIBLE TOWER 3.6.4 INSTALL" \
CHECKCONNECT
ANSIBLETOWERTXT
ANSIBLEREGISTER
ANSIBLEPREPFORINSTALL
ANSIBLESYSTEMREPOS
ANSIBLELINUXUPGRADE
ANSIBLEINSTALLTOWER
INSIGHTS
ANSIBLEFIREWALL
ANSIBLESELINUX
;;
3) dMsgBx "SATELLITE POST INSTALL CLEANUP" \
#REMOVEUNSUPPORTED
DISASSOCIATE_TEMPLATES
CLEANUP
;;
4) dMsgBx "*** EXITING - THANK YOU ***"
break
;;
esac

done

exit 0