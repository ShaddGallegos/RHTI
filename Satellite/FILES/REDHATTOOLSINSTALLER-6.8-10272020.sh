#!/bin/bash
#Red Hat tools installer – for RHEL 7.X
#POC/Demo
#This Script is for setting up a basic Satellite 6.8 on RHEL 7 or Ansible Tower 6.8.1 on RHEL 7

echo -ne "\e[8;40;170t"

# Hammer referance to assist in modifing the script can be found at 
# https://www.gitbook.com/book/abradshaw/getting-started-with-satellite-6-command-line/details


#What this script does in cronalogical order
#Verify the server can get to the internet
#Verify you are “root”
#Ensure GW connectivity
#Set selinux to permissive and disable firewall 
#Register RHEL
#Set repositories
#Enable repositories
#Install packages enable script to run
#Collect variables
#Install dependencies 
#Upgrade OS
#Root ssh keys
#Set domain
#Check all requirements have been met
#Check FQDN
#Verify repositories for Satellite 6.8
#Install Satellite 6.8
#Configure Satellite 6.8
#Satellite 6.8 configure Satellite base
#Satellite 6.8 internal DNS configuration
#Satellite 6.8 DHCP configuration (optional)
#Satellite 6.8 TFTP configuration
#Satellite 6.8 task and cleanup configuration
#Satellite 6.8 cloud management option configuration
#Start and enable Satellite services
#Configure Satellite cache
#Verify DHCP is wanted for new systems (default is enabled)
#Enable hammer 
#If you have put your manifest into ~/downloads/
#When prompted please enter your Satellite admin/foreman username and password
#Refresh the capsule content
#Set Satellite environment settings
#Tune the Satellite for medium Satellite 
#Stop the log spamming of /var/log/messages with slice
#RHEL 7 standard repositories
#RHEL 8 standard repositories
#Sync all repositories
#Create the first or primary subnet to connect the nodes to the Satellite
#Create environments DEV_RHEL→ TEST_RHEL→ PROD_RHEL
#Create a daily sync plan
#Associate plan to products
#Create a content views
#Create a host collection for RHEL
#Create an activation keys for environments
#Associate each activation key to host collection
#Add all subscriptions available to keys
#Enable all the base content for each os by default
#Create media
#Create a RHEL hostgroups
#
#                                              **************************
#                                              Satellite 6.8 REQUIREMENTS
#                                              **************************
#                                    Hardware Requirements
#                                        32  GB Ram
#                                        300 GB Storage
#                                        8   CPU
#
#                                    Official Storage Requirements https://url.corp.redhat.com/SAT-6-7-Storage-Requirements
#                                    Filesystems Required for this script to run
#                                        /              Rest of Drive
#                                        /boot          1024 MB
#                                        /swap          18 GB
#
#                                    2 etthernet ports
#                                        eth0 internal for provisioning
#                                        eth1 external for syncing to cdn
#
#                                    The Server
#                                        Basic system or System with GUI
#
#           Your manifest from https://access.redhat.com/management/subscription_allocations
#
#           A ~/Downloads directory
#
#           Copy this script, and your manifest into ~/Downloads/
#
#           To run it
#           change to root user
#           sudo su
#
#           cd into the admin downloads dir
#           cd ~/Downloads
#
#           Run the script
#           sh REDHATTOOLSINSTALLER-6.8.sh"

#-----------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------ Functions ------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------

#-------------------------
function CHECKONLINE {
#-------------------------
if [ -t 0 ]; then
  reset
fi
echo 'REDHAT TOOLS INSTALLER – FOR RHEL 7.X'
wget -q --tries=10 --timeout=20 --spider http://redhat.com
if [[ $? -eq 0 ]]; then
echo "Online: Continuing to Install"
else
echo "Offline"
echo "This script requires access to the network to run please fix your settings and try again"
sleep 1
exit 1
fi
reset
if [ "$(whoami)" != "root" ]
then
echo "This script must be run as root - if you do not have the credentials please contact your administrator"
exit
else
echo " "
echo " "

echo '

                                                   REDHAT TOOLS INSTALLER
             FOR RHEL 7.X FOR SETTING UP SINGLE NODE CONFIGURATIONS OF RED HAT MANAGEMENT PORTFOLIO APPLICATIONS FOR P.O.C.'
echo " "
read -p "To Continue Press [Enter] or use Ctrl+c to exit the installer"
fi
sleep 1 
reset
}
CHECKONLINE

function SPINNER {
pid=$!
#Store the background process id in a temp file to use in err_handler
echo $(jobs -p) > "${VAR_FILE}"
spin[0]="-"
spin[1]="\\"
spin[2]="|"
spin[3]="/"
# Loop while the process is still running
while kill -0 $pid 2>/dev/null
do
	for i in "${spin[@]}"
	do
		if kill -0 $pid 2>/dev/null; then #Check that the process is running to prevent a full 4 character cycle on error
			# Display the spinner in 1/4 states
			echo -ne "\b\b\b${Bold}[${Green}$i${Reset}${Bold}]" >&3
			sleep .5 # time between each state
		else #process has ended, stop next loop from finishing iteration
			break
		fi
	done
done
# Check if background process failed once complete
if wait $pid; then # Exit 0
	echo -ne "\b\b\b${Bold}[${Green}-done-${Reset}${Bold}]" >&3
else # Any other exit
	false
fi
}

function SECHO {
# Use first arg $1 to determine if echo skips a line (yes/no)
# Second arg $2 is the message
case $1 in
	# No preceeding blank line
	[Nn])
		echo -ne "\n${2}" | tee -a /dev/fd/3
		echo # add new line after in log only
		;;
	# Preceeding blank line
	[Yy]|*)
		echo -ne "\n\n${2}" | tee -a /dev/fd/3
		echo # add new line after in log only
		;;
esac
}

#-------------------------
function SETUPHOST {
#-------------------------
HNAME=$(hostname)
SHNAME=$(hostname -s)
DOM="$(hostname -d)"
mkdir -p ~/Downloads/RHTI
mkdir /run/user/1000/dconf/ &>/dev/null
touch /run/user/1000/dconf/user &>/dev/null
chmod 777 /run/user/1000/dconf/user &>/dev/null
chmod -R 777 ~/Downloads/RHTI &>/dev/null
chown -R nobody:nobody ~/Downloads/RHTI &>/dev/null
echo " "
cp -p /root/.bashrc /root/.bashrc.bak
cp -p /etc/sysctl.conf /etc/sysctl.conf.bak
cp /etc/hosts /etc/hosts.bak
cp /etc/sudoers /etc/sudoers.bak
export INTERNAL=$(ip -o link | head -n 2 | tail -n 1 | awk '{print $2}' | sed s/:// )
export EXTERNAL=$(ip route show | sed -e 's/^default via [0-9.]* dev \(\w\+\).*/\1/' | head -1)
export INTERNALIP=$(ifconfig "$INTERNAL" | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."$3"."$4}')
export INTERNALSUBMASK=$(ifconfig "$INTERNAL" |grep netmask |awk -F " " {'print $4'})
export INTERNALGATEWAY=$(ip route list type unicast dev $(ip -o link | head -n 2 | tail -n 1 | awk '{print $2;}' | sed s/:$//) |awk -F " " '{print $7}')
echo "HNAME=$(hostname -f)" >> /root/.bashrc
echo "INTERNALIP=$INTERNALIP" >> /root/.bashrc
echo " " >> /root/.bashrc
echo " " >> /etc/hosts
echo " " >> /etc/hosts
echo ''$INTERNALIP' '$HNAME' '$SHNAME'' >> /etc/hosts
echo " "
echo " "
echo '********************************************************'
echo 'ENSURE INTERNAL/PROVISIONING (eth0/ens3) GW CONNICTIVITY'
echo '********************************************************'
echo " "
echo 'what is the IP of your eth0 GATEWAY ?'
read GWINIP
echo 'what is the FQDN of your eth0 GATEWAY ?'
read GWFQDN
echo ''$GWINIP'  '$GWFQDN'' >> /etc/hosts
ping -c 5 $GWINIP |exit 1
echo ''DNS2=$GWINIP'' >> /root/.bashrc
sudo touch ~/Downloads/RHTI/SETUPHOST
}

ls ~/Downloads/RHTI/SETUPHOST &>/dev/null
if [ $? -eq 0 ]; then
echo '/etc/host has already been run Skipping'
sleep 1
else
echo "Setting up /etc/hostfile to include this '$(hostname)' and the GW for your internal provisioning (eth0/ens3) interface"
SETUPHOST
sleep 1
echo " "
fi

#-------------------------
function DISABLESECURITY {
#-------------------------
echo "*****************************************************************"
echo "SET SELINUX TO PERMISSIVE AND DISABLING FIREWALL 
      FOR THE INSTALL AND CONFIG, You will have the option 
      to reenable once the system completes "
echo "*****************************************************************"
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
service firewalld stop
chkconfig firewalld off
sleep 1
echo " "
}

ls ~/Downloads/RHTI/DISABLESECURITY &>/dev/null
if [ $? -eq 0 ]; then
echo 'Disable Security for install has already been run, Skipping'
sleep 1
else
echo "Disabling Selinux and Firewalld will be disabled for install and you will be queried to enable if you so choose after the install"
DISABLESECURITY
sleep 1
echo " "
fi

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
touch ~/Downloads/RHTI/SYSREGISTER
else
echo "System is registered with Red Hat or a Red Hat Satellite, Continuing!"
touch ~/Downloads/RHTI/SYSREGISTER
fi
echo " "
}

ls ~/Downloads/RHTI/SYSREGISTER &>/dev/null
if [ $? -eq 0 ]; then
echo 'Registering'
else
echo 'Registered'
SYSREGISTER
fi

#---------------------
function SYSREPOS {
#---------------------
echo " "
echo "*********************************************************"
echo "FIRST DISABLE REPOS"
echo "*********************************************************"
subscription-manager repos --disable "*" 
sleep 5
echo " "
echo "*********************************************************"
echo "ENABLE PROPER REPOS"
echo "*********************************************************"
subscription-manager repos --enable=rhel-7-server-rpms \
--enable=rhel-7-server-extras-rpms 
echo " "
echo "*********************************************************"
echo "ENABLE EPEL FOR A FEW PACKAGES"
echo "*********************************************************"
yum -q list installed epel-release-latest-7 &>/dev/null && echo "epel-release-latest-7 is installed" || \
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm --skip-broken
yum-config-manager --enable epel 
yum-config-manager --save --setopt=*.skip_if_unavailable=true
yum clean all
rm -fr /var/cache/yum
sudo touch ~/Downloads/RHTI/SYSREPOS
echo " "
}

ls ~/Downloads/RHTI/SYSREPOS &>/dev/null
if [ $? -eq 0 ]; then
echo 'Repos Enabled'
else
echo 'Enabling Repos'
SYSREPOS
fi

#-----------------------------
function INSTALLERPACKAGES {
#---------------------------
echo " "
echo "*********************************************************"
echo "INSTALLING PACKAGES ENABLING SCRIPT TO RUN"
echo "*********************************************************"
mkdir -p ~/Downloads
cd ~/Downloads
yum-config-manager --enable epel
yum -q list installed wget &>/dev/null && echo "wget is installed" || yum install -y 'wget' --skip-broken
wget https://github.com/ShaddGallegos/RHTI/raw/master/Satellite/files/xdialog-2.3.1-13.el7.centos.x86_64.rpm
chmod 777 ~/Downloads/xdialog-2.3.1-13.el7.centos.x86_64.rpm
cp -fp xdialog-2.3.1-13.el7.centos.x86_64.rpm ~/Downloads
yum -q list installed xdialog &>/dev/null && echo "xdialog is installed" || yum localinstall -y  ~/Downloads/xdialog-2.3.1-13.el7.centos.x86_64.rpm --skip-broken
yum -q list installed dialog &>/dev/null && echo "dialog is installed" || yum install -y 'dialog' --skip-broken
yum -q list installed rhel-system-roles &>/dev/null && echo "rhel-system-roles is installed" || yum install 'rhel-system-roles' -y --skip-broken
yum -q list installed rubygem-builder &>/dev/null && echo "rubygem-builder is installed" || yum  install -y 'rubygem-builder' --skip-broken
yum -q list installed libvirt-client &>/dev/null && echo "libvirt-client is installed" || yum  install -y 'libvirt-client' --skip-broken
yum-config-manager --disable epel
sudo touch ~/Downloads/RHTI/INSTALLERPACKAGES
echo " "
}

ls ~/Downloads/RHTI/INSTALLERPACKAGES &>/dev/null
if [ $? -eq 0 ]; then
echo 'The requirements to run this script have been met, proceeding'
sleep 1
else
echo "Installing requirements to run script please stand by"
INSTALLERPACKAGES
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

#-----------------------------------------------------------------------------------------------------------------------
#----------------------------------------START OF SAT 6.X INSTALL SCRIPT------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------

#-------------------------------
function SATELLITEREQUIREMENTS {
#-------------------------------
echo " "
echo "************************************************************************************************************************************"
echo "
                                              **************************
                                              Satellite 6.8 REQUIREMENTS
                                              **************************
                                    Hardware Requirements
                                        32  GB Ram
                                        300 GB Storage
                                        8   CPU

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

           Your manifest from https://access.redhat.com/management/subscription_allocations

           A ~/Downloads directory

           Copy this script, and your manifest into ~/Downloads/

           To run it
           change to root user
           sudo su

           cd into the admin downloads dir
           cd ~/Downloads

           Run the script
           sh REDHATTOOLSINSTALLER-6.8.sh"
echo " "
echo "************************************************************************************************************************************"
read -p "Press [Enter] to continue"
echo " "
reset
}

#-------------------------
function SATELLITEREADME {
#-------------------------
echo " "
echo " "
echo "************************************************************************************************************************************"
echo " "
echo " "
echo "

                                              P.O.C Satellite 6.8 ONLY, RHEL 7.X KVM, or RHEL 7 Physical Host 
                                                   THIS SCRIPT CONTAINS NO CONFIDENTIAL INFORMATION

                                           This script is designed to set up a basic standalone Satellite 6.X system

                                    Disclaimer: This script was written for education, evaluation, and/or testing purposes. 
                    This helper script is Licensed under GPL and there is no implied warranty and is not officially supported by anyone.
 
                                ...SHOULD NOT BE USED ON A CURRENTlY OPERATING PRODUCTION SYSTEM - USE AT YOUR OWN RISK...


                    However, if you have an issue with the installed product and have a valid subscription please contact Red Hat at:

                          RED HAT Inc..
                          1-888-REDHAT-1 or 1-919-754-3700, then select the Menu Prompt for Customer Service
                          Spanish: 1-888-REDHAT-1 Option 5 or 1-919-754-3700 Option 5
                          Fax: 919-754-3701 (General Corporate Fax)
                          Email address: customerservice@redhat.com "


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
echo " "
subscription-manager register
sleep 1
echo " "
echo "*******************************************************************"
echo 'Verifying that the system is attached to a Satellite Subscription'
echo "*******************************************************************"
echo " "
subscription-manager attach --pool=`subscription-manager list --available --matches 'Red Hat Satellite Infrastructure Subscription' --pool-only`
sleep 1
echo " "
else
echo "*******************************************************************"
echo "System is registered with Red Hat or Red Hat Satellite, Continuing!"
echo "*******************************************************************"
echo " "
echo "*******************************************************************"
echo 'Verifying that the system is attached to a Satellite Subscription'
echo "*******************************************************************"
echo 'Checking your Satellite subscription status this may take a moment'
subscription-manager attach --pool=`subscription-manager list --available --matches 'Red Hat Satellite Infrastructure Subscription' --pool-only`
sleep 1
fi
sudo touch ~/Downloads/RHTI/SATREGISTER
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
HNAME=$(hostname -f)
SHNAME=$(hostname -s)
DOM="$(hostname -d)"
echo "*********************************************************"
echo "COLLECT VARIABLES FOR SAT 6.X"
echo "*********************************************************"
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
echo "*********************************************************"
echo "LOCATION OF YOUR SATELLITE"
echo "*********************************************************"
echo 'What is the location of your Satellite server. Example DENVER'
read LOC
echo 'LOC='$LOC'' >> /root/.bashrc
echo " "
echo "*********************************************************"
echo "SETTING DOMAIN"
echo "*********************************************************"
echo 'DOM='$(hostname -d)'' >> /root/.bashrc
echo " "$(hostname -d)''
echo " "
echo "*********************************************************"
echo "NAME OF FIRST SUBNET"
echo "*********************************************************"
echo 'What would you like to call your first subnet for systems you are regestering to satellite?'
read  SUBNET
echo 'SUBNET_NAME='$SUBNET'' >> /root/.bashrc
echo " "
echo "*********************************************************"
echo "NODE PASSWORD"
echo "*********************************************************"
echo 'PROVISIONED HOST PASSWORD'
echo 'Please enter the default password you would like to use for root for your newly provisioned nodes'
read PASSWORD
for i in $(echo "$PASSWORD" | openssl passwd -apr1 -stdin); do echo NODEPASS=$i >> /root/.bashrc ; done
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
touch ~/Downloads/RHTI/VARIABLES1
}
#-------------------------------
function SERVICEUSER {
#-------------------------------
echo "*********************************************************"
echo "ADMIN/FOREMAN PASSWORD"
echo "*********************************************************"
echo 'What will the password be for your admin (FOREMAN) user?'
echo 'ADMIN=admin'  >> /root/.bashrc
read  ADMIN_PASSWORD
echo 'ADMIN_PASSWORD='$ADMIN_PASSWORD'' >> /root/.bashrc
echo " "
touch ~/Downloads/RHTI/SERVICEUSER
}

#------------------------------
function INSTALLREPOS {
#------------------------------
echo "******************************************************************"
echo "STANDBY WHILE WE SET REPOS FOR INSTALLING AND UPDATING SATELLITE 6.8"
echo "******************************************************************"
echo -ne "\e[8;40;170t"
source /root/.bashrc
subscription-manager repos --disable "*"
echo "**************************"
echo "ENABLE REPOS"
echo "**************************"
subscription-manager repos --disable "*"
yum-config-manager --disable epel
subscription-manager repos --enable=rhel-7-server-rpms \
--enable=rhel-7-server-satellite-6.8-rpms \
--enable=rhel-7-server-satellite-maintenance-6-rpms \
--enable=rhel-server-rhscl-7-rpms \
--enable=rhel-7-server-ansible-2.9-rpms 
yum clean all
rm -rf /var/cache/yum
yum clean all
rm -rf /var/cache/yum

echo " "
sudo touch ~/Downloads/RHTI/INSTALLREPOS
}

#------------------------------
function INSTALLDEPS {
#------------------------------
echo "************************************************************************"
echo "INSTALLING DEPENDENCIES AND UPDATING FOR SATELLITE OPERATING ENVIRONMENT"
echo "************************************************************************"
echo -ne "\e[8;40;170t"
sleep 1
yum -q list installed kernel-devel &>/dev/null && echo "kernel-devel is installed" || yum install -y 'kernel-devel' --skip-broken
yum -q list installed kernel-doc &>/dev/null && echo "kernel-doc is installed" || yum install -y 'kernel-doc' --skip-broken
yum -q list installed kernel-headers &>/dev/null && echo "kernel-headers is installed" || yum install -y 'kernel-headers' --skip-broken
echo " "
echo "*********************************************************"
echo "UPGRADING OS"
echo "*********************************************************"
 yum-config-manager --disable epel
 subscription-manager repos --disable=rhel-7-server-extras-rpms --disable=rhel-7-server-optional-rpms
 yum clean all ; rm -rf /var/cache/yum
 yum upgrade -y --skip-broken
 sudo touch ~/Downloads/RHTI/INSTALLDEPS
}

#----------------------------------
function GENERALSETUP {
#----------------------------------
echo -ne "\e[8;40;170t"
source /root/.bashrc
echo " "
echo "*********************************************************"
echo "ROOT SSH KEY"
echo "*********************************************************"
ssh-keygen -f /root/.ssh/id_rsa -t rsa -N ''
echo " "
echo "*********************************************************"
echo “SET DOMAIN”
echo "*********************************************************"
echo 'inet.ipv4.ip_forward=1' >> /etc/sysctl.conf
echo "kernel.domainname=$DOM" >> /etc/sysctl.conf
echo " "
cd ~/Downloads/
mkdir -p /root/.hammer
sudo touch ~/Downloads/RHTI/GENERALSETUP
echo " "
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
echo "The FQDN is not defined please please enter now"
read HOSNAME
hostnamectl set-hostname "$HOSNAME"
service restart systemd-hostnamed
sleep 1
echo " "
dnsserver="$DHCP_GW"

# function to get IP address
function get_ipaddr {
  ip_address=""
    # A and AAA record for IPv4 and IPv6, respectively
    # $1 stands for first argument
  if [ -n "$1" ]; then
    hostname="${1}"
    if [ -z "query_type" ]; then
      query_type="A"
    fi
    # use host command for DNS lookup operations
    host -t ${query_type}  ${hostname} &>/dev/null ${dnsserver}
    if [ "$?" -eq "0" ]; then
      # get ip address
      ip_address="$(host -t ${query_type} ${hostname} ${dnsserver}| awk '/has.*address/{print $NF; exit}')"
    else
      exit 1
    fi
  else
    exit 2
  fi
# display ip
 echo $ip_address
}

hostname="${1}"
for query in "A-IPv4" "AAAA-IPv6"; do
  query_type="$(printf $query | cut -d- -f 1)"
  ipversion="$(printf $query | cut -d- -f 2)"
  address="$(get_ipaddr ${hostname})"
  if [ "$?" -eq "0" ]; then
    if [ -n "${address}" ]; then
    echo "The ${ipversion} adress of the Hostname ${hostname} is: $address"
    fi
  else
    echo "An error occurred"
  fi
done
fi
sleep 7
sudo touch ~/Downloads/RHTI/SYSCHECK
}

# --------------------------------------
function INSTALLNSAT {
# --------------------------------------
echo -ne "\e[8;40;170t"
source /root/.bashrc
echo " "
echo "*********************************************************"
echo "VERIFING REPOS FOR Satellite 6.8"
echo "*********************************************************"
subscription-manager repos --disable "*"
yum-config-manager --disable epel
subscription-manager repos --enable=rhel-7-server-rpms \
--enable=rhel-7-server-satellite-6.8-rpms \
--enable=rhel-7-server-satellite-maintenance-6-rpms \
--enable=rhel-server-rhscl-7-rpms \
--enable=rhel-7-server-ansible-2.9-rpms 
yum clean all
rm -rf /var/cache/yum
sleep 1
echo " "
echo "*********************************************************"
echo "INSTALLING SATELLITE COMPONENTS"
echo "*********************************************************"
echo "INSTALLING SATELLITE"
yum -q list installed bind &>/dev/null && echo "bind is installed" || yum install -y 'bind' --skip-broken
yum -q list installed bind-utils &>/dev/null && echo "bind-utils is installed" || yum install -y 'bind-utils' --skip-broken
yum -q list installed dhcp &>/dev/null && echo "dhcp is installed" || yum install -y 'dhcp' --skip-broken
yum -q list installed tftp &>/dev/null && echo "tftp is installed" || yum install 'tftp' -y --skip-broken
yum -q list installed tftp-server &>/dev/null && echo "tftp-server is installed" || yum install 'tftp-server' -y --skip-broken
yum -q list installed nfs-utils &>/dev/null && echo "nfs-utils is installed" || yum install 'nfs-utils' -y --skip-broken
yum -q list installed syslinux &>/dev/null && echo "syslinux is installed" || yum install 'syslinux' -y --skip-broken
yum -q list installed rh-mongodb34-syspaths &>/dev/null && echo "rh-mongodb34-syspaths is installed" || yum install -y 'rh-mongodb34-syspaths' --skip-broken 
yum -q list installed rh-mongodb34 &>/dev/null && echo "rh-mongodb34 is installed" || yum install -y 'rh-mongodb34' --skip-broken 
yum -q list installed rubygem-bundler &>/dev/null && echo "rubygem-bundler is installed" || yum install -y 'rubygem-bundler' --skip-broken 
yum -q list installed hivex &>/dev/null && echo "hivex is installed" || yum install -y 'hivex' --skip-broken 
yum -q list installed scrub &>/dev/null && echo "scrub is installed" || yum install -y 'scrub' --skip-broken 
yum -q list installed libguestfs-tools-c &>/dev/null && echo "libguestfs-tools-c is installed" || yum install -y 'libguestfs-tools-c' --skip-broken 
yum -q list installed perl-hivex &>/dev/null && echo "perl-hivex is installed" || yum install -y 'perl-hivex' --skip-broken 
yum -q list installed libguestfs &>/dev/null && echo "libguestfs is installed" || yum install -y 'libguestfs' --skip-broken 
yum -q list installed hexedit &>/dev/null && echo "hexedit is installed" || yum install -y 'hexedit' --skip-broken 
yum -q list installed smart_proxy &>/dev/null && echo "smart_proxy is installed" || yum install -y '*smart_proxy*' --skip-broken 
yum -q list installed foreman &>/dev/null && echo "foreman is installed" || yum install -y 'foreman' --skip-broken 
yum -q list installed grub2-efi-x64 &>/dev/null && echo "grub2-efi-x64 is installed" || yum install -y 'grub2-efi-x64' --skip-broken 
yum -q list installed satellite &>/dev/null && echo "satellite is installed" || yum install -y 'satellite' --skip-broken
rpm -e --nodeps postgresql-9.2.24-4.el7_8.x86_64
rpm -e --nodeps infoblox 
yum upgrade -y

cat > /usr/share/foreman-proxy/bundler.d/dhcp_remote_isc.rb << EOF
group :dhcp_remote_isc do
  gem 'rsec', '< 1'
end
gem 'smart_proxy_dhcp_remote_isc'
EOF


sudo touch ~/Downloads/RHTI/INSTALLNSAT
}

#-----------------------------------------------------------------------------------------------------------------------
#-------------------------------------------START OF SAT 6.X CONFIGURE SCRIPT-------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------

#--------------------------------------
function CONFSAT {
#--------------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo " " 
echo "*********************************************************"
echo "CONFIGURING SATELLITE"
echo "*********************************************************"
source /root/.bashrc
yum clean all
rm -rf /var/cache/yum
clear
echo "*****************************"
echo "CONFIGURING SATELLITE BASE"
echo "*****************************"
source /root/.bashrc
foreman-maintain packages unlock 
satellite-installer --scenario satellite -v \
--foreman-initial-admin-username="$ADMIN" \
--foreman-initial-admin-password="$ADMIN_PASSWORD" \
--foreman-initial-organization="$ORG" \
--foreman-initial-location "$LOC" \
--foreman-proxy-puppetca=true \
--foreman-proxy-tftp=true \
--foreman-proxy-tftp-managed=true \
--foreman-proxy-tftp-listen-on=both \
--foreman-proxy-tftp-servername="$(hostname)" \
--foreman-proxy-dns=true \
--foreman-proxy-dns-managed=true \
--foreman-proxy-dns-forwarders="$DNS" \
--foreman-proxy-dns-server="$(hostname)" \
--foreman-proxy-dns-interface="$SAT_INTERFACE" \
--foreman-proxy-dns-listen-on=both \
--foreman-proxy-dns-provider=nsupdate \
--foreman-proxy-dns-reverse="$DNS_REV" \
--foreman-proxy-dns-zone="$DOM" \
--enable-foreman-proxy-plugin-dhcp-remote-isc \
--enable-foreman-compute-vmware \
--enable-foreman-compute-libvirt \
--enable-foreman-compute-gce \
--enable-foreman-compute-ec2 \
--foreman-plugin-tasks-automatic-cleanup true \
--foreman-proxy-plugin-discovery-install-images true \
--enable-foreman-plugin-discovery \
--enable-foreman-plugin-bootdisk \
--enable-foreman-plugin-remote-execution \
--enable-foreman-proxy-plugin-remote-execution-ssh \
--foreman-proxy-dhcp=true \
--foreman-proxy-dhcp-managed=true \
--foreman-proxy-dhcp-gateway="$DHCP_GW" \
--foreman-proxy-dhcp-interface="$SAT_INTERFACE" \
--foreman-proxy-dhcp-listen-on="both" \
--foreman-proxy-dhcp-nameservers="$DHCP_DNS" \
--foreman-proxy-dhcp-range="$DHCP_RANGE" \
--foreman-proxy-dhcp-server="$INTERNALIP" 


echo " "
echo " " 
echo '*******************************************'
echo 'Settinging Permissions For Services'
echo '*******************************************'
foreman-maintain packages unlock
mv /usr/share/foreman-proxy/bundler.d/dhcp_remote_isc.rb /usr/share/foreman-proxy/bundler.d/dhcp_remote_isc.rb.bak
yum -q list installed foreman-discovery-image &>/dev/null && echo "foreman-discovery-image is installed" || yum install -y 'foreman-discovery-image' --skip-broken 
usermod -a -G named foreman-proxy
restorecon -v /etc/rndc.key
chown -v root:named /etc/rndc.key
chmod -v 640 /etc/rndc.key
mkdir -p /etc/systemd/system/dhcpd.service.d/

cat > /etc/systemd/system/dhcpd.service.d/interfaces.conf<< EOF
[Service]
ExecStart=/usr/sbin/dhcpd -f -cf /etc/dhcp/dhcpd.conf -user dhcpd -group dhcpd --no-pid "$INTERNAL"
EOF

usermod -a -G dhcpd foreman-proxy
usermod -a -G named foreman-proxy
usermod -a -G dhcpd admin
usermod -a -G named admin
usermod -a -G libvirt admin
usermod -a -G qemu admin



chmod o+rx /etc/dhcp/
chmod o+r /etc/dhcp/dhcpd.conf
#chattr +i /etc/dhcp/ /etc/dhcp/dhcpd.conf

echo " "
echo " " 
echo '*******************************************'
echo 'Starting and enabling Satellite services'
echo '*******************************************'
systemctl enable tftp.service
systemctl start tftp.service
systemctl restart dhcpd.service
systemctl enable named.service
systemctl start named.service
systemctl --system daemon-reload
foreman-maintain packages lock

sudo touch ~/Downloads/RHTI/CONFSAT
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
read -n1 -t "$COUNTDOWN" -p "Would like to use the DHCP server provided by Satellite? (default:y) y/n " INPUT
INPUT=${INPUT:-$DEFAULTDHCP}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo " "
echo "***************"
echo "DHCPD ENABLED"
echo "***************"
#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo " "
echo "***************"
echo "DHCPD DISABLED"
echo "***************"
chkconfig dhcpd off
service dhcpd stop
#foreman-maintain packages unlock
#satellite-installer --foreman-proxy-dhcp false
#foreman-maintain packages lock

#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
fi
sudo touch ~/Downloads/RHTI/CHECKDHCP
}

#--------------------------------------
function DISABLEEXTRAS {
#--------------------------------------
echo "*********************************************************"
echo "DISABLING EXTRA REPO"
echo "*********************************************************"
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
foreman-maintain packages unlock
subscription-manager repos --disable=rhel-7-server-extras-rpms
yum clean all 
rm -rf /var/cache/yum
sudo touch ~/Downloads/RHTI/DISABLEEXTRAS
}

#------------------------------
function HAMMERCONF {
#------------------------------
echo -ne "\e[8;40;170t"
source /root/.bashrc
echo "*********************************************************"
echo "Enabling Hammer for Satellite configuration tasks"
echo "Setting up hammer will list the Satellite username and password in the /root/.hammer/cli_config.yml file
with default permissions set to -rw-r--r--, if this is a security concern it is recommended the file is
deleted once the setup is complete"
echo "*********************************************************"
sleep 1
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
sudo touch ~/Downloads/RHTI/HAMMERCONF
}

# --------------------------------------
function CONFIG2 {
# --------------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo 'Pulling up the url so you can build and export the manifest
This must be saved into the ~/Downloads directory'
echo "*********************************************************"
echo " "
read -p "Press [Enter] to continue"
echo " "
echo "*********************************************************"
echo 'If you have put your manafest into ~/Downloads/'
echo "*********************************************************"
echo "Just making sure"
read -p "Press [Enter] to continue"
echo " "
echo "*********************************************************************"
echo 'WHEN PROMPTED PLEASE ENTER YOUR SATELLITE ADMIN/FOREMAN USERNAME AND PASSWORD'
echo "*********************************************************************"
source /root/.bashrc
hammer organization update --name $ORG
hammer location update --name $LOC
for i in $(ls /home/); do cp /home/$i/Downloads/manifest*zip ~/Downloads/ ; done
sudo -u admin hammer subscription upload --file /home/$i/Downloads/manifest*zip --organization $ORG
echo " "
echo "*********************************************************"
echo 'REFRESHING THE CAPSULE CONTENT'
echo "*********************************************************"
for i in $(hammer capsule list |awk -F '|' '{print $1}' |grep -v ID|grep -v -) ; do hammer capsule refresh-features --id=$i ; done 
sleep 1
echo " "
echo "*********************************************************"
echo 'SETTING SATELLITE ENV SETTINGS'
echo "*********************************************************"
hammer settings set --name default_download_policy --value on_demand
hammer settings set --name default_redhat_download_policy --value on_demand
hammer settings set --name default_proxy_download_policy --value on_demand
hammer settings set --name default_organization --value "$ORG"
hammer settings set --name default_location --value "$LOC"
hammer settings set --name discovery_organization --value "$ORG"
hammer settings set --name root_pass --value "$NODEPASS"
hammer settings set --name query_local_nameservers --value true
hammer settings set --name discovery_location --value "$LOC"
hammer settings set --name content_view_solve_dependencies --value true
hammer settings set --name remote_execution_by_default --value true
hammer settings set --name ansible_ssh_private_key_file --value /root/.ssh/id_rsa
hammer settings set --name unregister_delete_host --value true
hammer settings set --name default_puppet_environment --value production
hammer settings set --name ansible_verbosity --value "Level 3(-vvv)"
echo " "
echo "*********************************************************"
echo 'TUNING THE SATELLITE FOR MEDIUM '
echo "*********************************************************"
satellite-installer -v --tuning medium
echo " "
sudo touch ~/Downloads/RHTI/CONFIG2
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
sudo touch ~/Downloads/RHTI/STOPSPAMMINGVARLOG
}

#NOTE: Jenkins, CentOS Linux 7.9 Puppet Forge, Icinga, and Maven are examples of setting up a custom repository
#---START OF REPO CONFIGURE AND SYNC SCRIPT---
source /root/.bashrc
QMESSAGE7="Would you like to enable and sync RHEL 7 Content
This will enable:
 Red Hat Enterprise Linux 7 Server (Kickstart)
 Red Hat Enterprise Linux 7 Server
 Red Hat Satellite Tools 6.8 (for RHEL 7 Server)
 Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server
 Red Hat Enterprise Linux 7 Server - Extras
 Red Hat Enterprise Linux 7 Server - Optional
 Red Hat Enterprise Linux 7 Server - Supplementary
 Red Hat Enterprise Linux 7 Server - RH Common
 Extra Packages for Enterprise Linux 7
 "


QMESSAGE8="Would you like to enable and sync RHEL 8 Content
This will enable:
Red Hat Storage Native Client for RHEL 8 (RPMs)
Red Hat Enterprise Linux 8 for x86_64 - AppStream (RPMs)
Red Hat Enterprise Linux 8 for x86_64 - BaseOS (Kickstart)
Red Hat Enterprise Linux 8 for x86_64 - Supplementary (RPMs)
Red Hat Enterprise Linux 8 for x86_64 - BaseOS (RPMs)
Red Hat Satellite Tools 6.8 for RHEL 8 x86_64 (RPMs)
"

QMESSAGEJBOSS="Would you like to download JBoss Enterprise Application Platform 7 (RHEL 7 Server) content"
QMESSAGEVIRTAGENT="Would you like to download Red Hat Virtualization 4 Management Agents for RHEL 7 content"
QMESSAGESAT65="Would you like to download Red Hat Satellite 6.8 (for RHEL 7 Server) content"
QMESSAGECAP65="Would you like to download Red Hat Satellite Capsule 6.8 (for RHEL 7 Server) content"
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
QMESSAGEICENTOS7="Would you like to download CentOS Linux 7.9 custom content"
QMESSAGEISCIENTIFICLINUX7="Would you like to download SCIENTIFIC LINUX 7.9 custom content"

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
source /root/.bashrc
echo "Red Hat Enterprise Linux 7 Server (Kickstart)"
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7.9' --name 'Red Hat Enterprise Linux 7 Server (Kickstart)' 
hammer repository update --download-policy immediate --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 7 Server Kickstart x86_64 7.9'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 7 Server Kickstart x86_64 7.9' 2>/dev/null
echo "Red Hat Enterprise Linux 7 Server (RPMs)"
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Enterprise Linux 7 Server (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 7 Server RPMs x86_64 7Server' 2>/dev/null
echo "Red Hat Enterprise Linux 7 Server - Supplementary (RPMs)"
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Enterprise Linux 7 Server - Supplementary (RPMs)'
echo "Red Hat Enterprise Linux 7 Server - Optional (RPMs)"
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Enterprise Linux 7 Server - Optional (RPMs)'
echo "Red Hat Enterprise Linux 7 Server - Extras (RPMs)"
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --name 'Red Hat Enterprise Linux 7 Server - Extras (RPMs)'
echo "'Red Hat Satellite Tools 6.8 (for RHEL 7 Server) (RPMs)"
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --name 'Red Hat Satellite Tools 6.8 (for RHEL 7 Server) (RPMs)'
echo "Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server"
hammer repository-set enable --organization "$ORG" --product 'Red Hat Software Collections (for RHEL Server)' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server'
wget -q https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7Server -O /root/RPM-GPG-KEY-EPEL-7Server
sleep 1
hammer gpg create --key /root/RPM-GPG-KEY-EPEL-7Server --name 'GPG-EPEL-7Sever' --organization $ORG
sleep 1
hammer product create --name='Extra Packages for Enterprise Linux 7Server' --organization $ORG
sleep 1
echo "Extra Packages for Enterprise Linux 7Server"
hammer repository create --name='Extra Packages for Enterprise Linux 7Server' --organization $ORG --product='Extra Packages for Enterprise Linux 7Server' --content-type yum --publish-via-http=true --url=https://dl.fedoraproject.org/pub/epel/7Server/x86_64/
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Extra Packages for Enterprise Linux 7Server' 2>/dev/null
#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
fi
sudo touch ~/Downloads/RHTI/REQUEST7
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
echo "Red Hat Enterprise Linux 8 for x86_64 - BaseOS (Kickstart)"
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux for x86_64' --basearch='x86_64' --releasever='8.3' --name 'Red Hat Enterprise Linux 8 for x86_64 - BaseOS (Kickstart)'
hammer repository update --download-policy immediate --organization "$ORG" --product 'Red Hat Enterprise Linux for x86_64' --name 'Red Hat Enterprise Linux 8 for x86_64 - BaseOS Kickstart x86_64 8.3'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux for x86_64' --name 'Red Hat Enterprise Linux 8 for x86_64 - BaseOS Kickstart x86_64 8.3' 2>/dev/null
echo "Red Hat Enterprise Linux 8 for x86_64 - AppStream (RPMs)"
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux for x86_64' --basearch='x86_64' --releasever='8.3' --name 'Red Hat Enterprise Linux 8 for x86_64 - AppStream (RPMs)'
echo "Red Hat Enterprise Linux 8 for x86_64 - Supplementary (RPMs)"
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux for x86_64' --basearch='x86_64' --releasever='8.3' --name 'Red Hat Enterprise Linux 8 for x86_64 - Supplementary (RPMs)'
echo "Red Hat Enterprise Linux 8 for x86_64 - BaseOS (RPMs)"
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux for x86_64' --basearch='x86_64' --releasever='8.3' --name 'Red Hat Enterprise Linux 8 for x86_64 - BaseOS (RPMs)'
echo "Red Hat Satellite Tools 6.8 for RHEL 8 x86_64 (RPMs)"
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux for x86_64' --basearch='x86_64' --name 'Red Hat Satellite Tools 6.8 for RHEL 8 x86_64 (RPMs)' 
echo "Red Hat Storage Native Client for RHEL 8 (RPMs)"
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux for x86_64' --basearch='x86_64' --name 'Red Hat Storage Native Client for RHEL 8 (RPMs)'
wget -q https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-8 -O /root/RPM-GPG-KEY-EPEL-8
sleep 1
hammer gpg create --key /root/RPM-GPG-KEY-EPEL-8 --name 'RPM-GPG-KEY-EPEL-8' --organization $ORG
sleep 1
hammer product create --name='Extra Packages for Enterprise Linux 8' --organization $ORG
sleep 1
hammer repository create --name='Extra Packages for Enterprise Linux 8' --organization $ORG --product='Extra Packages for Enterprise Linux 8' --content-type yum --publish-via-http=true --url=https://dl.fedoraproject.org/pub/epel/8/Everything/x86_64/
echo "Extra Packages for Enterprise Linux 8"
hammer repository update --download-policy immediate --organization "$ORG" --product 'Extra Packages for Enterprise Linux 8' --name 'Extra Packages for Enterprise Linux 8'
time hammer repository synchronize --organization "$ORG" --product 'Extra Packages for Enterprise Linux 8' --name 'Extra Packages for Enterprise Linux 8' 2>/dev/null
#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
fi
sudo touch ~/Downloads/RHTI/REQUEST8
}

#-------------------------------
function REQUESTCENTOS7 {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "CentOS Linux 7.9:"
echo "*********************************************************"
read -n1 -t "$COUNTDOWN" -p "$QMESSAGEICENTOS7 ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
cd /root/Downloads
wget http://mirror.centos.org/centos/7.9.2003/os/x86_64/RPM-GPG-KEY-CentOS-7
hammer gpg create --organization $ORG --name RPM-GPG-KEY-CentOS-Linux-7.9 --key RPM-GPG-KEY-CentOS-7
hammer product create --name='CentOS Linux 7.9' --organization $ORG

hammer repository create --organization $ORG --name='CentOS Linux 7.9 (Kickstart)' --product='CentOS Linux 7.9' --content-type='yum' --gpg-key=RPM-GPG-KEY-CentOS-Linux-7.9 --publish-via-http=true --url=http://mirror.centos.org/centos/7.9.2003/os/x86_64/ 
time hammer repository synchronize --organization "$ORG" --product 'CentOS Linux 7.9' --name 'CentOS Linux 7.9 (Kickstart)' 2>/dev/null

hammer repository create --organization $ORG --name='CentOS Linux 7.9 CentOS Plus' --product='CentOS Linux 7.9' --content-type='yum' --gpg-key=RPM-GPG-KEY-CentOS-Linux-7.9 --publish-via-http=true --url=http://mirror.centos.org/centos/7.9.2003/centosplus/x86_64/ --checksum-type=sha256
time hammer repository synchronize --organization "$ORG" --product 'CentOS Linux 7.9' --name 'CentOS Linux 7.9 CentOSplus' 2>/dev/null

hammer repository create --organization $ORG --name='CentOS Linux 7.9 DotNET' --product='CentOS Linux 7.9' --content-type='yum' --gpg-key=RPM-GPG-KEY-CentOS-Linux-7.9 --publish-via-http=true --url=http://mirror.centos.org/centos/7.9.2003/dotnet/x86_64/ --checksum-type=sha256
time hammer repository synchronize --organization "$ORG" --product 'CentOS Linux 7.9' --name 'CentOS Linux 7.9 DotNET' 2>/dev/null

hammer repository create --organization $ORG --name='CentOS Linux 7.9 Extras' --product='CentOS Linux 7.9' --content-type='yum' --gpg-key=RPM-GPG-KEY-CentOS-Linux-7.9 --publish-via-http=true --url=http://mirror.centos.org/centos/7.9.2003/extras/x86_64/ --checksum-type=sha256
time hammer repository synchronize --organization "$ORG" --product 'CentOS Linux 7.9' --name 'CentOS Linux 7.9 Extras' 2>/dev/null

hammer repository create --organization $ORG --name='CentOS Linux 7.9 Fasttrack' --product='CentOS Linux 7.9' --content-type='yum' --gpg-key=RPM-GPG-KEY-CentOS-Linux-7.9 --publish-via-http=true --url=http://mirror.centos.org/centos/7.9.2003/fasttrack/x86_64/ --checksum-type=sha256
time hammer repository synchronize --organization "$ORG" --product 'CentOS Linux 7.9' --name 'CentOS Linux 7.9 Fasttrack' 2>/dev/null

hammer repository create --organization $ORG --name='CentOS Linux 7.9 Openshift Origin 311' --product='CentOS Linux 7.9' --content-type='yum' --gpg-key=RPM-GPG-KEY-CentOS-Linux-7.9 --publish-via-http=true --url=http://mirror.centos.org/centos/7.9.2003/paas/x86_64/openshift-origin311/ --checksum-type=sha256
time hammer repository synchronize --organization "$ORG" --product 'CentOS Linux 7.9' --name 'CentOS Linux 7.9 Openshift Origin 311' 2>/dev/null

hammer repository create --organization $ORG --name='CentOS Linux 7.9 OpsTools' --product='CentOS Linux 7.9' --content-type='yum' --gpg-key=RPM-GPG-KEY-CentOS-Linux-7.9 --publish-via-http=true --url=http://mirror.centos.org/centos/7.9.2003/opstools/x86_64/ --checksum-type=sha256
time hammer repository synchronize --organization "$ORG" --product 'CentOS Linux 7.9' --name 'CentOS Linux 7.9 OpsTools' 2>/dev/null

hammer repository create --organization $ORG --name='CentOS Linux 7.9 Updates' --product='CentOS Linux 7.9' --content-type='yum' --gpg-key=RPM-GPG-KEY-CentOS-Linux-7.9 --publish-via-http=true --url=http://mirror.centos.org/centos/7.9.2003/updates/x86_64/ --checksum-type=sha256
time hammer repository synchronize --organization "$ORG" --product 'CentOS Linux 7.9' --name 'CentOS Linux 7.9 Updates' 2>/dev/null

hammer repository create --organization $ORG --name='CentOS Linux 7.9 OpenStack Stein' --product='CentOS Linux 7.9' --content-type='yum' --gpg-key=RPM-GPG-KEY-CentOS-Linux-7.9 --publish-via-http=true --url=http://mirror.centos.org/centos/7.9.2003/cloud/x86_64/openstack-stein/ --checksum-type=sha256
time hammer repository synchronize --organization "$ORG" --product 'CentOS Linux 7.9' --name 'CentOS Linux 7.9 OpenStack Stein' 2>/dev/null

hammer repository create --organization $ORG --name='CentOS Linux 7.9 Config Management' --product='CentOS Linux 7.9' --content-type='yum' --gpg-key=RPM-GPG-KEY-CentOS-Linux-7.9 --publish-via-http=true --url=http://mirror.centos.org/centos/7.9.2003/configmanagement/x86_64/ansible-29/ --checksum-type=sha256
time hammer repository synchronize --organization "$ORG" --product 'CentOS Linux 7.9' --name 'CentOS Linux 7.9 Config Management' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
fi
sudo touch ~/Downloads/RHTI/REQUESTCENTOS7
}

#-------------------------------
function SYNC {
#------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "**************************************************************************"
echo "SYNC ALL REPOSITORIES (WAIT FOR THIS TO COMPLETE BEFORE CONTINUING):"
echo "**************************************************************************"
for i in $(hammer --csv repository list |grep -i kickstart | awk -F ',' '{print $1}' |sort -n ) ; do time hammer repository update --id $i --download-policy immediate ; done 
for i in $(hammer --csv repository list --organization $ORG | awk -F, {'print $1'} | grep -vi '^ID' |grep -v -i puppet |grep -v Id |sort -n); do time hammer repository synchronize --id ${i} --organization $ORG; done
echo " "
sudo touch ~/Downloads/RHTI/SYNC
}

#-------------------------------
function PRIDOMAIN {
#------------------------------
hammer domain set-parameter --domain $DOM --name $DOM --value $DOM
hammer domain set-parameter --name subnets --value $SUBNET_NAME --domain $DOM
for i in $(hammer --csv domain list |grep -v Id | awk -F ',' '{print $1}' |sort -n) ; do hammer domain update --id $i  ; done
sudo touch ~/Downloads/RHTI/PRIDOMAIN
}

#-------------------------------
function CREATESUBNET {
#------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "**************************************************************************"
echo "CREATE THE FIRST OR PRIMARY SUBNET TO CONNECT THE NODES TO THE SATELLITE:"
echo "**************************************************************************"
echo " "
hammer subnet create --name $SUBNET_NAME --network $INTERNALNETWORK --mask $SUBNET_MASK --gateway $DHCP_GW \
--dns-primary $DNS --dns-secondary $DNS2 --ipam 'Internal DB' --from $SUBNET_IPAM_BEGIN --to $SUBNET_IPAM_END \
--tftp-id 1 --dhcp-id 1 --domain-ids 1 --organizations $ORG --locations "$LOC" --domains $DOM --tftp $(hostname) \
 --dhcp $(hostname) --discovery-id 1 --dns $(hostname)
sudo touch ~/Downloads/RHTI/CREATESUBNET
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
time hammer lifecycle-environment create --name='DEV_RHEL_7' --prior='Library' --organization $ORG
echo "TEST_RHEL_7"
time hammer lifecycle-environment create --name='TEST_RHEL_7' --prior='DEV_RHEL_7' --organization $ORG
echo "PRODUCTION_RHEL_7"
time hammer lifecycle-environment create --name='PROD_RHEL_7' --prior='TEST_RHEL_7' --organization $ORG
echo "DEVLOPMENT_RHEL_8"
time hammer lifecycle-environment create --name='DEV_RHEL_8' --prior='Library' --organization $ORG
echo "TEST_RHEL_8"
time hammer lifecycle-environment create --name='TEST_RHEL_8' --prior='DEV_RHEL_8' --organization $ORG
echo "PRODUCTION_RHEL_8"
time hammer lifecycle-environment create --name='PROD_RHEL_8' --prior='TEST_RHEL_8' --organization $ORG
sudo touch ~/Downloads/RHTI/ENVIRONMENTS
}

#-------------------------------
function SYNCPLANS {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "Create sync plan:"
echo "*********************************************************"
echo "Daily_Sync"
hammer sync-plan create --name 'Daily_Sync' --description 'Daily Synchronization Plan' --organization $ORG --interval daily --sync-date $(date +"%Y-%m-%d")" 00:00:00" --enabled no
echo "Weekly_Sync (active)"
hammer sync-plan create --name 'Weekly_Sync' --description 'Weekly Synchronization Plan' --organization $ORG --interval weekly --sync-date $(date +"%Y-%m-%d")" 00:00:00" --enabled yes
hammer sync-plan list --organization $ORG
echo " "
sudo touch ~/Downloads/RHTI/SYNCPLANS
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
for i in $(hammer --csv product list --enabled yes --organization $ORG |grep -v "-" |grep -v ID| awk -F ',' '{print $1}'|sort -n) ; do time hammer product set-sync-plan --sync-plan-id=2 --organization $ORG --id=$i; done
sudo touch ~/Downloads/RHTI/ASSOCPLANTOPRODUCTS
}

#-------------------------------
function SYNCPLANCOMPONENTS {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
for i in $(hammer --csv product list --enabled yes --organization $ORG |grep -v "-" |grep -v ID| awk -F ',' '{print $1}'|sort -n) ; do time hammer product set-sync-plan --id $i --organization $ORG --sync-plan 'Weekly_Sync' ; done
sudo touch ~/Downloads/RHTI/SYNCPLANCOMPONENTS
}



#-------------------------------
function CONTENTVIEWS7 {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
#for i in $(hammer --csv repository list --organization $ORG | awk -F, {'print $1'} | grep -vi '^ID' |grep -v -i puppet |grep -v Id |sort -n); do time hammer repository synchronize --id ${i} --organization $ORG; done
echo "***********************************************"
echo "Create a content views"
echo "***********************************************"
echo " "
echo 'RHEL_7.9_x86_64'
hammer content-view create --organization $ORG --name 'RHEL_7.9_x86_64' --label RHEL_7-9_x86_64 --description 'RHEL 7.9'
echo " "
echo 'Adding Red Hat Enterprise Linux 7 Server '
hammer content-view add-repository --organization $ORG --name 'RHEL_7.9_x86_64' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server RPMs x86_64 7Server'
echo 'Adding Red Hat Enterprise Linux 7 Server Kickstart '
hammer content-view add-repository --organization $ORG --name 'RHEL_7.9_x86_64' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server Kickstart x86_64 7.9'
echo 'Adding Red Hat Satellite Tools 6.8 for RHEL 7 Server'
hammer content-view add-repository --organization $ORG --name 'RHEL_7.9_x86_64' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Satellite Tools 6.8 for RHEL 7 Server RPMs x86_64'
echo 'Adding Red Hat Software Collections'
hammer content-view add-repository --organization $ORG --name 'RHEL_7.9_x86_64' --product 'Red Hat Software Collections for RHEL Server' --repository 'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server x86_64 7Server'
echo 'Adding Red Hat Enterprise Linux 7 Server - Supplementary'
hammer content-view add-repository --organization $ORG --name 'RHEL_7.9_x86_64' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Supplementary RPMs x86_64 7Server'
echo 'Adding Red Hat Enterprise Linux 7 Server - RH Common'
hammer content-view add-repository --organization $ORG --name 'RHEL_7.9_x86_64' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - RH Common RPMs x86_64 7Server'
echo 'Adding Red Hat Enterprise Linux 7 Server - Optional'
hammer content-view add-repository --organization $ORG --name 'RHEL_7.9_x86_64' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Optional RPMs x86_64 7Server'
echo 'Adding Red Hat Enterprise Linux 7 Server - Extras'
hammer content-view add-repository --organization $ORG --name 'RHEL_7.9_x86_64' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Extras RPMs x86_64'

hammer content-view add-repository --organization $ORG --name 'RHEL_7.9_x86_64' --product 'Extra Packages for Enterprise Linux 7Server' --repository 'Extra Packages for Enterprise Linux 7Server'

hammer content-view add-repository --organization $ORG --name 'RHEL_7.9_x86_64' --product 'Red Hat Ansible Engine' --repository 'Red Hat Ansible Engine 2.9 RPMs for Red Hat Enterprise Linux 7 Server x86_64'

hammer content-view add-repository --organization $ORG --name 'RHEL_7.9_x86_64' --product 'Red Hat Enterprise Linux Server from RHUI' --repository 'Red Hat Enterprise Linux 7 Server - Extras from RHUI RPMs x86_64'


sleep 1
sudo touch ~/Downloads/RHTI/CONTENTVIEWS7
}

#-------------------------------
function CONTENTVIEWS8 {
#-------------------------------
echo " "
echo 'RHEL_8.3_x86_64'
hammer content-view create --organization $ORG --name 'RHEL_8.3_x86_64' --label RHEL_8-3_x86_64 --description 'RHEL 8.3'
echo " "
echo 'Adding Red Hat Enterprise Linux 8 for x86_64 - AppStream'
hammer content-view add-repository --organization $ORG --name 'RHEL_8.3_x86_64' --product 'Red Hat Enterprise Linux for x86_64' --repository 'Red Hat Enterprise Linux 8 for x86_64 - AppStream RPMs 8.3'
echo 'Adding Red Hat Enterprise Linux 8 for x86_64 - BaseOS Kickstart'
hammer content-view add-repository --organization $ORG --name 'RHEL_8.3_x86_64' --product 'Red Hat Enterprise Linux for x86_64' --repository 'Red Hat Enterprise Linux 8 for x86_64 - BaseOS Kickstart 8.3'
echo 'Adding Red Hat Enterprise Linux 8 for x86_64 - BaseOS '
hammer content-view add-repository --organization $ORG --name 'RHEL_8.3_x86_64' --product 'Red Hat Enterprise Linux for x86_64' --repository 'Red Hat Enterprise Linux 8 for x86_64 - BaseOS RPMs 8.3'
echo 'Adding Red Hat Enterprise Linux 8 for x86_64 - Supplementary '
hammer content-view add-repository --organization $ORG --name 'RHEL_8.3_x86_64' --product 'Red Hat Enterprise Linux for x86_64' --repository 'Red Hat Enterprise Linux 8 for x86_64 - Supplementary RPMs 8.3'
echo 'Adding Red Hat Satellite Tools 6.8 for RHEL 8'
hammer content-view add-repository --organization $ORG --name 'RHEL_8.3_x86_64' --product 'Red Hat Enterprise Linux for x86_64' --repository 'Red Hat Satellite Tools 6.8 for RHEL 8 x86_64 RPMs x86_64'
echo 'Adding Red Hat EPEL for RHEL 8'
hammer content-view add-repository --organization $ORG --name 'RHEL_8.3_x86_64' --product 'Red Hat Enterprise Linux for x86_64' --repository 'Extra Packages for Enterprise Linux 8'
sleep 1
sudo touch ~/Downloads/RHTI/CONTENTVIEWS8
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
echo "RHEL_7.9_x86_64 - Initial Publishing"
time hammer content-view publish --organization $ORG --name 'RHEL_7.9_x86_64' --description 'Initial Publishing' 2>/dev/null
sleep 500
echo "Library --> DEV_RHEL_7"
time hammer content-view version promote --organization $ORG --content-view 'RHEL_7.9_x86_64' --from-lifecycle-environment Library  --to-lifecycle-environment DEV_RHEL_7 2>/dev/null

echo "DEV_RHEL_7 --> TEST_RHEL_7"
time hammer content-view version promote --organization $ORG --content-view 'RHEL_7.9_x86_64' --from-lifecycle-environment DEV_RHEL_7 --to-lifecycle-environment TEST_RHEL_7 2>/dev/null

echo "TEST_RHEL_7 --> PROD_RHEL_7"
time hammer content-view version promote --organization $ORG --content-view 'RHEL_7.9_x86_64' --from-lifecycle-environment TEST_RHEL_7 --to-lifecycle-environment PROD_RHEL_7 2>/dev/null

touch ~/Downloads/RHTI/PUBLISHRHEL7CONTENT
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
echo "RHEL_8.3_x86_64 - Initial Publishing"
time hammer content-view publish --organization $ORG --name 'RHEL_8.3_x86_64' --description 'Initial Publishing' 2>/dev/null
sleep 500
echo "Library --> DEV_RHEL_8"
time hammer content-view version promote --organization $ORG --content-view 'RHEL_8.3_x86_64' --from-lifecycle-environment Library  --to-lifecycle-environment DEV_RHEL_8 2>/dev/null
echo "DEV_RHEL_8 --> TEST_RHEL_8"
time hammer content-view version promote --organization $ORG --content-view 'RHEL_8.3_x86_64' --from-lifecycle-environment DEV_RHEL_8 --to-lifecycle-environment TEST_RHEL_8 2>/dev/null
echo "TEST_RHEL_8 --> PROD_RHEL_8"
time hammer content-view version promote --organization $ORG --content-view 'RHEL_8.3_x86_64' --from-lifecycle-environment TEST_RHEL_8 --to-lifecycle-environment PROD_RHEL_8 2>/dev/null
sudo touch ~/Downloads/RHTI/PUBLISHRHEL8CONTENT
fi
}

#-------------------------------
function HOSTCOLLECTION {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "***********************************"
echo "Create a host collection for RHEL:"
echo "***********************************"
echo "RHEL_7.9_x86_64"
hammer host-collection create --name='RHEL_7.9_x86_64' --organization $ORG
echo "RHEL_8.3_x86_64"
hammer host-collection create --name='RHEL_8.3_x86_64' --organization $ORG
sleep 1
sudo touch ~/Downloads/RHTI/HOSTCOLLECTION
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
echo "Activation Key - DEV_RHEL_7"
hammer activation-key create --name 'DEV_RHEL_7.9' --organization $ORG --content-view='RHEL_7.9_x86_64' --lifecycle-environment 'DEV_RHEL_7'
echo "Activation Key - TEST_RHEL_7"
hammer activation-key create --name 'TEST_RHEL_7.9' --organization $ORG --content-view='RHEL_7.9_x86_64' --lifecycle-environment 'TEST_RHEL_7'
echo "Activation Key - PROD_RHEL_7"
hammer activation-key create --name 'PROD_RHEL_7.9' --organization $ORG --content-view='RHEL_7.9_x86_64' --lifecycle-environment 'PROD_RHEL_7'

echo "Activation Key - DEV_RHEL_8"
hammer activation-key create --name 'DEV_RHEL_8.3' --organization $ORG --content-view='RHEL_8.3_x86_64' --lifecycle-environment 'DEV_RHEL_8'
echo "Activation Key - TEST_RHEL_8"
hammer activation-key create --name 'TEST_RHEL_8.3' --organization $ORG --content-view='RHEL_8.3_x86_64' --lifecycle-environment 'TEST_RHEL_8'
echo "Activation Key - PROD_RHEL_8"
hammer activation-key create --name 'PROD_RHEL_8.3' --organization $ORG --content-view='RHEL_8.3_x86_64' --lifecycle-environment 'PROD_RHEL_8'
sudo touch ~/Downloads/RHTI/KEYSFORENV
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
for i in $(hammer --csv activation-key list --organization $ORG |grep -v ID |grep -v '-' |awk -F ',' '{print $2}' | grep RHEL_7); \
do hammer activation-key add-host-collection --name $i --host-collection='RHEL_7.9_x86_64' \
--organization $ORG; done
sleep 1
for i in $(hammer --csv activation-key list --organization $ORG |grep -v ID |grep -v '-' |awk -F ',' '{print $2}' | grep RHEL_8); \
do hammer activation-key add-host-collection --name $i --host-collection='RHEL_8.3_x86_64' \
--organization $ORG; done
sleep 1
for i in $(hammer --csv activation-key list --organization $ORG |grep -v ID |awk -F ',' '{print $2}' |grep Satellite_6); \
do hammer activation-key add-host-collection --name $i --host-collection='Satellite_6.8-RHEL_7.9_x86_64' \
--organization $ORG; done
sleep 1
sudo touch ~/Downloads/RHTI/KEYSTOHOST
}

#-------------------------------
function SUBTOKEYS {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "Add all subscriptions available to keys:"
echo "*********************************************************"
for i in $(hammer --csv activation-key list --organization $ORG | awk -F "," {'print $1'} | grep -vi '^ID'); \
do for j in $(hammer --csv subscription list --organization $ORG | awk -F "," {'print $1'} | grep -vi '^ID'); \
do hammer activation-key add-subscription --id ${i} --subscription-id ${j}; done; done
echo " "
echo "*********************************************************"
echo "Enable all the base content for each OS by default:"
echo "*********************************************************"
for i in $(hammer activation-key list --organization $ORG | grep -v ID | grep -v '-' | awk -F '|' '{print $1}') ; \
do hammer activation-key product-content --content-access-mode-all true --organization $ORG  --id $i ;done
sudo touch ~/Downloads/RHTI/SUBTOKEYS
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
hammer medium create --path=http://repos/${ORG}/Library/content/dist/rhel/server/7/7.9/x86_64/kickstart/ --organizations=$ORG --os-family=Redhat --name="RHEL 7.9 Kickstart" --operatingsystems="RedHat 7.9"

#RHEL 8 
hammer medium create --path=http://repos/${ORG}/Library/content/dist/rhel8/8.3/x86_64/baseos/kickstart --organizations=$ORG --os-family=Redhat --name="RHEL 8.3 Kickstart" --operatingsystems="RedHat 8.3"
sudo touch ~/Downloads/RHTI/MEDIUM
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
echo "MEDID1=$(hammer --csv medium list |grep 'RHEL 7.9' |awk -F "," {'print $1'} |grep -v Id)" >> /root/.bashrc
#echo "MEDID2=$(hammer --csv medium list |grep 'CentOS 7' |awk -F "," {'print $1'} |grep -v Id)" >> /root/.bashrc
echo "SUBNETID=$(hammer --csv subnet list |awk -F "," {'print $1'}| grep -v Id)" >> /root/.bashrc
echo "OSID1=$(hammer os list |grep -i "RedHat 7.9" |awk -F "|" {'print $1'})" >> /root/.bashrc
#echo "OSID2=$(hammer os list |grep -i "CentOS 7.9" |awk -F "|" {'print $1'})" >> /root/.bashrc
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
sudo touch ~/Downloads/RHTI/VARSETUP2
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
sudo touch ~/Downloads/RHTI/PARTITION_OS_PXE_TEMPLATE
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
for i in $LEL; do for j in $(hammer --csv environment list |awk -F "," {'print $2'}| awk -F "_" {'print $1'}|grep -v Name); do hammer hostgroup create --name RHEL-7.9-$j --puppet-environments $i --architecture-id $ARCHID --content-view-id $CVID --domain-id $DOMID --location-ids $LOCID --medium-id $MEDID1 --operatingsystem-id $OSID1 --organization-id=$ORGID --partition-table-id $PARTID --puppet-ca-proxy-id $PROXYID --subnet-id $SUBNETID --root-pass=rreeddhhaatt ; done; done
#for i in $LEL; do for j in $(hammer --csv environment list |awk -F "," {'print $2'}| awk -F "_" {'print $1'}|grep -v Name); do hammer hostgroup create --name CentOS Linux 7.9-$j --puppet-environments $i --architecture-id $ARCHID --content-view-id $CVID --domain-id $DOMID --location-ids $LOCID --medium-id $MEDID2 --operatingsystem-id $OSID2 --organization-id=$ORGID --partition-table-id $PARTID --puppet-ca-proxy-id $PROXYID --subnet-id $SUBNETID --root-pass=redhat ; done; done
sudo touch ~/Downloads/RHTI/HOSTGROUPS
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
for i in $(hammer --csv os list |awk -F ',' '{print $1}' |grep -v Id) ; do hammer template add-operatingsystem --operatingsystem-id $i --id 1 ;done
sudo touch ~/Downloads/RHTI/ADD_OS_TO_TEMPLATE
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
--add-port="5900-5930/tcp" \
--add-service "dhcp" \
--add-service "named" \
--add-service "satellite" \
--add-port="7911/tcp" 
firewall-cmd --runtime-to-permanent


echo 'Restricting Access to mongod to apache and root'
firewall-cmd  --direct --add-rule ipv4 filter OUTPUT 0 -o lo -p \
tcp -m tcp --dport 27017 -m owner --uid-owner apache -j ACCEPT \
&& firewall-cmd  --direct --add-rule ipv6 filter OUTPUT 0 -o lo -p \
tcp -m tcp --dport 27017 -m owner --uid-owner apache -j ACCEPT \
&& firewall-cmd  --direct --add-rule ipv4 filter OUTPUT 0 -o lo -p \
tcp -m tcp --dport 27017 -m owner --uid-owner root -j ACCEPT \
&& firewall-cmd  --direct --add-rule ipv6 filter OUTPUT 0 -o lo -p \
tcp -m tcp --dport 27017 -m owner --uid-owner root -j ACCEPT \
&& firewall-cmd  --direct --add-rule ipv4 filter OUTPUT 1 -o lo -p \
tcp -m tcp --dport 27017 -j DROP \
&& firewall-cmd  --direct --add-rule ipv6 filter OUTPUT 1 -o lo -p \
tcp -m tcp --dport 27017 -j DROP \
&& firewall-cmd  --direct --add-rule ipv4 filter OUTPUT 0 -o lo -p \
tcp -m tcp --dport 28017 -m owner --uid-owner apache -j ACCEPT \
&& firewall-cmd  --direct --add-rule ipv6 filter OUTPUT 0 -o lo -p \
tcp -m tcp --dport 28017 -m owner --uid-owner apache -j ACCEPT \
&& firewall-cmd  --direct --add-rule ipv4 filter OUTPUT 0 -o lo -p \
tcp -m tcp --dport 28017 -m owner --uid-owner root -j ACCEPT \
&& firewall-cmd  --direct --add-rule ipv6 filter OUTPUT 0 -o lo -p \
tcp -m tcp --dport 28017 -m owner --uid-owner root -j ACCEPT \
&& firewall-cmd  --direct --add-rule ipv4 filter OUTPUT 1 -o lo -p \
tcp -m tcp --dport 28017 -j DROP \
&& firewall-cmd  --direct --add-rule ipv6 filter OUTPUT 1 -o lo -p \
tcp -m tcp --dport 28017 -j DROP
firewall-cmd --runtime-to-permanent



firewall-cmd  --zone public --add-service mountd \
&& firewall-cmd --zone public --add-service rpc-bind \
&& firewall-cmd --zone public --add-service nfs \
firewall-cmd --runtime-to-permanent
sudo touch ~/Downloads/RHTI/SATREENABLEFOIREWALL
}

#-------------------------------
function SATDONE {
#-------------------------------
hammer template build-pxe-default
foreman-rake foreman_tasks:cleanup TASK_SEARCH='label = Actions::Katello::Repository::Sync' STATES='paused,pending,stopped' VERBOSE=true --trace
foreman-rake katello:delete_orphaned_content --trace
foreman-rake katello:reimport
foreman-rake apipie:cache:index --trace

echo 'YOU HAVE NOW COMPLETED INSTALLING SATELLITE! READY TO REBOOT'
read -p "Press [Enter] to continue"
sleep 1
sudo touch ~/Downloads/RHTI/SATDONE
sudo init 6
}

#-------------------------------
function DISASSOCIATE_TEMPLATES {
#------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "DELETE UNSUPPORTED COMPONENTS (DESTRUCTIVE - Removes all 
      non redhat templates)"
echo "*********************************************************"
echo " "
echo 'Alterator default
Alterator default finish
Alterator default PXELinux
alterator_pkglist
AutoYaST default
AutoYaST default user data
AutoYaST default iPXE
AutoYaST default PXELinux
AutoYaST SLES default
chef_client
coreos_cloudconfig
CoreOS provision
CoreOS PXELinux
Discovery Debian kexec
FreeBSD (mfsBSD) finish
FreeBSD (mfsBSD) provision
FreeBSD (mfsBSD) PXELinux
Jumpstart default
Jumpstart default finish
Jumpstart default PXEGrub
Junos default finish
Junos default SLAX
Junos default ZTP config
NX-OS default POAP setup
Preseed default
Preseed default finish
Preseed default PXEGrub2
Preseed default iPXE
Preseed default PXELinux
Preseed default user data
preseed_networking_setup
saltstack_minion
WAIK default PXELinux
XenServer default answerfile
XenServer default finish
XenServer default PXELinux '

read -p "To Continue Press [Enter] or use Ctrl+c to exit"
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
hammer template update --name "${INDEX}" --locked no
echo " "
echo Delete ${INDEX} from ${ORG}@${LOC}
hammer template delete --name "${INDEX}"
echo " "
done

sudo touch ~/Downloads/RHTI/DISASSOCIATE_TEMPLATES
}

#-------------------------------
function INSIGHTS {
#-------------------------------
satellite-maintain packages unlock
yum update python-requests -y
yum install redhat-access-insights -y
redhat-access-insights --register
sudo touch ~/Downloads/RHTI/INSIGHTS
satellite-maintain packages lock
}

#-------------------------------
function CLEANUP {
#-------------------------------
echo "**********************************"
echo 'Removing Temp Files'
echo "**********************************"
rm -rf ~/FILES
rm -rf /root/FILES
rm -rf /tmp/*
echo " "
echo "**********************************"
echo ' Restoring Original /root/.bashrc '
echo "**********************************"
mv -f /root/.bashrc.bak /root/.bashrc
echo " "
echo "******************************************"
echo ' Removing any initial node config reports '
echo "******************************************"
for i in $(hammer --csv config-report list |awk -F ',' '{print $1}' ) ; do hammer config-report delete --organization $ORG --location $LOC --id $i ; done
echo " "
echo "**************************************"
echo 'Setting up initial cache and Cleaning
     temp items made when building satellite'
echo "**************************************"
foreman-rake foreman_tasks:cleanup TASK_SEARCH='label = Actions::Katello::Repository::Sync' STATES='paused,pending,stopped' VERBOSE=true
foreman-rake katello:delete_orphaned_content
#foreman-rake db:migrate
#foreman-rake db:seed
#foreman-rake katello:reimport

sudo touch ~/Downloads/RHTI/CLEANUP
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
sleep 1
else
echo "Offline"
echo "This script requires access to 
 the network to run please fix your settings and try again"
sleep 1
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
echo "*******************"
echo "FIRST DISABLE REPOS"
echo "*******************"
subscription-manager repos --disable "*"
yum-config-manager --disable "*"
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
subscription-manager repos --enable rhel-7-server-rh-common-rpms \
 --enable rhel-7-server-extras-rpms \
 --enable rhel-7-server-optional-rpms \
 --enable rhel-7-server-supplementary-rpms \
 --enable rhel-server-rhscl-7-rpms \
 --enable rhel-7-server-rpms \
 --enable rhel-7-server-ansible-2.9-rpms
yum clean all
rm -rf /var/cache/yum
yum-config-manager --setopt=\*.skip_if_unavailable=1 --save \*
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
echo 'What would you like your default Ansible Tower user "admin" password to be?'
read ADMINPASSWORD
export $ADMINPASSWORD
sed -i 's/admin_password='"''"'/admin_password='"'"'$ADMINPASSWORD'"'"'/g' ~/Downloads/ansible-tower-setup-bundle-3.6.4-1/inventory
sed -i 's/pg_password='"''"'/pg_password='"'"'$ADMINPASSWORD'"'"'/g' ~/Downloads/ansible-tower-setup-bundle-3.6.4-1/inventory
sed -i 's/rabbitmq_password='"''"'/rabbitmq_password='"'"'$ADMINPASSWORD'"'"'/g' ~/Downloads/ansible-tower-setup-bundle-3.6.4-1/inventory
sh setup.sh
sleep 1
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
sleep 1
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
echo " "
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
sleep 1

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
1 "Satellite 6.8 INSTALL" \
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
sleep 1
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
TMPd=~/Downloads/RHTI/
while true
do
[[ -e "$TMPd" ]] || mkdir -p $TMPd
TmpFi=$(mktemp $TMPd/xcei.XXXXXXX )
dMainMenu > $TmpFi
RC=$?
[[ $RC -ne 0 ]] && break
Flag=$(cat $TmpFi)
case $Flag in
1) dMsgBx "Satellite 6.8 INSTALL" \
sleep 1
#SCRIPT
echo " "
SATELLITEREQUIREMENTS
SATELLITEREADME
echo " "

ls ~/Downloads/RHTI/SATREGISTER &>/dev/null
if [ $? -eq 0 ]; then
echo 'The Satellite registered, proceeding'
sleep 1
else
echo "Regestering Satellite, follow prompt"
echo " "
echo "***********"
echo "SATREGISTER"
echo "***********"
SATREGISTER
sleep 1
echo " "
fi
echo " "

ls ~/Downloads/RHTI/VARIABLES1 &>/dev/null
if [ $? -eq 0 ]; then
echo 'The Variables are complete, proceeding'
sleep 1
else
echo "Setting up Variables for Satellite stand by"
echo " "
echo "**********"
echo "VARIABLES1"
echo "**********"
VARIABLES1
sleep 1
echo " "
fi
echo " "

ls ~/Downloads/RHTI/SERVICEUSER &>/dev/null
if [ $? -eq 0 ]; then
echo 'The requirements to run this script have been met, proceeding'
sleep 1
else
echo "*******************************"
echo "FOREMAN Service Account 'admin'"
echo "*******************************"
echo "Installing service account please stand by"
SERVICEUSER
sleep 1
echo " "
fi

ls ~/Downloads/RHTI/INSTALLREPOS &>/dev/null
if [ $? -eq 0 ]; then
echo ' INSTALLREPOS Complete skipping'
sleep 1
else
echo "**********"
echo "INSTALLREPOS"
echo "**********"
INSTALLREPOS
sleep 1
fi
echo " "

ls ~/Downloads/RHTI/INSTALLDEPS &>/dev/null
if [ $? -eq 0 ]; then
echo ' INSTALLDEPS Complete skipping'
sleep 1
else
echo "**********"
echo "INSTALLDEPS"
echo "**********"
#INSTALLDEPS
fi
echo " "

ls ~/Downloads/RHTI/GENERALSETUP &>/dev/null
if [ $? -eq 0 ]; then
echo ' GENERALSETUP Complete skipping'
sleep 1
else
echo "************"
echo "GENERALSETUP"
echo "************"
GENERALSETUP
fi
echo " "

ls ~/Downloads/RHTI/SYSCHECK &>/dev/null
if [ $? -eq 0 ]; then
echo ' SYSCHECK Complete skipping'
sleep 1
else
echo "**********"
echo "SYSCHECK"
echo "**********"
SYSCHECK
fi
echo " "

ls ~/Downloads/RHTI/INSTALLNSAT &>/dev/null
if [ $? -eq 0 ]; then
echo ' INSTALLNSAT Complete skipping'
sleep 1
else
echo "***********"
echo "INSTALLNSAT"
echo "***********"
INSTALLNSAT
fi
echo " "

ls ~/Downloads/RHTI/CONFSAT &>/dev/null
if [ $? -eq 0 ]; then
echo ' CONFSAT Complete skipping'
sleep 1
else
echo "**********"
echo "CONFSAT"
echo "**********"
CONFSAT
fi
echo " "

ls ~/Downloads/RHTI/CONFSATCACHE &>/dev/null
if [ $? -eq 0 ]; then
echo ' CONFSATCACHE Complete skipping'
sleep 1
else
echo "************"
echo "CONFSATCACHE"
echo "************"
CONFSATCACHE
fi
echo " "

ls ~/Downloads/RHTI/CHECKDHCP &>/dev/null
if [ $? -eq 0 ]; then
echo ' CHECKDHCP Complete skipping'
sleep 1
else
echo "**********"
echo "CHECKDHCP"
echo "**********"
CHECKDHCP
fi
echo " "

ls ~/Downloads/RHTI/DISABLEEXTRAS &>/dev/null
if [ $? -eq 0 ]; then
echo ' DISABLEEXTRAS Complete skipping'
sleep 1
else
echo "*************"
echo "DISABLEEXTRAS"
echo "*************"
DISABLEEXTRAS
fi
echo " "

ls ~/Downloads/RHTI/HAMMERCONF &>/dev/null
if [ $? -eq 0 ]; then
echo ' HAMMERCONF Complete skipping'
sleep 1
else
echo "**********"
echo "HAMMERCONF"
echo "**********"
HAMMERCONF
fi
echo " "

ls ~/Downloads/RHTI/CONFIG2 &>/dev/null
if [ $? -eq 0 ]; then
echo ' CONFIG2 Complete skipping'
sleep 1
else
echo "*******"
echo "CONFIG2"
echo "*******"
CONFIG2
fi
echo " "

ls ~/Downloads/RHTI/STOPSPAMMINGVARLOG &>/dev/null
if [ $? -eq 0 ]; then
echo ' STOPSPAMMINGVARLOG Complete skipping'
sleep 1
else
echo "******************"
echo "STOPSPAMMINGVARLOG"
echo "******************"
STOPSPAMMINGVARLOG
fi
echo " "

ls ~/Downloads/RHTI/REQUEST7 &>/dev/null
if [ $? -eq 0 ]; then
echo 'REQUEST7 Complete skipping'
sleep 1
else
echo "**********"
echo "REQUEST7"
echo "**********"
REQUEST7
fi
echo " "

ls ~/Downloads/RHTI/REQUEST8 &>/dev/null
if [ $? -eq 0 ]; then
echo ' REQUEST8 Complete skipping'
sleep 1
else
echo "**********"
echo "REQUEST8"
echo "**********"
REQUEST8
fi
echo " "

ls ~/Downloads/RHTI/REQUESTCENTOS7 &>/dev/null
if [ $? -eq 0 ]; then
echo ' REQUESTCENTOS7 Complete skipping'
sleep 1
else
echo "**********"
echo "REQUESTCENTOS7"
echo "**********"
REQUESTCENTOS7
fi
echo " "

ls ~/Downloads/RHTI/SYNC &>/dev/null
if [ $? -eq 0 ]; then
echo ' SYNC Complete skipping'
sleep 1
else
echo "**********"
echo "SYNC"
echo "**********"
SYNC
fi
echo " "

ls ~/Downloads/RHTI/PRIDOMAIN &>/dev/null
if [ $? -eq 0 ]; then
echo ' PRIDOMAIN Complete skipping'
sleep 1
else
echo "**********"
echo "PRIDOMAIN"
echo "**********"
PRIDOMAIN
fi
echo " "

ls ~/Downloads/RHTI/CREATESUBNET &>/dev/null
if [ $? -eq 0 ]; then
echo ' CREATESUBNET Complete skipping'
sleep 1
else
echo "************"
echo "CREATESUBNET"
echo "************"
CREATESUBNET
fi
echo " "

ls ~/Downloads/RHTI/ENVIRONMENTS &>/dev/null
if [ $? -eq 0 ]; then
echo ' ENVIRONMENTS Complete skipping'
sleep 1
else
echo "************"
echo "ENVIRONMENTS"
echo "************"
ENVIRONMENTS
fi
echo " "

ls ~/Downloads/RHTI/SYNCPLANS &>/dev/null
if [ $? -eq 0 ]; then
echo ' SYNCPLANS Complete skipping'
sleep 1
else
echo "**********"
echo "SYNCPLANS"
echo "**********"
SYNCPLANS
fi
echo " "

ls ~/Downloads/RHTI/SYNCPLANCOMPONENTS &>/dev/null
if [ $? -eq 0 ]; then
echo ' SYNCPLANCOMPONENTS Complete skipping'
sleep 1
else
echo "******************"
echo "SYNCPLANCOMPONENTS"
echo "******************"
SYNCPLANCOMPONENTS
fi
echo " "

ls ~/Downloads/RHTI/ASSOCPLANTOPRODUCTS &>/dev/null
if [ $? -eq 0 ]; then
echo ' ASSOCPLANTOPRODUCTS Complete skipping'
sleep 1
else
echo "*******************"
echo "ASSOCPLANTOPRODUCTS"
echo "*******************"
ASSOCPLANTOPRODUCTS
fi
echo " "

ls ~/Downloads/RHTI/CONTENTVIEWS8 &>/dev/null
if [ $? -eq 0 ]; then
echo ' CONTENTVIEWS8 Complete skipping'
sleep 1
else
echo "************************"
echo "CONTENTVIEWS RHEL 8 "
echo "************************"
CONTENTVIEWS8
sleep 1
fi
echo " "

ls ~/Downloads/RHTI/CONTENTVIEWS7 &>/dev/null
if [ $? -eq 0 ]; then
echo ' CONTENTVIEWS7 Complete skipping'
sleep 1
else
echo "************************"
echo "CONTENTVIEWS RHEL 7 "
echo "************************"
CONTENTVIEWS7
sleep 1
fi
echo " "

ls ~/Downloads/RHTI/PUBLISHRHEL7CONTENT &>/dev/null
if [ $? -eq 0 ]; then
echo ' PUBLISHRHEL7CONTENT Complete skipping'
sleep 1
else
echo "*******************"
echo "PUBLISHRHEL7CONTENT"
echo "*******************"
PUBLISHRHEL7CONTENT
fi
echo " "

ls ~/Downloads/RHTI/PUBLISHRHEL8CONTENT &>/dev/null
if [ $? -eq 0 ]; then
echo ' PUBLISHRHEL8CONTENT Complete skipping'
sleep 1
else
echo "*******************"
echo "PUBLISHRHEL8CONTENT"
echo "*******************"
PUBLISHRHEL8CONTENT
fi
echo " "

ls ~/Downloads/RHTI/HOSTCOLLECTION &>/dev/null
if [ $? -eq 0 ]; then
echo ' HOSTCOLLECTION Complete skipping'
sleep 1
else
echo "*******************"
echo "HOSTCOLLECTION"
echo "*******************"
HOSTCOLLECTION
fi
echo " "

ls ~/Downloads/RHTI/KEYSFORENV &>/dev/null
if [ $? -eq 0 ]; then
echo ' KEYSFORENV Complete skipping'
sleep 1
else
echo "*******************"
echo "KEYSFORENV"
echo "*******************"
KEYSFORENV
fi
echo " "

ls ~/Downloads/RHTI/KEYSTOHOST &>/dev/null
if [ $? -eq 0 ]; then
echo ' KEYSTOHOST Complete skipping'
sleep 1
else
echo "*******************"
echo "KEYSTOHOST"
echo "*******************"
KEYSTOHOST
fi
echo " "

ls ~/Downloads/RHTI/SUBTOKEYS &>/dev/null
if [ $? -eq 0 ]; then
echo ' SUBTOKEYS Complete skipping'
sleep 1
else
echo "*******************"
echo "SUBTOKEYS"
echo "*******************"
SUBTOKEYS
fi
echo " "

ls ~/Downloads/RHTI/MEDIUM &>/dev/null
if [ $? -eq 0 ]; then
echo ' MEDIUM Complete skipping'
sleep 1
else
echo "*******************"
echo "MEDIUM"
echo "*******************"
MEDIUM
fi
echo " "

ls ~/Downloads/RHTI/INSIGHTS &>/dev/null
if [ $? -eq 0 ]; then
echo 'INSIGHTS Complete skipping'
sleep 1
else
echo "*******************"
echo "INSIGHTS"
echo "*******************"
INSIGHTS
fi
echo " "

ls ~/Downloads/RHTI/SATDONE &>/dev/null
if [ $? -eq 0 ]; then
echo 'SATDONE Complete skipping'
sleep 1
else
echo "*******************"
echo "SATDONE"
echo "*******************"
SATDONE
fi
echo " "

ls ~/Downloads/RHTI/SATREENABLEFOIREWALL &>/dev/null
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
CLEANUP
DISASSOCIATE_TEMPLATES
;;
4) dMsgBx "*** EXITING - THANK YOU ***"
break
;;
esac

done

exit 0
