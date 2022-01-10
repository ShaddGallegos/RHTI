# ANSIBLE GALAXY https://galaxy.ansible.com
---------------------------------------------------------

Ansible Galaxy is Ansible’s official hub for sharing Ansible content.

The listing below is just a small example of what is available on Ansible Galaxy if you want to build it, 
there is a good chance you will find an example here. 

## Roles or Collection
-------

ROLE

  * https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html

        Roles are ways of automatically loading certain vars_files, tasks, and handlers 
        based on a known file structure. Grouping content by roles also allows easy sharing of roles with other users.

Collections

  * https://docs.ansible.com/ansible/latest/user_guide/collections_using.html

        Collections are a distribution format for Ansible content that can include playbooks,
        roles, modules, and plugins. You can install and use collections through Ansible Galaxy.


To install a Role or Collection 

      ROLE:          ansible-galaxy install <user>.<project>

      COLLECTION:    ansible-galaxy collection install  <user>.<project>


Example from below 

     ansible-galaxy install ataha.linux_patching

## RHEL
-------

     * https://galaxy.ansible.com/ataha/linux_patching
     * https://galaxy.ansible.com/geerlingguy/php_roles
     * https://galaxy.ansible.com/ericsysmin/system
     * https://galaxy.ansible.com/geerlingguy/packer_rhel
     * https://galaxy.ansible.com/dsglaser/cis_security
     * https://galaxy.ansible.com/oatakan/rhel_upgrade
     * https://galaxy.ansible.com/ansible-network/rhel
     * https://galaxy.ansible.com/alikins/top_geerlingguy/packer_rhel
     * https://galaxy.ansible.com/nbigot/ansible-fail2ban
     * https://galaxy.ansible.com/redhatinsights/insights-client
     * https://galaxy.ansible.com/jlozadad/rhel_system_roles
     * https://galaxy.ansible.com/geerlingguy/java
     * https://galaxy.ansible.com/geerlingguy/apache
     * https://galaxy.ansible.com/datadog/datadog
     * https://galaxy.ansible.com/geerlingguy/jenkins
     * https://galaxy.ansible.com/vincentclee/ansible_rhel_workstation
     * https://galaxy.ansible.com/linux-system-roles/network
     * https://galaxy.ansible.com/samdoran/packer-rhel
     * https://galaxy.ansible.com/linux-system-roles/cockpit
     * https://galaxy.ansible.com/adriagalin/motd
     * https://galaxy.ansible.com/brianshumate/vault
     * https://galaxy.ansible.com/johanmeiring/sftp-server
     * https://galaxy.ansible.com/linux-system-roles/firewall
     * https://galaxy.ansible.com/centralpayment/rhel-subscription
     * https://galaxy.ansible.com/nycrecords/yum_config_manager
     * https://galaxy.ansible.com/ryandaniels/create_users
     * https://galaxy.ansible.com/bertvv/rh-base
     * https://galaxy.ansible.com/ryandaniels/server_update_reboot
     * https://galaxy.ansible.com/juliovp01/setup-role


## Macintosh
-------

     * https://galaxy.ansible.com/kinglouie/macos
     * https://galaxy.ansible.com/tkimball83/appzapper
     * https://galaxy.ansible.com/macstadium/xcode
     * https://galaxy.ansible.com/macstadium/osx_ci
     * https://galaxy.ansible.com/lafarer/osx-defaults
     * https://galaxy.ansible.com/brianhartsock/netatalk
     * https://galaxy.ansible.com/shashikant86/ios-dev
     * https://galaxy.ansible.com/proinsias/ansible-role-macos

## Microsoft
-------

     * https://galaxy.ansible.com/dabondi/o365
     * https://galaxy.ansible.com/robertdebock/microsoft_repository_keys
     * https://galaxy.ansible.com/ecchong/microsoft_packages
     * https://galaxy.ansible.com/sbaerlocher/onedrive
     * https://galaxy.ansible.com/deekayen/chocolatey
     * https://galaxy.ansible.com/gantsign/visual-studio-code
     * https://galaxy.ansible.com/deekayen/win_updates
     * https://galaxy.ansible.com/deekayen/schannel
     * https://galaxy.ansible.com/robertdebock/mssql
     * https://galaxy.ansible.com/svendewindt/omsagentlinux
     * https://galaxy.ansible.com/mycloudrevolution/veeam_setup
     * https://galaxy.ansible.com/rkm/dotnet_core

## Database
-------

     * https://galaxy.ansible.com/joelwking/mongodb
     * https://galaxy.ansible.com/softasap/mariadb_box
     * https://galaxy.ansible.com/jeqo/oracle-database
     * https://galaxy.ansible.com/geerlingguy/postgresql
     * https://galaxy.ansible.com/geerlingguy/adminer
     * https://galaxy.ansible.com/geerlingguy/mysql
     * https://galaxy.ansible.com/geerlingguy/redis
     * https://galaxy.ansible.com/lean_delivery/oracle_db
     * https://galaxy.ansible.com/ome/postgresql_backup
     * https://galaxy.ansible.com/oscbco/create_database_and_users
     * https://galaxy.ansible.com/bbaassssiiee/artifactory

## Cluster
-------

     * https://galaxy.ansible.com/opensvc/cluster
     * https://galaxy.ansible.com/dcos/cluster
     * https://galaxy.ansible.com/debops/debops
     * https://galaxy.ansible.com/community/kubernetes
     * https://galaxy.ansible.com/andrewrothstein/etcd-cluster
     * https://galaxy.ansible.com/ten7/flightdeck_cluster
     * https://galaxy.ansible.com/f5devcentral/bigip_ha_cluster
     * https://galaxy.ansible.com/ondrejhome/ha-cluster-pacemaker
     * https://galaxy.ansible.com/piwi3910/ansible_mariadb_galera_cluster
     * https://galaxy.ansible.com/andrewrothstein/couchdb-cluster

## HPC
-------

     * https://galaxy.ansible.com/stackhpc/cluster-infra
     * https://galaxy.ansible.com/jm1/dev_hpc
     * https://galaxy.ansible.com/lecorguille/singularity
     * https://galaxy.ansible.com/brucellino/hpc-wn-role
     * https://galaxy.ansible.com/brucellino/hpc-head-node
     * https://galaxy.ansible.com/idiv-biodiversity/repo-xcat
     * https://galaxy.ansible.com/pddg/singularity
     * https://galaxy.ansible.com/stackhpc/drac-facts
     * https://galaxy.ansible.com/stackhpc/drac
     * https://galaxy.ansible.com/stackhpc/os-images
     * 

## Security
-------

     * https://galaxy.ansible.com/ecchong/rhel8_stig
     * https://galaxy.ansible.com/redhatofficial/rhel7_stig
     * https://galaxy.ansible.com/polarisalpha/rhel7-stig
     * https://galaxy.ansible.com/mindpointgroup/rhel7-stig
     * https://galaxy.ansible.com/ansible-security-compliance/rhel7-role-stig-rhel7-disa
     * https://galaxy.ansible.com/redhatofficial/rhv4_rhvh_stig
     * https://galaxy.ansible.com/redhatofficial/rhel8_pci_dss
     * https://galaxy.ansible.com/redhatofficial/rhel7_pci_dss
     * https://galaxy.ansible.com/ansible-security-compliance/rhel7-role-pci-dss
     * https://galaxy.ansible.com/anthcourtney/cis-amazon-linux
     * https://galaxy.ansible.com/harryharcourt/ansible-rhel7-cis-benchmarks
     * https://galaxy.ansible.com/dockpack/hardened7
     * https://galaxy.ansible.com/dev-sec/os-hardening

## Cloud
-------

     * https://galaxy.ansible.com/huxoll/azure-cli
     * https://galaxy.ansible.com/ansible-network/azure
     * https://galaxy.ansible.com/gsoft/azure_devops_agent
     * https://galaxy.ansible.com/adfinis-sygroup/azure_linux_image
     * https://galaxy.ansible.com/ppouliot/container_linux_azure
     * https://galaxy.ansible.com/adambrassard/azure_virtualmachine
     * https://galaxy.ansible.com/geerlingguy/aws-inspector
     * https://galaxy.ansible.com/thiagoalmeidasa/aws_efs
     * https://galaxy.ansible.com/sansible/aws_vpc
     * https://galaxy.ansible.com/sansible/aws_vpc_additional_block
     * https://galaxy.ansible.com/markosamuli/aws_tools
     * https://galaxy.ansible.com/fogartyp/softlayer-deploy
     * https://galaxy.ansible.com/isca0/mpath

## IBM
-------

     * https://galaxy.ansible.com/ibm/blockchain_platform_manager
     * https://galaxy.ansible.com/jmbarros/slcli
     * https://galaxy.ansible.com/lanycrost/docker

## VMWare
-------

     * https://galaxy.ansible.com/oatakan/windows_vmware_tools
     * https://galaxy.ansible.com/vmware/vmware-workstation
     * https://galaxy.ansible.com/jtyr/ansible_vmware_vm_provisioning
     * https://galaxy.ansible.com/hamburger_software/vmware_ubuntu_cloud_image
     * https://galaxy.ansible.com/thulium_drake/vmware
     * https://galaxy.ansible.com/piwi3910/vmware_loginsight
     * https://galaxy.ansible.com/amtega/vmware_provisioner
     * https://galaxy.ansible.com/vmware/ovftool
     * https://galaxy.ansible.com/ruzickap/vmwaretools
     * https://galaxy.ansible.com/oatakan/windows_template_build
     * https://galaxy.ansible.com/oatakan/windows_vcenter_template
     * https://galaxy.ansible.com/oatakan/rhel_vcenter_template
     * https://galaxy.ansible.com/simplygeekuk/vmware_deploy_vro

## Active Directory
-------

     * https://galaxy.ansible.com/rikairchy/rhel_ad
     * https://galaxy.ansible.com/darrenswart/ad_group
     * https://galaxy.ansible.com/laslabs/linux-active-directory
     * https://galaxy.ansible.com/smlloyd/sssd_ad
     * https://galaxy.ansible.com/govcloud/ad
     * https://galaxy.ansible.com/amtega/win_dns_records
     * https://galaxy.ansible.com/thulium_drake/adjoin
     * https://galaxy.ansible.com/kami911/linux_ad
     * https://galaxy.ansible.com/robertdebock/ad_auth
     * https://galaxy.ansible.com/iyp-uk/linux-active-directory

## PowerBroker
-------

     * https://galaxy.ansible.com/jhu-sheridan-libraries/pbis
     * https://galaxy.ansible.com/mrlesmithjr/ansible-pbis-open
     * https://galaxy.ansible.com/alens/ansible-likewiseopen

## Services 
-------

     * https://galaxy.ansible.com/robertdebock/dns
     * https://galaxy.ansible.com/jdauphant/dns
     * https://galaxy.ansible.com/lennertmertens/dns
     * https://galaxy.ansible.com/ryezone_labs/dhcp
     * https://galaxy.ansible.com/marcusburghardt/ansible_role_dhcp
     * https://galaxy.ansible.com/linux-system-roles/firewall
     * https://galaxy.ansible.com/bertvv/vsftpd
     * https://galaxy.ansible.com/shomatan/vsftpd
     * https://galaxy.ansible.com/bertvv/tftp
     * https://galaxy.ansible.com/while_true_do/srv_tftp
     * https://galaxy.ansible.com/ericsysmin/system
     * https://galaxy.ansible.com/geerlingguy/ntp
     * https://galaxy.ansible.com/arillso/ntp
     * https://galaxy.ansible.com/narfman0/ansible-pxe
     * https://galaxy.ansible.com/shomatan/pxe-server-kickstart
     * https://galaxy.ansible.com/borkenpipe/ansible_pxe
     * https://galaxy.ansible.com/bertvv/pxeserver
     * https://galaxy.ansible.com/linaro/mr-provisioner
     * https://galaxy.ansible.com/grzegorznowak/ansible_ssh_login_notifications
     * https://galaxy.ansible.com/so5/ssh_hostbased_auth
     * https://galaxy.ansible.com/rywillia/ssh-copy-id
     * https://galaxy.ansible.com/bihealth/ssh_keys
     * https://galaxy.ansible.com/fgtatsuro/ssh-client
     * https://galaxy.ansible.com/gzm55/local_ssh_known_hosts
     * https://galaxy.ansible.com/sawatani/github_ssh

## Libvirt
-------

     * https://galaxy.ansible.com/stackhpc/libvirt-host
     * https://galaxy.ansible.com/stackhpc/libvirt-vm
     * https://galaxy.ansible.com/tcharl/ansible_role_libvirt_host
     * https://galaxy.ansible.com/mcgrof/libvirt_user
     * https://galaxy.ansible.com/rhjhunt/libvirt_vm
     * https://galaxy.ansible.com/mattgeddes/libvirt_kvm
     * https://galaxy.ansible.com/andrewrothstein/libvirt


## OpenShift
-------

     * https://galaxy.ansible.com/luisarizmendi/ocp_libvirt_ipi_role
     * https://galaxy.ansible.com/oybed/casl_galaxy
     * https://galaxy.ansible.com/andrewrothstein/openshift-origin-client-tools
     * https://galaxy.ansible.com/epfl_si/ansible_module_openshift
     * https://galaxy.ansible.com/openshift_labs/workshop_deployment_tracker
     * https://galaxy.ansible.com/adfinis-sygroup/openshift_backup
     * https://galaxy.ansible.com/siamaksade/openshift_coolstore
     * https://galaxy.ansible.com/jas02/openshift-bastion
     * https://galaxy.ansible.com/mcouliba/openshift_codeready_workspaces
     * https://galaxy.ansible.com/jas02/create-openshift-hosts
     * https://galaxy.ansible.com/jooho/openshift-custom-login-page
     * https://galaxy.ansible.com/jooho/openshift-custom-webconsole-logo
     * https://galaxy.ansible.com/gnuthought/openshift-provision
     * https://galaxy.ansible.com/magicalyak/minishift_up
     * https://galaxy.ansible.com/andrewrothstein/kubernetes-helm
     * https://galaxy.ansible.com/gantsign/helm
     * https://galaxy.ansible.com/lumina/helm_install
     * https://galaxy.ansible.com/geerlingguy/helm

## IPA/IDM
-------

     * https://galaxy.ansible.com/timorunge/freeipa_server
     * https://galaxy.ansible.com/timorunge/freeipa_client
     * https://galaxy.ansible.com/redhatgov/idm
     * https://galaxy.ansible.com/yabhinav/ipaserver

## RHV
-------

     * https://galaxy.ansible.com/redhatgov/rhv_vm
     * https://galaxy.ansible.com/ovirt/engine-setup
     * https://galaxy.ansible.com/ovirt/manageiq

## System
-------

     * https://galaxy.ansible.com/jgoutin/home
     * https://galaxy.ansible.com/mmorev/hashicorp
     * https://galaxy.ansible.com/geerlingguy/java
     * https://galaxy.ansible.com/geerlingguy/pip
     * https://galaxy.ansible.com/geerlingguy/nfs
     * https://galaxy.ansible.com/sensu/sensu
     * https://galaxy.ansible.com/arillso/logrotate
     * https://galaxy.ansible.com/yatesr/timezone
     * https://galaxy.ansible.com/geerlingguy/elasticsearch
     * https://galaxy.ansible.com/0x0i/systemd

## Git
-------

     * https://galaxy.ansible.com/geerlingguy/git
     * https://galaxy.ansible.com/geerlingguy/gitlab
     * https://galaxy.ansible.com/lvrfrc87/source_control
     * https://galaxy.ansible.com/robertdebock/git
     * https://galaxy.ansible.com/nephelaiio/git
     * https://galaxy.ansible.com/andrewrothstein/git
     * https://galaxy.ansible.com/weareinteractive/git
     * https://galaxy.ansible.com/while_true_do/app_git

## Development
-------

     * https://galaxy.ansible.com/geerlingguy/nginx
     * https://galaxy.ansible.com/geerlingguy/php
     * https://galaxy.ansible.com/geerlingguy/drush
     * https://galaxy.ansible.com/geerlingguy/drush
     * https://galaxy.ansible.com/geerlingguy/jenkins
     * https://galaxy.ansible.com/nginxinc/nginx
     * https://galaxy.ansible.com/geerlingguy/ruby
     * https://galaxy.ansible.com/robertdebock/buildtools
     * https://galaxy.ansible.com/louim/bedrock-site-protect
     * https://galaxy.ansible.com/gantsign/maven
     * https://galaxy.ansible.com/gantsign/golang

## Networking
-------

     * https://galaxy.ansible.com/zjpeterson/aci
     * https://galaxy.ansible.com/juniper/junos
     * https://galaxy.ansible.com/sbaerlocher/snmp
     * https://galaxy.ansible.com/dell-networking/dellos-vlan
     * https://galaxy.ansible.com/f5devcentral/f5ansible
     * https://galaxy.ansible.com/ansible-network/network-engine
     * https://galaxy.ansible.com/paloaltonetworks/paloaltonetworks
     * https://galaxy.ansible.com/ansible-network/cisco_ios
     * https://galaxy.ansible.com/lonemtntech/aci_fabric_manager
     * https://galaxy.ansible.com/stackhpc/mlnx-ufm

## Monitoring
-------

     * https://galaxy.ansible.com/fiaasco/icinga2
     * https://galaxy.ansible.com/community/grafana
     * https://galaxy.ansible.com/community/zabbix
     * https://galaxy.ansible.com/geerlingguy/kibana
     * https://galaxy.ansible.com/geerlingguy/logstash
     * https://galaxy.ansible.com/dj-wasabi/telegraf
     * https://galaxy.ansible.com/mrlesmithjr/elk-kibana
     * https://galaxy.ansible.com/bakhti/elk
     * https://galaxy.ansible.com/geerlingguy/logstash

## Bundles
-------

     * https://galaxy.ansible.com/newswangerd/collection_demo
     * https://galaxy.ansible.com/abaez/hashicluster
     * https://galaxy.ansible.com/pullyvan/epfl
     * https://galaxy.ansible.com/abaez/containers
     * https://galaxy.ansible.com/alancoding/everything
     * https://galaxy.ansible.com/n3pjk/servicenow
     * https://galaxy.ansible.com/pulp/pulp_installer

## Cyberark
-------

### Collections
     * https://galaxy.ansible.com/cyberark/pas
     * https://galaxy.ansible.com/cyberark/conjur
     
### Roles
     * https://galaxy.ansible.com/cyberark/conjur-host-identity
     * https://galaxy.ansible.com/cyberark/modules
     * https://galaxy.ansible.com/cyberark/password_lookup_plugin
     * https://galaxy.ansible.com/cyberark/conjur-lookup-plugin
     * https://galaxy.ansible.com/cyberark/aimprovider

## Ect, ect, ect



