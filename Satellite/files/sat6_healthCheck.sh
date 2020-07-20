#!/bin/sh

##############################
## Satellite 6 Health Check ##
##############################

######################
## Work In Progress 
##
## ToDo:
##
## - Add in remedial action for errors/warnings
## - Check all firewall reqs
## - Alter call depending on type (Sat6 or Capsule)
## - Add check for disconnected Sat6
##
######################

###############################
## Script settings & Constants
###############################

# Set script counters
WARNINGS=0
ERRORS=0

# Text colours
RED=`tput setaf 1`
GREEN=`tput setaf 2`
ORANGE=`tput setaf 3`
RESET=`tput sgr0`

# Environment information
HOSTNAME=$(hostname -f)
FACTER=$(which facter 2> /dev/null)
TOINSTALL=""
TMPDIR="/tmp/sat6_check"
release=$(awk '{print $7}' /etc/redhat-release | cut -c1)

# Check specific constants
FIREWALLD_XML="/usr/lib/firewalld/services/RH-Satellite-6.xml"
FIREWALL_REGEX="\"80|443|564[67]|5671|8140|8080|9090|67|68|53|69|53|5647\""
EXPECTED_PORTCOUNT=13

###############
## Functions ##
###############

## Output utility functions

function printOK {
  echo -e "${GREEN}[OK]\t\t $1 ${RESET}" | tee -a $TMPDIR/success
}

function printWarning {
  ((WARNINGS=WARNINGS+1))
  echo -e "${ORANGE}[WARNING] $WARNINGS\t $1 ${RESET}" | tee -a $TMPDIR/warnings
}

function printError {
    ((ERRORS=ERRORS+1))
  echo -e "${RED}[ERROR] $ERRORS\t $1 ${RESET}" | tee -a $TMPDIR/errors
}

function remedialAction {
  echo -e "$1" | tee -a $TMPDIR/remedialAction
}

## Test run setup / teardown functions

function clean_temp_directory {
   if [[ -d $TMPDIR ]]
   then
     rm -rf $TMPDIR
   fi
   mkdir -p $TMPDIR
}

function reset_remedial_action {
   touch $TMPDIR/remedialAction
}

function am_I_root {
  if [ "$EUID" -ne 0 ]
    then echo "Please run this script as root"
    exit 1
  fi
}

function check_hiera_symlink {
  if [ $(rpm -q hiera | wc -l) -gt 0 ]
    then 
    echo -e "hiera has been installed"
    if [ ! -L /etc/puppet/hiera.yaml ]
      then 
      printWarning "Missing hiera symlink from /etc/hiera.yaml -> /etc/puppet/hiera.yaml"
      echo -n "Would you like me to create it ? [y|N]:"
      read yesno
      if [ ${yesno} == 'y' ]
      then
      ln -s /etc/hiera.yaml /etc/puppet/hiera.yaml 
      fi 
    else
      printOK "Hiera symlink exists"
    fi
  fi  
}


function check_hammer_config_file {
    if [[ ! -f /root/.hammer/cli_config.yml ]]
    then
        echo -e "A hammer config file has not been created.  This is used to interogate foreman."
        echo -n "Would you like me to create this file ? [y|n] :"
        read yesno
        if [ ${yesno} == 'y' ]
        then
            echo -n "Please enter your admin username : "
            read username
            echo -n "Please enter your admin password : "
            read -s password

            mkdir /root/.hammer
            chmod 600 /root/.hammer
cat << EOF > /root/.hammer/cli_config.yml
:foreman:
     :host: 'https://$(hostname -f)'
     :username: '${username}'
     :password: '${password}'

EOF
        echo "/root/.hammer/cli_config.yml has been created"
    else
        echo -e "Please do the following:
    mkdir /root/.hammer
    chmod 600 /root/.hammer
    echo << EOF >> /root/.hammer/cli_config.yml
      :foreman:
           :host: 'https://$(hostname -f)'
           :username: 'admin'
           :password: 'password'

    EOF"
        exit 2
        fi
    fi

}

## Check functions

function check_admin_tools {
    MPSTAT=$(which mpstat >/dev/null 2>&1)
    a=$?
    if [[ $a != 0 ]]
    then
      toInstall="$toInstall sysstat"
    fi

    nmap=$(which nmap >/dev/null 2>&1)
    a=$?
    if [[ $a != 0 ]]
    then
      toInstall="$toInstall nmap"
    fi

    nslookup=$(which nslookup >/dev/null 2>&1)
    a=$?
    if [[ $a != 0 ]]
    then
      toInstall="$toInstall bind-utils"
    fi

    if [[ $toInstall != "" ]]
    then
    while true; do
        echo "Certain utilities are required for running this script: $toInstall"
        echo "After this script has run you may uninstall them if they are no longer needed."
        read -p "OK to install? (y/n) : " yn
        case $yn in
            [Yy]* ) yum -y install $toInstall; break;;
            [Nn]* ) echo " OK - health check stopped"; exit;;
            * ) echo "Please answer y or n.";;
        esac
    done
    fi
}

function checkDNS {
    host=$1
    echo -e "
     + Checking DNS entries for $host"

    ## Check the forward DNS record.
    forwardDNS=$(nslookup $host |  grep ^Name -A1 | awk '/^Address:/ {print $2}')
    if [[ ! -z $forwardDNS ]]
    then
      printOK "Forward DNS resolves to $forwardDNS"
    else
      printError "Forward DNS does not resolve"

    fi

    ## Check the reverse DNS record.
    reverseDNS=$(nslookup $forwardDNS | awk '/name/ {print $NF}' | rev | cut -c2- | rev)
    if [[ ! -z $reverseDNS ]]
    then
      printOK "Reverse DNS resolves to $reverseDNS"
    else
      printError "Reverse DNS not resolvable for $forwardDNS"
    fi

    ## Check the forward and reverse records match.
    if [[ $host == $reverseDNS ]]
    then
      printOK "Forward and reverse DNS match"
    else
      printError "Forward and reverse DNS do not match for $host / $reverseDNS"
    fi
    echo
}


function checkSubscriptions {
    # Check current subscriptions
    echo -e "
    #######################
      Subcription Details
    #######################
    + Checking enabled repositories (this could take some time)"
    subscription-manager repos --list-enabled > ${TMPDIR}/repos
    grep "^Repo Name" /tmp/sat6_check/repos
    SAT6VERSION=$(awk '/Satellite/ {print $6}' /tmp/sat6_check/repos)
    if [[ -z $SAT6VERSION ]]
     then
        printWarning "Unable to ascertain a valid Satellite repository?"
     else
        printOK " -  Repository installed for Satellite version $SAT6VERSION"
    fi
}

function getType {
    UPSTREAM=$(awk '/^hostname/ {print $3}' /etc/rhsm/rhsm.conf )
    if [[ $UPSTREAM == "subscription.rhn.redhat.com" ]]
    then
       # Connected Satellite Server
       printOK "This system is registered to $UPSTREAM which indicates it is a Satellite server"
       TYPE="Satellite"
    else
      # Satellite Capsule?
      if [[ $UPSTREAM == $HOSTNAME ]]
      then
        echo -e "This system is registered to itself ($HOSTNAME)"
        TYPE="Satellite"
      else
        TYPE="Capsule"
        echo "** This script only currently runs on Satellite servers not capsules.  A capsule version is currently being writted **"
        echo 3
      fi
    fi
}

function checkGeneralSetup {
    echo -e "
######################################
   Satellite 6 Health Check Report
######################################

+ System Details:
 - Hostname         : $(hostname)
 - IP Address       : $(ip -4 -o a | grep -v "127.0.0" | awk '{print $4}')
 - Kernel Version   : $(uname -r)
 - Uptime           : $(uptime | sed 's/.*up \([^,]*\), .*/\1/')
 - Last Reboot Time : $(who -b | awk '{print $3,$4}')
 - Red Hat Release  : $(cat /etc/redhat-release)"

    cpus=$(lscpu | grep -e "^CPU(s):" | cut -f2 -d: | awk '{print $1}')
    i=0
    echo " + CPU: %usr"
    echo "   ---------"
    while [ $i -lt $cpus ]
    do
      echo " - CPU${i} : $(mpstat -P ALL | awk -v var=$i '{ if ($2 == var ) print $3 }' )"
      let i=${i}+1
    done
    echo

    echo -e "
####################
## Checking umask ##
####################"

    umask=$(umask)
    if [[ $umask -ne "0022" ]]
    then
      printWarning "Umask is set to $umask which could cause problems with puppet module permissions.\n Recommend setting umask to 0022"
      else
      printOK "Umask is set to 0022"
    fi

}


function checkNetworkConnection {
    echo -e "
#######################
## Connection Status ##
#######################
    "
    # Connection to cdn.redhat.com
    echo " + Checking connection to cdn.redhat.com"
    ms=$(ping -c5 cdn.redhat.com | awk -F"/" '/^rtt/ {print $5}')
    echo " -  Complete.  Average was $ms ms"
}

function checkSELinux {
    echo " + Checking SELinux"
    selinux=$(getenforce)
    if [[ $selinux != "Enforcing" ]]
      then
        printWarning "SELinux is currently in $selinux mode. Enforcing is recommended by Red Hat"
      else
        printOK "SELinux is running in Enforcing mode."
    fi
}


function checkChronySynchronised {

    if [ $(chronyc sources | grep \* | wc -l) -eq 0 ]
    then
      printError "chronyd has no synchronised time source"
      remedialAction "wait for chrony to synchronise and check with 'chronyc sources list'"
    else
      printOK "chronyd is synchronised with a time server"
    fi
}

function checkFirewalldXML {
    ## Check the firewalld xml profile, suggest and offer to fix it.

    if [ $(egrep ${FIREWALL_REGEX} ${FIREWALLD_XML} | wc -l) -lt ${EXPECTED_PORTCOUNT} ]
    then
        printError "Incorrect firewalld manifest detected"
        echo -n "Would you like me to correct it ? [y|N] : "
        read yesno
        if [ $yesno == 'y' ]
        then
            echo "Correcting firewalld profile and reloading"
            fixFirewalldProfile
            firewall-cmd --add-service=RH-Satellite-6 --permanent
            firewall-cmd --reload
        else
            printWarning "Leaving the firewalld profile as is as is"
        fi
    else
        printOK "firewalld xml profile looks ok"
    fi

}

function checkService {
    service=$1
    echo " - Checking status of ${service}"
    if (( $release >= 7 ))
      then
         if [[ ${service} == "ntpd" ]]
         then
           return
         fi
         ## Is it running?
         running=$(systemctl is-active ${service} 2> /dev/null)
         if [[ $running == "active" ]]
           then
          printOK "${service} is running"

          if [[ ${service} == "chronyd" ]]
          then
              echo " + NTP Servers:"
              awk '/^server/ {print $2}' /etc/chrony.conf
              checkChronySynchronised
          fi
           else
          printError "${service} is not running"
          remedialAction "systemctl start ${service}"
         fi

         if [[ ${service} == "firewalld" ]]
          then
            checkFirewalldXML
          fi


         ## Is it enabled?
         enabled=$(systemctl is-enabled ${service} 2> /dev/null)
         if [[ $enabled == "enabled" ]]
           then
          printOK "${service} is enabled"
           else
         printWarning "${service} is not enabled to start on boot"
         remedialAction "systemctl enable ${service}"
         fi
      else
         if pgrep ${service} > /dev/null
         then
            printOK "${service} is running"
            if [[ ${service} == "ntpd" ]]
            then
               echo " + NTP Servers:"
               awk '/^server/ {print $2}' /etc/ntp.conf
            fi
         else
            printError "${service} is not running"
         fi
         if $( chkconfig ${service} )
            then
          printOK "${service} is enabled"
            else
          printWarning "${service} is not enabled to start on boot"
              remedialAction "service ${service} start "
         fi
    fi
}

function checkOSupdates {
    echo " + Checking for OS updates"
    yum check-update > $TMPDIR/updates
    if (( $(wc -l $TMPDIR/updates | awk '{print $1}') > 2 ))
     then
        printWarning "$(egrep -v "^Loaded|^$" $TMPDIR/updates | wc -l) updates available. These can be found in $TMPDIR/updates.  It is recommended to run yum -y update"
     else
        printOK "All Packages up to date"

    fi
}

function fixFirewalldProfile {
## Fix the broken firewalld profile shipped
cat << EOF > /usr/lib/firewalld/services/RH-Satellite-6.xml
<?xml version="1.0" encoding="utf-8"?>
<service>
  <short>Red Hat Satellite 6</short>
  <description>Red Hat Satellite 6 is a systems management server that can be used to configure new systems, subscribe to updates, and maintain installations in distributed environments.</description>
  <port protocol="tcp" port="80"/>
  <port protocol="tcp" port="443"/>
  <port protocol="tcp" port="5646-5647"/>
  <port protocol="tcp" port="5671"/>
  <port protocol="tcp" port="8140"/>
  <port protocol="tcp" port="8080"/>
  <port protocol="tcp" port="9090"/>
  <port protocol="udp" port="67"/>
  <port protocol="udp" port="68"/>
  <port protocol="tcp" port="53"/>
  <port protocol="udp" port="69"/>
  <port protocol="udp" port="53"/>
  <port protocol="tcp" port="5647"/>
</service>
EOF
}

function checkDisks {
    echo -e "
############################
 Checking Disk Partitions
############################"
    echo
    df -Pkh | grep -v 'Filesystem' > $TMPDIR/df.status
    while read DISK
    do
            LINE=$(echo $DISK | awk '{print $1,"\tMounted at ",$6,"\tis ",$5," used","\twith",$4," free space"}')
            mount=$(echo $DISK | awk '{print $1}')
            used=$(echo $DISK | awk '{print $5}' | rev | cut -c 2- | rev)
            echo -e $LINE
            if (( $used > 85 ))
            then
          printWarning "$mount has used more than 85% (${used}%).  Could be worth adding more storage?"
            fi

    done < $TMPDIR/df.status
    echo
    # Check pulp partition
    if (( $(df | grep -c pulp) < 1 ))
    then
        printWarning "/var/lib/pulp should be mounted on a separate partition"
    fi

    # Check mongo partition
    if (( $(df | grep -c mongo) < 1 ))
    then
        printWarning "/var/lib/mongodb should be mounted on a separate partition"
    fi

}

function checkFirewallRules {
    echo -e "
###########################
 Checking Firewall Rules
###########################"
    a=$(systemctl is-active firewalld 2> /dev/null)
    if [[ $a == "unknown" ]]
    then
        echo "Not checking firewall as it isn't currently running"
        return 1
    else
    iptables -n -L IN_public_allow > $TMPDIR/iptables
    cat << EOF >> $TMPDIR/iptables_required
tcp dpt:22
tcp dpt:443
tcp dpt:80
tcp dpt:8140
tcp dpt:9090
tcp dpt:8080
udp dpt:67
udp dpt:68
tcp dpt:53
udp dpt:69
udp dpt:53
tcp dpt:5671
tcp dpt:5647
EOF

    while read line
      do
        port=$(echo $line | awk -F":" '{print $2}')
        proto=$(echo $line | awk '{print $1}')
        if (( $(grep -c "$line" $TMPDIR/iptables) > 0 ))
          then
        printOK "$port ($proto) has been opened"
          else
        printError "$port ($proto) has NOT been opened"
        fi
      done < $TMPDIR/iptables_required
    fi
}

function checkSatelliteConfig {
    echo -e "
#######################################
## Checking Satellite Configuration  ##
#######################################"

    ## Organisations
    hammer --csv --csv-separator=" " organization list| sort -n | grep -v "Id " > $TMPDIR/orgs
    if (( $(grep -c "Default_Organization" $TMPDIR/orgs) > 0 ))
    then
      printWarning "The Default_Organization is still set.  Best to remove this in a production environment"
    fi


    ## Location List
    echo
    hammer --csv --csv-separator=" " location list | sort -n | grep -v "Id " > $TMPDIR/locations
    totalLocations=$(wc -l $TMPDIR/locations | awk '{print $1}')
    echo " + $totalLocations Locations found"
    while read line
    do
      id=$(echo $line | awk '{print $1}')
      location=$(echo $line | awk '{print $2}')
      hammer --output csv location  info --id=${id} > $TMPDIR/location_${location}
      totalSubnets=$(tr ',' '\n' < $TMPDIR/location_${location}  | grep -c Subnets)
      echo "  + Details for location \"${location}\" are in $TMPDIR/location_${location}"
      ## Add subnets
      echo "  - $totalSubnets Subnet(s) found for ${location}"
      for subnet in $(tr ',' '\n' < $TMPDIR/location_${location}  | grep -n  Subnets | awk -F":" '{print $1}')
      do
        locationSubnet=$(tail -1 $TMPDIR/location_${location} | awk -F"," -v net=${subnet} '{print $net}')
        echo "   - $locationSubnet"
      done

    done < $TMPDIR/locations

    ## Capsules
    echo
    hammer --csv --csv-separator=" " capsule list| sort -n | grep -v "Id " > $TMPDIR/capsules
    totalCapsules=$(wc -l $TMPDIR/capsules | awk '{print $1}')
    echo " + $totalCapsules Capsule(s) found"
    while read line
    do
      id=$(echo $line | awk '{print $1}')
      name=$(echo $line | awk '{print $2}')
      fqdn=$(echo $line | awk '{print $3}' | sed -e "s/[^/]*\/\/\([^@]*@\)\?\([^:/]*\).*/\2/")
      hammer capsule info --id=${id} > $TMPDIR/capsule_${name}
      echo " + Details for capsule \"${name}\" are in $TMPDIR/capsule_${name}"
      echo -ne " - Features: "
      awk '/Features: / {for (i=2; i<NF; i++) printf $i " "; print $NF}' $TMPDIR/capsule_${name}
      checkDNS ${fqdn}
      echo -e " + Checking network connectivity between $(hostname) and ${fqdn}"
      ping -c 1 ${fqdn} > /dev/null
      if [[ $? -eq 0 ]]
      then
        nmap -p T:443,5647,5646,8443,9090 ${fqdn} | grep "^[0-9]" > $TMPDIR/capsule_firewall_${name}
        while read nmap_line
        do
          port=$(echo $nmap_line | awk '{print $1}')
          status=$(echo $nmap_line | awk '{print $2}')
          if [[ $status == "closed" ]]
          then
        printWarning "Port $port is closed on $fqdn"
          else
        printOK "Port $port is open to $fqdn"
          fi
        done < $TMPDIR/capsule_firewall_${name}
      else
        printError "$fqdn is not responding to ping?"
      fi
    done < $TMPDIR/capsules

    ## Subnets
    echo
    echo " + Subnets"
    hammer --csv --csv-separator=" " subnet list| sort -n | grep -v "Id " > $TMPDIR/subnets
    while read line
    do
      id=$(echo $line | awk '{print $1}')
      name=$(echo $line | awk '{print $2}')
      hammer subnet info --id=${id} > $TMPDIR/subnet_${name}
      echo " - Details for subnet \"${name}\" are in $TMPDIR/subnet_${name}"
    done < $TMPDIR/subnets
}


function main {

#################
## MAIN SCRIPT ##
#################

## Pre checks
# Validate the script is being run by the correct user.
am_I_root

# Make sure the various admin tools are available
check_admin_tools

# Check the hammer configuration file exists and is valid
check_hammer_config_file

# Clean out the temporary directory
clean_temp_directory

# Reset the remedial action flag
reset_remedial_action

## Start checking the system
checkGeneralSetup
checkDisks
checkNetworkConnection
getType
checkSubscriptions
check_hiera_symlink

echo -e "
#######################
  Checking OS Services
#######################"
checkDNS $(hostname)
checkSELinux
checkOSupdates
for service in firewalld ntpd chronyd
do
  checkService ${service}
done
checkFirewallRules
echo -e "
#######################################
  Checking Katello/Satellite Services
#######################################"
for service in mongod qpidd qdrouterd tomcat foreman-proxy foreman-tasks pulp_celerybeat pulp_resource_manager pulp_workers httpd
do
  checkService ${service}
done

checkSatelliteConfig
display_results


}

function display_results {

    ####################
    ## Output Results ##
    ####################

    if (( $WARNINGS > 0 ))
    then
      echo
      echo " + Total Warnings: $WARNINGS"
      cat $TMPDIR/warnings
    else
      echo
      echo " + No warnings"
    fi

    if (( $ERRORS > 0 ))
    then
      echo
      echo " + Total Errors: $ERRORS"
      cat $TMPDIR/errors
      echo
    else
      echo
      echo " + No errors"
      echo
    fi

    if [[ -s $TMPDIR/remedialAction ]]
    then
      echo " + Remedial Action:"
      cat $TMPDIR/remedialAction
    fi
}

main
exit



# *** vim: set ts=2 et ai: ***
