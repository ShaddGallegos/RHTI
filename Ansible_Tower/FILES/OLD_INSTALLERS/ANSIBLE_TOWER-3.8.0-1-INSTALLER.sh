#!/bin/bash
# This installer will work on RHEL 7 or RHEL 8 and:
#1.verify you are root 
#2.Check you are connected to the internet.
#3.Provide a breif overview of what the tool is.
#4.Help the end user register with Red Hat if not already done.
#5.Take of some prep stuff install shut off firewall and selinux and install pip prior to install.
#6.Enable required repos for OS and Ansible Tower.
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
                                ANSIBLE-TOWER 3.8.0-1 INSTALLER FOR RHEL 7.x AND RHEL 8.x
                              FOR SETTING UP A SIMPLE SINGLE NODE CONFIGURATION FOR P.O.C.'
read -p " To Continue Press [Enter] or use Ctrl+c to exit the installer"

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
                                    di Connection to the internet so the installer can download the required packages
                                      eth0 internal Provisioning network
                                      eth1 external"
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

                        6. This install was tested with:
                           * RHEL_7.x in a KVM environment.
                           * Ansible Tower 3.8.0-1
                             https://releases.ansible.com/ansible-tower/setup-bundle/ansible-tower-setup-bundle-latest.el7.tar.gz
                           * Red Hat subscriber channels:
                                rhel-7-server-ansible-2.9-rpms
                                rhel-7-server-extras-rpms
                                rhel-7-server-optional-rpms
                                rhel-7-server-rpms
                                https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

                          * RHEL_8.x in a KVM environment.
                          * Ansible Tower 3.8.0-1 https://releases.ansible.com/ansible-tower/setup-bundle/ansible-tower-setup-bundle-latest.el8.tar.gz
                          * Red Hat subscriber channels:
                                ansible-2.9-for-rhel-8-x86_64-rpms
                                rhel-8-for-x86_64-appstream-rpms
                                rhel-8-for-x86_64-baseos-rpms
                                rhel-8-for-x86_64-supplementary-rpms
                                rhel-8-for-x86_64-optional-rpms
                                https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

        URL Resources 
            http://www.ansible.com
            https://www.ansible.com/tower-trial
            http://docs.ansible.com/ansible-tower/latest/html/quickinstall/index.html"
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
sleep 2 
fi
echo " "
echo " "
}

#-------------------------------
function ANSIBLESECURITY {
#-------------------------------
mkdir /root/Downloads
cd /root/Downloads
echo "***************************************************************************"
echo "SET SELINUX TO PERMISSIVE FOR THE INSTALL AND CONFIG OF Ansible Tower 3.8.0-1"
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
echo 'What would you like your default Ansible Tower user "admin" password to be?'
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
echo " "
echo "*******************"
echo "DISABLE REPOS"
echo "*******************"
subscription-manager repos --disable "*"
sleep 2
echo " "
echo " "
echo "*******************"
echo "ENABLE REPOS RHEL7 "
echo "*******************"
subscription-manager repos --enable rhel-7-server-extras-rpms --enable rhel-7-server-optional-rpms --enable rhel-7-server-supplementary-rpms --enable rhel-server-rhscl-7-rpms --enable rhel-7-server-rpms --enable rhel-7-server-ansible-2.9-rpms
yum -q list installed epel &>/dev/null && echo "epel is installed" || yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm --skip-broken
yum-config-manager --add-repo https://releases.ansible.com/ansible-tower/cli/ansible-tower-cli-el7.repo
yum clean all
rm -rf /var/cache/yum
yum-config-manager --setopt=\*.skip_if_unavailable=1 --save \*
echo " "
echo " "
sleep 2
echo "********************************"
echo "CHECKING AND INSTALLING PACKAGES"
echo "********************************"
yum-config-manager --enable epel 
yum clean all 
rm -rf /var/cache/yum
yum -q list installed ansible-tower-cli &>/dev/null && echo "ansible-tower-cli is installed" || dnf install -y ansible-tower-cli --skip-broken --noplugins 
yum -q list installed dnf &>/dev/null && echo "dnf is installed" || dnf install -y wget --skip-broken --noplugins 
yum -q list installed wget &>/dev/null && echo "wget is installed" || yum install -y wget --skip-broken --noplugins
yum -q list installed python3-pip &>/dev/null && echo "python3-pip is installed" || yum install -y python3-pip --skip-broken --noplugins
yum -q list installed yum-utils &>/dev/null && echo "yum-utils is installed" || yum install -y yum-util* --skip-broken --noplugins
yum -q list installed bash-completion-extras &>/dev/null && echo "bash-completion-extras is installed" || yum install -y bash-completion-extras --skip-broken --noplugins
yum -q list installed dconf &>/dev/null && echo "dconf is installed" || yum install -y dconf* --skip-broken --noplugins
yum -q list installed git &>/dev/null && echo "git is installed" || yum install -y git --skip-broken --noplugins --best --allowerasing
mkdir -p /root/Downloads/git 
cd /root/Downloads/git
git clone https://github.com/ansible/product-demos.git
cd /root/Downloads
yum-config-manager --disable epel
echo " "
echo " "
elif test $status -eq 1
then
echo '*******************'
echo 'ENABLE REPOS RHEL 8' 
echo '*******************'
subscription-manager repos --disable '*'
subscription-manager repos --enable ansible-2.9-for-rhel-8-x86_64-rpms --enable rhel-8-for-x86_64-appstream-rpms --enable rhel-8-for-x86_64-baseos-rpms --enable rhel-8-for-x86_64-supplementary-rpms 
yum -q list installed epel &>/dev/null && echo "epel is installed" || dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm --skip-broken
dnf config-manager --add-repo https://releases.ansible.com/ansible-tower/cli/ansible-tower-cli-el8.repo
yum -q list installed yum-utils &>/dev/null && echo "yum-utils is installed" || dnf install -y yum-utils --skip-broken
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
yum -q list installed ansible-tower-cli &>/dev/null && echo "ansible-tower-cli is installed" || dnf install -y ansible-tower-cli --skip-broken --noplugins 
yum -q list installed yum-utils &>/dev/null && echo "yum-utils is installed" || dnf install -y yum-util* --skip-broken --noplugins --best --allowerasing
yum -q list installed wget &>/dev/null && echo "wget is installed" || dnf install -y wget --skip-broken --noplugins --best --allowerasing
yum -q list installed python3-pip &>/dev/null && echo "python3-pip is installed" || dnf install -y python3-pip --skip-broken --noplugins --best --allowerasing
yum -q list installed platform-python-pip &>/dev/null && echo "platform-python-pip is installed" || dnf install -y platform-python-pip --skip-broken --noplugins --best --allowerasing
yum -q list installed dconf &>/dev/null && echo "dconf" || dnf install -y dconf* --skip-broken --noplugins --best --allowerasing
yum -q list installed dnf-utils &>/dev/null && echo "dnf-utils is installed" || dnf install -y dnf-utils --skip-broken --noplugins --best --allowerasing
yum -q list installed git &>/dev/null && echo "git is installed" || dnf install -y git --skip-broken --noplugins --best --allowerasing
mkdir -p /root/Downloads/git 
cd /root/Downloads
yum-config-manager --disable epel
echo " "
echo " "
sleep 2
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
dnf upgrade -y --skip-broken --best --allowerasing 
echo " "
echo " "
elif test $status -eq 1
then 
echo "*******************"
echo "Upgrade RHEL8 "
echo "*******************"
dnf upgrade -y --skip-broken --best --allowerasing 
echo " "
echo " "
fi
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
pip3 install --user --upgrade pip boto3 ansible-tower-cli boto botocore requests requests-credssp cryptography pywinrm PyVmomi azure-mgmt-compute azure-mgmt-resource azure-keyvault-secrets six netaddr passlib
deactivate
}

#-----------------------------
function ANSIBLEINSTALLTOWER {
#-----------------------------
grep -q -i "release 7." /etc/redhat-release
status=$?
if test $status -eq 0
then 
echo '****************************************************************'
echo 'Getting, Expanding, and installing Ansible Tower 3.8.0-1 for RHEL7'
echo '****************************************************************'
mkdir /root/Downloads
cd /root/Downloads
wget https://releases.ansible.com/ansible-tower/setup-bundle/ansible-tower-setup-bundle-3.8.0-1.tar.gz
tar -zxvf /root/Downloads/ansible-tower-setup-bundle-3.8.0-1.tar.gz 
cd /root/Downloads/ansible-tower-setup-bundle-3.8.0-1
dnf localinstall -y --skip-broken /root/Downloads/ansible-tower-setup-bundle-3.8.0-1/bundle/el7/repos/ansible-tower-dependencies/*.rpm  --best --allowerasing
sleep 2
echo " "
echo " " 
cd 
echo 'What would you like your default Ansible Tower user "admin" password to be?'
read ADMINPASSWORD
export $ADMINPASSWORD
sed -i 's/admin_password='"''"'/admin_password='"'"$ADMINPASSWORD"'"'/g' /root/Downloads/ansible-tower-setup-bundle-3.8.0-1/inventory
sed -i 's/pg_password='"''"'/pg_password='"'"$ADMINPASSWORD"'"'/g' /root/Downloads/ansible-tower-setup-bundle-3.8.0-1/inventory
sed -i 's/rabbitmq_password='"''"'/rabbitmq_password='"'"$ADMINPASSWORD"'"'/g' /root/Downloads/ansible-tower-setup-bundle-3.8.0-1/inventory
echo " "
echo " "
cd /root/Downloads/ansible-tower-setup-bundle-3.8.0-1
sh setup.sh
sleep 5
echo " "
echo " "
elif test $status -eq 1
then
echo '****************************************************************'
echo 'Getting, Expanding, and installing Ansible Tower 3.8.0-1 for RHEL8'
echo '****************************************************************'
mkdir /root/Downloads
cd /root/Downloads
wget https://releases.ansible.com/ansible-tower/setup-bundle/ansible-tower-setup-bundle-3.8.0-1.tar.gz
tar -zxvf /root/Downloads/ansible-tower-setup-bundle-3.8.0-1.tar.gz 
cd /root/Downloads/ansible-tower-setup-bundle-3.8.0-1
dnf localinstall -y --skip-broken /root/Downloads/ansible-tower-setup-bundle-3.8.0-1/bundle/el8/repos/ansible-tower-dependencies/*.rpm --best --allowerasing
sleep 2
echo " "
echo " "
echo 'What would you like your default Ansible Tower user "admin" password to be?'
read ADMINPASSWORD
export $ADMINPASSWORD
sed -i 's/admin_password='"''"'/admin_password='"'"$ADMINPASSWORD"'"'/g' /root/Downloads/ansible-tower-setup-bundle-3.8.0-1/inventory 
sed -i 's/pg_password='"''"'/pg_password='"'"$ADMINPASSWORD"'"'/g' /root/Downloads/ansible-tower-setup-bundle-3.8.0-1/inventory
sed -i 's/rabbitmq_password='"''"'/rabbitmq_password='"'"$ADMINPASSWORD"'"'/g' /root/Downloads/ansible-tower-setup-bundle-3.8.0-1/inventory
echo " "
echo " "
cd /root/Downloads/ansible-tower-setup-bundle-3.8.0-1/
sh setup.sh
sleep 5
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
echo '*******'
echo 'SELinux'
echo '*******'
echo '
         If you do not know what selinux is please visit
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
REQUEST
fi
}

#-------------------------
function ANSIBLEFIREWALL {
#-------------------------
echo " "
echo '********'
echo 'Firewall'
echo '********'
echo ''
echo '
         The ports used by Ansible Tower and its services are:
 
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
ANSIBLEFIREWALL
fi
} 

ANSIBLETOWERTXT
ANSIBLECHECKCONNECT
ANSIBLEREGISTER
ANSIBLESECURITY
#YOURUSER
#ADMINUSERS
ANSIBLESYSTEMREPOS
ANSIBLELINUXUPGRADE
#CloudRequirements
ANSIBLEINSTALLTOWER
ANSIBLESELINUX
ANSIBLEFIREWALL

fi
