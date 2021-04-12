* Table of contents below Intro, for Tools and Docs

# RED HAT MANAGEMENT PORTFOLIO
In every environment there is a core set of servers/services that are required to allow your users to interface with the systems they use daily in seamless operation. The Red Hat Management Portfolio can provide you with the tools you need from a User Front End, Provisioning, Orchestration, Automation, and Management for your environment. These systems will allow you to provide that next level of IT service to your end users/customers. 

My work is focused on: 

 * Ansible Tower
 * Satellite
 * InSights

![Red Hat Management](./PNG/Red_Hat_Management.png)

The key to success is always in the planning! The Venn diagram below depicts the primary functions between tools and the overlap between to help you decide where you would like to situate the functions, and assist in integrating the tools within your IT environment(s) 
## Satellite: 
The easiest way to manage your Red Hat infrastructure for efficient and compliant IT operations. Establish trusted content repos and processes that help you build a standards-based, secure Red Hat environment. 
## Ansible Tower: 
Simple, agentless automation platform that can improve your current processes, migrate apps for better optimization, and provide a single language for DevOps practices across your organization. Ansible Tower by Red Hat is a centralized API for your Ansible automation and a graphical user interface for Ansible.
## InSights: 
A predictive analytic tool with real-time, in-depth analysis of your Red Hat infrastructure, letting you predict and prevent problems before they occur.

![Portfolio Overlap](./PNG/RedHat_Management_Portfolio.png)

Working in tandem, this is what the optimal Management system would look like from a Red Hat perspective.

![E2E Management Portfolio](./PNG/E2E_RedHat_Management_PortfoliowServiceNow.png)

---------------------------
[1. Ansible and Ansible Tower](./Ansible_Tower)
---------------------------

        While the upstream Ansible community is known for fast-moving innovations, many enterprises
        require a more secure, stable and reliable approach. With Ansible Engine, organizations
        can access the tools and innovations available from the underlying Ansible technology in a
        hardened, enterprise-grade manner. Ansible Engine relies on the massive, global community 
        behind the Ansible project, and adds in the capabilities and assurance from Red Hat that 
        your business requires in order to comfortably adopt organization-wide automation, and 
        at any scale you can bring. 

[Community vs. Enterprise](https://www.ansible.com/products/engine)

        Both the Ansible project and Ansible Engine are open source technologies. The Ansible project
        is built by the community (ansible.com/community) for the benefit of the community. 
        Ansible Engine is developed by Red Hat with the explicit intent of being used as an 
        enterprise IT platform.

        Automation requires an investment in time, technology, and people. Make the most of your 
        investment with an enterprise automation platform that delivers supportability, agility
        and flexibility.

[Ansible Tower](https://www.ansible.com/products/tower)

        Solve problems once. Scale automation with control and insight. Collaborate across teams. 
        Manage policy enforcement and governance. Bring the power of automation to your whole 
        organization.

        With Red Hat Ansible Tower you can centralize and control your IT infrastructure with a visual
        dashboard, role-based access control, job scheduling, integrated notifications and graphical 
        inventory management. Easily embed Ansible Tower into existing tools and processes with REST 
        API and CLI.


Ansible and Ansible Tower should be the linchpin in your Enterprise and the foundation for your
your journey into automation

Ansible Features:

  * Simple
  * Powerful - hundreds of use cases 
  * Agentless
  * Cross platform – Linux, Windows, UNIX, IoT, etc...
  * Human readable - anyone can do it (no coding skills required) 
  * Perfect description of application - less time on documentation required
  * Version controlled
  * Dynamic inventories
  * Orchestration that plays well with others – hp sa, puppet, Jenkins, rhnss, etc.
  * The language of DevOps
 
Ansible Tower Features:

  * [Ansible Tower Editions](https://www.ansible.com/products/tower/editions) Standard vs Premium
  * Easy to understand and clean dashboard
  * Real-time job status updates
  * Multi-playbook workflows
  * Easy to see who ran what job when
  * Scale capacity with tower clusters
  * Integrated notifications
  * Schedule ansible jobs
  * Manage and track your entire inventory - Static or DYNAMIC INVENTORIES
  * Self-service it... simplified
  * Remote command execution
  * Comprehensive rest API and tower CLI tool
  * Role Based Access Control
  * LDAP, AD, and other authentication integration
  * Made easy config for your logging aggragator 

Ways To Interact With Ansible:

AD-Hoc

Playbooks

Roles


Ansible Collections 
       https://www.ansible.com/blog/getting-started-with-ansible-collections

 * Certified Content in Ansible Automation Hub
       https://access.redhat.com/articles/3642632

        New content is continuously made available for consumption. Managing content in this manner also becomes easier as modules, plugins, roles, and docs are packaged and tagged with a collection version. Modules can be updated, renamed, improved upon; roles can be updated to reflect changes in module interaction; docs can be regenerated to reflect the edits and all are packaged and tagged together.

        Before collections, it was not uncommon for modules to break or lack timely updates needed to interact with the services they were interfacing with. This often required Ansible users or Ansible Tower administrators to run multiple versions of Ansible in virtual environments in order to consume a patch that addressed a module issue. Ansible Content Collections bring stability and predictability by breaking modules out from the core distribution.
        For automated organizations, this means that certified content is readily available to be applied to use-cases ripe for automation from day one.

             By default ansible collections live in:
                  /etc/ansible/collections              
           
             Finding Collections Community:
                  https://galaxy.ansible.com/

             Redhat Supported Content:
                  https://cloud.redhat.com/ansible/automation-hub

[Request a Ansible Tower License](https://www.redhat.com/en/technologies/management/ansible/try-it?extIdCarryOver=true&sc_cid=701f2000001OH6uAAG)

## Resources

 * [Ansible_Cheat_Sheets](./Ansible_Tower/Ansible_Cheat_Sheets/) - Training vendors with nice wall cheat sheets for ansible visit their sites if you want more info
   * [1. Ansible-cheat-sheet-1](./Ansible_Tower/Ansible_Cheat_Sheets/Ansible-cheat-sheet-1.webp)
   * [2. Ansible_Cheat_Sheet-DevOps_Quickstart_Guide](./Ansible_Tower/Ansible_Cheat_Sheets/Ansible_Cheat_Sheet-DevOps_Quickstart_Guide.png)
   * [3. Ansible_Cheat_Sheet_Wall-Skills1 PNG](./Ansible_Tower/Ansible_Cheat_Sheets/Ansible_Cheat_Sheet_Wall-Skills1.png)
   * [4. Ansible-Cheat-Sheet_Wall-Skills2 PDF](./Ansible_Tower/Ansible_Cheat_Sheets/Ansible-Cheat-Sheet_Wall-Skills2.pdf)

 * [Ansible_DOC](./Ansible_Tower/Ansible_DOC/) - Currently MT

 * [Ansible_PDF](./Ansible_Tower/Ansible_PDF/)
   * [1. Ansible_Engine_and_Tower-Preferred_Practices](./Ansible_Tower/Ansible_PDF/Ansible_Engine_and_Tower-Preferred_Practices.pdf)
   * [2. Ansible_G2_Case_Study_Percussion](./Ansible_Tower/Ansible_PDF/Ansible_G2_Case_Study_Percussion.pdf)
   * [3. Ansible From Stack Overflow](./Ansible_Tower/Ansible_PDF/Ansible.pdf)
   * [4. Ansible_Tower-RBAC_Recommendations](./Ansible_Tower/Ansible_PDF/Ansible_Tower-RBAC_Recommendations.pdf)
   * [5. Ansible_Tower-Review_&_Customer_Use_Cases](./Ansible_Tower/Ansible_PDF/Ansible_Tower-Review_&_Customer_Use_Cases.pdf)
   * [6. Ansible_Tower_Training](./Ansible_Tower/Ansible_PDF/Ansible_Tower_Training.pd)
   * [7. Ansible_Tower-vs-awx](./Ansible_Tower/Ansible_PDF/Ansible_Tower-vs-awx.pdf)
   * [8. Getting_Started_with_RH_Ansible_Tower](./Ansible_Tower/Ansible_PDF/Getting_Started_with_RH_Ansible_Tower.pdf)

 * [Ansible_PPT](./Ansible_Tower/Ansible_PPT/)
   * [1. Ansible_Automation_Platform](./Ansible_Tower/Ansible_PPT/Ansible_Automation_Platform.pptx)
   * [2. Ansible_Importance_Deck](./Ansible_Tower/Ansible_PPT/Ansible_Importance_Deck.pptx)
   * [3. Ansible_Tower](./Ansible_Tower/Ansible_PPT/Ansible_Tower.pptx)
   * [4. Networking_Deck](./Ansible_Tower/Ansible_PPT/Networking_Deck.pptx)
   * [5. Ansible_Best_Practices](./Ansible_Tower/Ansible_PPT/Ansible_Best_Practices.pptx)
   * [6. Ansible_Technical](./Ansible_Tower/Ansible_PPT/Ansible_Technical.pptx)
   * [7. Ansible_Windows_Automation](./Ansible_Tower/Ansible_PPT/Ansible_Windows_Automation.pptx)
   * [8. Standard_Ansible_Tower](./Ansible_Tower/Ansible_PPT/Standard_Ansible_Tower.pptx)
   * [9. Ansible_Deck](./Ansible_Tower/Ansible_PPT/Ansible_Deck.pptx)
   * [10. Ansible_Tower_Automation](./Ansible_Tower/Ansible_PPT/Ansible_Tower_Automation.pptx)
   * [11. MBU_Red_Hat_Ansible_Automation_Platform_Technical_Deck](./Ansible_Tower/Ansible_PPT/MBU_Red_Hat_Ansible_Automation_Platform_Technical_Deck.pptx)

 * [Ansible Use Cases](https://github.com/ShaddGallegos/RHTI/blob/master/Ansible_Tower/Ansible_Use_Cases/Ansible%20Use%20Case%20List.xlsx) - Downloads the xls spread sheet

 * [Ansible_Video_Demos](./Ansible_Tower/Ansible_Video_Demos/)
   * [1. Ansible_automation_analytics](./Ansible_Tower/Ansible_Video_Demos/DEMO_1-Ansible_automation_analytics.mp4)
   * [2. Ansible_multivendor_network_automation](./Ansible_Tower/Ansible_Video_Demos/DEMO_2-Ansible_multivendor_network_automation.mp4)
   * [3. Ansible_provisions_Red_Hat_Enterprise_Linux_on_AWS](./Ansible_Tower/Ansible_Video_Demos/DEMO_3-Ansible_provisions_Red_Hat_Enterprise_Linux_on_AWS.mp4)
   * [4. Ansible_automation_security_response](./Ansible_Tower/Ansible_Video_Demos/DEMO_4-Ansible_automation_security_response.mp4)
   * [5.Red_Hat_Ansible_Tower_application_deployment](./Ansible_Tower/Ansible_Video_Demos/DEMO_5_-Red_Hat_Ansible_Tower_application_deployment.mp4)
   * [6. ansible-helm-jenkins-demo](./Ansible_Tower/Ansible_Video_Demos/DEMO_6-ansible-helm-jenkins-demo.mp4)
   * [7. Red_Hat_Ansible_Tower_with_ServiceNow](./Ansible_Tower/Ansible_Video_Demos/DEMO_7-Red_Hat_Ansible_Tower_with_ServiceNow.mp4)
   * [8. Red_Hat_Ansible_Tower_workflow](./Ansible_Tower/Ansible_Video_Demos/DEMO_8-Red_Hat_Ansible_Tower_workflow.mp4)
   * [9. Introduction_to_the_expanded_Red_Hat_Insights](./Ansible_Tower/Ansible_Video_Demos/DEMO_9-Introduction_to_the_expanded_Red_Hat_Insights.mp4)

 * [Ansible Playbook Examples](./Ansible_Tower/Ansible_Resources/ANSIBLE_GITHUB.md)
 * [Ansible Galaxy Roll Examples](./Ansible_Tower/Ansible_Resources/ANSIBLE_GALAXY.md)
 * [Internet Resources](./Ansible_Tower/Ansible_Resources/Internet_Resources/README.md) - Vendor specific resources all in one spot.

 * [Ansible, From The Command Line](./Ansible_Tower/Ansible_Resources/ANSIBLE_COMMANDLINE.md)
 * [Ansible Roadmap](https://docs.ansible.com/ansible/devel/roadmap/index.html#roadmaps)

 * [Ansible The Next Release](https://github.com/ansible-community/ansible-build-data/blob/main/2.10/CHANGELOG-v2.10.rst)
        NOTE: Stay at Ansible v2.9.x - DO NOT upgrade to 2.10 yet 

#### Simple Scripts for installing Ansible Tower P.O.C on a single node/vm on RHEL7/8:
        
        NOTE: Ansible Tower is one of the easiest things to install at Red Hat the 
              scripts below are something I made to help a windows person install Ansible Tower 
              on a linux system without thought. The scripts only install on a standalone if you 
              are going to install this in an Enterprise environment you need to 
              look at the architectural recomendations at: 
              https://docs.ansible.com/ansible-tower/latest/html/administration/clustering.html

###### THE ARCHITECTURE FOR AN ENTERPRISE DEPLOYMENT
![E2E Management Portfolio](./Ansible_Tower/PNG/AnsibleCluster.png)

        DISCLAMER: Also these are "my scripts" and are not supported in any way (use at own risk) 
                   Do not use on a currently running production system. No implied warrenty or other.
 
 * [ANSIBLE_TOWER-3.6.4-1-INSTALLER.sh](https://github.com/ShaddGallegos/RHTI/blob/master/Ansible_Tower/FILES/ANSIBLE_TOWER-3.6.4-1-INSTALLER.sh)
 * [ANSIBLE_TOWER-3.7.0-4-INSTALLER.sh](https://github.com/ShaddGallegos/RHTI/blob/master/Ansible_Tower/FILES/ANSIBLE_TOWER-3.7.0-4-INSTALLER.sh)
 * [ANSIBLE_TOWER-3.7.1-1-INSTALLER.sh](https://github.com/ShaddGallegos/RHTI/blob/master/Ansible_Tower/FILES/ANSIBLE_TOWER-3.7.1-1-INSTALLER.sh)

#### FREE Ansible Tower Workshops (listed below)
---------------------------------

 * Instructor-led (In person or remote)  - Contact your Red Hat Technical Account Manager, Account Solutions Architect, or Sales Team.
 * Or in true Red Hat/Opensource fashion, Red Hat provides you the code to set it up for yourself!

[Red Hat Workshops](https://github.com/ansible/workshops) - Code for building workshops.

6 hour workshops:

| Workshop   | Presentation Deck  | Exercises  | Workshop Type Var   |
|---|---|---|---|
| **Ansible Red Hat Enterprise Linux Workshop** <br> focused on automating Linux platforms like Red Hat Enterprise Linux  | [Deck](https://github.com/ansible/workshops/blob/devel/decks/ansible_rhel.pdf) | [Exercises](https://github.com/ansible/workshops/tree/devel/exercises/ansible_rhel)  | `workshop_type: rhel`  |
| **Ansible Network Automation Workshop** <br> focused on router and switch platforms like Arista, Cisco, Juniper   | [Deck](https://github.com/ansible/workshops/blob/devel/decks/ansible_network.pdf) | [Exercises](https://github.com/ansible/workshops/tree/devel/exercises/ansible_network)  | `workshop_type: network`  |
| **Ansible F5 Workshop** <br> focused on automation of F5 BIG-IP  | [Deck](https://github.com/ansible/workshops/blob/devel/decks/ansible_f5.pdf) | [Exercises](https://github.com/ansible/workshops/tree/devel/exercises/ansible_f5)   | `workshop_type: f5` |
| **Ansible Security Automation** <br> focused on automation of security tools like Check Point Firewall, IBM QRadar and the IDS Snort  | [Deck](https://github.com/ansible/workshops/blob/devel/decks/ansible_security.pdf) | [Exercises](https://github.com/ansible/workshops/tree/devel/exercises/ansible_security)   | `workshop_type: security` |
| **Ansible Windows Automation Workshop** <br> focused on automation of Microsoft Windows  | [Deck](https://github.com/ansible/workshops/blob/devel/decks/ansible_windows.pdf) | [Exercises](https://github.com/ansible/workshops/tree/devel/exercises/ansible_windows)   | `workshop_type: windows` |

90 minute abbreviated versions:

| Workshop   | Presentation Deck  | Exercises  | Workshop Type Var   |
|---|---|---|---|
| **Ansible Red Hat Enterprise Linux Workshop** <br> focused on automating Linux platforms like Red Hat Enterprise Linux  | [Deck](https://github.com/ansible/workshops/blob/devel/decks/ansible_rhel_90.pdf) | [Exercises](https://github.com/ansible/workshops/tree/devel/exercises/ansible_rhel_90)  | `workshop_type: rhel_90`  |

#### Lab Provisioner

 - [AWS Lab Provisioner](https://github.com/ansible/workshops/tree/devel/provisioner) - Playbook that spins up instances on AWS for students to perform the exercises provided above.

#### Self Paced Exercises

 - [Vagrant Demo](https://github.com/ansible/workshops/tree/devel/vagrant-demo) - Self-paced network automation exercises that can be run on your personal laptop

---------------------------
[2. Satellite](./Satellite)
---------------------------

        Red Hat Satellite is a system management solution that enables you to deploy, configure,
        and maintain your systems across physical, virtual, and cloud environments. Satellite 
        provides provisioning, remote management and monitoring of multiple Red Hat Enterprise Linux
        deployments with a single, centralized tool.

        Red Hat Satellite Server synchronizes the content from Red Hat Customer Portal and other 
        sources, and provides functionality including fine-grained life cycle management, user and 
        group role-based access control, integrated subscription management, as well as advanced GUI, 
        CLI, or API access.

        Red Hat Satellite Capsule Server mirrors content from Red Hat Satellite Server to facilitate 
        content federation across various geographical locations. Host systems can pull content and
        configuration from the Capsule Server in their location and not from the central Satellite
        Server. The Capsule Server also provides localized services such as Puppet Master, DHCP, DNS,
        or TFTP. Capsule Servers assist you in scaling Red Hat Satellite as the number of managed 
        systems increases in your environment.
       
       [ACCESS RED HAT SATELLITE](https://access.redhat.com/documentation/en-us/red_hat_satellite/6.7/html/release_notes/pref-red_hat_satellite-release_notes-introduction#red_hat_satellite_and_proxy_server_life_cycle)
        

 ** [Request Satellite License](https://www.redhat.com/en/technologies/management/smart-management)

 * [Whats components comprise Satellite?](https://access.redhat.com/articles/1343683)

        NOTE: Satellite has a lot of features so the request will be started with a conversation with
              your sales person and the technical account team to assist in the archatecture when
              you request a evaluation.

 * [Satellite_PDF](./Satellite/Satellite_PDF)
   * [1. Standard-Operating-Environment-ebook](./Satellite/Satellite_PDF/co-standard-operating-environment-ebook-f16684-201909-en.pdf)
   * [2. Getting-Started-With-Satellite-6](./Satellite/Satellite_PDF/getting-started-with-satellite-6-command-line.pdf)
   * [3. OpenSCAP](./Satellite/Satellite_PDF/Openscap.pdf)
   * [4. Performance_Tuning_for_Red_Hat_Satellite_6.7](./Satellite/Satellite_PDF/performance_tuning_for_red_hat_satellite_6.7.pdf)
   * [5. Red_Hat_Satellite_Power_User_Tips_and_Tricks](./Satellite/Satellite_PDF/Red_Hat_Satellite_Power_User_Tips_and_Tricks_Summit_2018.pdf)
   * [6. Satellite_6_Prereqs](./Satellite/Satellite_PDF/Satellite_6_Prereqs.pdf)
   * [7. Steps_to_Build_an_SOE_How_Red_Hat_Satellite](./Satellite/Satellite_PDF/Steps_to_Build_an_SOE_How_Red_Hat_Satellite.pdf)
   * [8. Summit_Preso_V2](./Satellite/Satellite_PDF/Summit_Preso_V2.pdf)

 * [Satellite_DOC](./Satellite/Satellite_DOC)
   * [1. Satellite_6.x_Contents](./Satellite/Satellite_DOCSatellite_6.x_Contents.doc)
   * [2. Sync_from_one_Satellite_server_to_another_over_HTTP_or_HTTPS](./Satellite/Satellite_DOC/Satellite_content_can_be_synced_from_one_Satellite_server_to_another_over_HTTP_or_HTTPS.txt)

 * [Satellite-Ansible Playbook Examples](./Satellite/Satellite-Ansible_Resources/GITHUB_FOR_SATELLITE.md)
 * [Satellite-Ansible Galaxy Roll Examples](./Satellite/Satellite-Ansible_Resources/ANSIBLE_GALAXY_FOR_SATELLITE.md)

  * [Ansible_Modules-Foreman-Katello](./Satellite/FILES/Ansible_Modules-Foreman-Katello.tar.gz)

        DISCLAMER: Again these are "my scripts" and are not supported in any way (use at own risk) 
                   Do not use on a currently running production system. No implied warrenty or other.

[Requirements to run the script](https://github.com/ShaddGallegos/RHTI/blob/master/Satellite/README.md)
#### Simple script for installing Satellite P.O.C on a single node/vm on RHEL7:
  * [REDHATTOOLSINSTALLER-6.8-10272020.sh](./Satellite/FILES/REDHATTOOLSINSTALLER-6.8-10272020.sh)

#### Simple script checking the health of your Satellite once it is set up on your RHEL7 sys:
  * [sat6_healthCheck.sh Sat6.7 and lower](./Satellite/FILES/Satellite6.7_on_RHEL7_ONLY_healthCheck.sh)

#### RPM for an X enabled server (not required) 
 * [xdialog-2.3.1-13.el7.centos.x86_64.rpm](./Satellite/FILES/xdialog-2.3.1-13.el7.centos.x86_64.rpm)

![REDHATTOOLSINSTALLER](./Satellite/PNG/REDHATTOOLSINSTALLER-6.7.png)
  
[3. Useful Scripts](./Useful_Scripts/)

[4. Integration](./Intergrations/)

 * [Satellite/Ansible Tower](./Intergrations/Satellite-Ansible_Tower) - in Progress
 * [Ansible Tower/ServiceNow](./Intergrations/Ansible_Tower-ServiceNow) - in progress
 
### Red Hat Tiger Team members
#### Trusted Red Hat colleagues that I often use for reference

 * Michael Ford 
   * [Cloud Agnostic and ServiceNow Integration](https://github.com/michaelford85)

 * Orcun Aatakan
   * [Many examples: Windows, VMWare, and Other](https://github.com/oatakan)

 * Jimmy Conner
   * [Ninja Blog](http://ansible.ninja)

 * Will Tome 
   * [Demo_Playbooks](https://github.com/willtome/ansible-demokit) 
   * [Insights](https://www.ansible.com/blog/manage-red-hat-enterprise-linux-like-a-boss-with-red-hat-ansible-content-collection-for-red-hat-insights)
   * [Inventory](https://github.com/willtome/ansible-inventory)
   * [Automated Smart Management](https://github.com/willtome/automated-smart-management)

 * Phil Avery
   * [Avery Tech Guy BLOG](https://averytechguy.wordpress.com/)

 * Gerald Dykeman
   * [Azure, Networking, Workshops and more](https://github.com/gdykeman)

 * Eric Mcleroy
   * [NETWORK](https://github.com/jmcleroy/jpoc)

 * Kevin Holmes
   * [General Ansible](https://github.com/gokev)

 * Greg Sowell
   * [Networking and Zabbix](https://github.com/gregsowell)
     [Network and Telco BLOG](http://gregsowell.com)
     [AD integration post](http://gregsowell.com/?p=6443)
     [CI/CD demo](http://gregsowell.com/?p=6676)
     [SNOW ordering servers via Tower](http://gregsowell.com/?p=6542)
     [All Gregs Ansible blog posts](https://gregsowell.com/?cat=49)


more to come 
