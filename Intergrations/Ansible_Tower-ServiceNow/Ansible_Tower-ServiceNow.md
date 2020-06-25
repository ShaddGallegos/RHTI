LOGIN 
------------
The first item you will come to is the login screen where you will enter your username (admin) and password (r3dh4t7!) 

License
------------
When you install the system yourself the second screen is the License screen. Save your license to a place on your desktop and browse to find it. Then accept the EULA and select SUBMIT
Welcome To Ansible Tower

The First screen is your Tower home screen. Here you can see at a glance what your system is up to. Notice the menu on the left.
Navigation Menu
The navigation menu lists all the components we will be working with

SETTINGS
------------
Last item on menu on the left

Authentication: 
This is where you will setup your Enterprise auth.

Jobs:
Here we can add ad-hoc modules to be run, change Max sched jobs, check, and timeout intervals.

System:
Here is where you will be able to setup your logging and some other minor settings

User Interface:
Here you can set the motd msg and add your logo to the login screen 

License:
Here you can see the status of your license and update/add a license at any time 

ORGANIZATIONS
------------

If you are using LDAP, Azure AD, O2Auth, or if you are adding users manually, This is where you will create your groups of users organized into Teams or individual users within each org you create. Users can live in multiple Organizations or Teams. 

There are only 3 types of users on a system Normal, Auditor, and Admin. (no worries) 

Only use admin for the few users that have NO RESTRICTIONS in your environment, and you want these people to see or change everything. If you have selected the "Normal User" you can now assign the level of access that they have within the system by selecting the ORGANIZATION → PERMISSIONS → USER and select the level of authority the user will have. You may select multiple options for your users.
• Select "SAVE"

CREDENTIALS
------------

For setting up and working with AWS we need 2 types of credentials 
We need the credential for connection to AWS and we need a credential for working with the nodes 

For AWS we need 
• ACCESS KEY
• SECRETKEY
• PEM KEY

Select CREDENTIALS from the side menu
• Click the add button, which launches the CREATE CREDENTIAL
• In the CREDENTIAL TYPE choose "Amazon Web Services"Now insert your ACCESS KEY and SECRETKEY
• Select SAVE 

Now for the machine credential 
• Click the add button, which launches the CREATE CREDENTIALS.
• In the CREDENTIAL TYPE choose "Machine"

NOTE: The root user for installing in AWS is ec2_user so add that to the "USERNAME" section
• Now open your PEM key you received from AWS and copy and paste it in the "SSH PRIVATE KEY" section.

Select SAVE 

DYNAMIC INVENTORIES
------------

Inventory tends to fluctuate over time, with hosts spinning up and shutting down in response to business demands, the static inventory solutions described in Working with Inventory will not serve your needs. You may need to track hosts from multiple sources: cloud providers, LDAP, Cobbler, and/or enterprise CMDB systems.

Ansible integrates all of these options via a dynamic external inventory system. Ansible supports two ways to connect with external inventory: Inventory Plugins and inventory scripts.

Inventory plugins take advantage of the most recent updates to Ansible’s core code. We recommend plugins over scripts for dynamic inventory. You can write your own plugin to connect to additional dynamic inventory sources.

You can still use inventory scripts if you choose. When we implemented inventory plugins, we ensured backwards compatibility via the script inventory plugin. The examples below illustrate how to use inventory scripts.

If you’d like a GUI for handling dynamic inventory, the Red Hat Ansible Tower inventory database syncs with all your dynamic inventory sources, provides web and REST access to the results, and offers a graphical inventory editor. With a database record of all of your hosts, you can correlate past event history and see which hosts have had failures on their last playbook runs.

We will be working with a couple different Dynamic inventories in this example (AWS and ServiceNow) We will start with the AWS component and address the ServiceNow portion in the ServiceNow section.

AWS Inventory
------------

From the menu select "Inventories" 
• Click the add button, which launches the "Inventory" from the drop down
• Insert the name of the Inventory (EC2) 
• Select SAVE

• Then choose the "SOURCES" button

SOURCE
------------

• Enter the name (I chose EC2 for consistency) 
 ◦ 
• Choose the "SOURCE" "Amazon EC2"

• Choose "CREDENTIAL" (EC2) Choose "REGIONS"(extra) add ‘INSTANCE FILTERS" This will allow you to filter for items you want to see. (tag:Name=<orginazation>*) this example filters all instances that were prefaced by "<orginazation>"

• Choose the boxes "OVERWRITE" and "UPDATE ON LAUNCH"Choose "SAVE"

PROJECTS
------------

A Project is a logical collection of Ansible playbooks, represented in Tower.

You can manage playbooks and playbook directories by either placing them manually under the Project Base Path on your Tower server, or by placing your playbooks into a source code management (SCM) system supported by Tower, including Git, Subversion, Mercurial, and Red Hat Insights. To create a Red Hat Insights project, refer to Setting up an Insights Project.

• Click the  add button, which launches the Create Project dialog.Name the PROJECT (LinkLight - Linux)
• Choose the SCM TYPE (Git) 
• Add your "SCM URL" (https://github.com/ansible/workshops.git)
• Choose the boxes "CLEAN" and "UPDATE REVISION ON LAUNCH"
• Choose SAVE

Repeat the process for creating a project and create a "SkyLight – Windows" project using https://github.com/mgmt-sa-tiger-team/skylight.git as the SCM URL.

CREDENTIAL TYPES
------------ 
https://docs.ansible.com/ansible-tower/latest/html/userguide/credential_types.html#getting-started-with-credential-types
As a Tower administrator with superuser access, you can define a custom credential type in a standard format using a YAML/JSON-like definition, allowing the assignment of new credential types to jobs and inventory updates. This allows you to define a custom credential type that works in ways similar to existing credential types. For example, you could create a custom credential type that injects an API token for a third-party web service into an environment variable, which your playbook or custom inventory script could consume.
Custom credentials support the following ways of injecting their authentication information:
• Environment variables
• Ansible extra variables
• File-based templating (i.e., generating .ini or .conf files that contain credential values)
You can attach one SSH and multiple cloud credentials to a Job Template. Each cloud credential must be of a different type. In other words, only one AWS credential, one GCE credential, etc., are allowed. In Ansible Tower 3.2 and later, vault credentials and machine credentials are separate entities.
In the provided example we will need to create 2 of our own credentials. The first for deploying Windows in SkyLight and the second for ServiceNow 


From the menu on the left select "Credential Types"
• Click the add button, which launches the NEW CREDENTIAL TYPE
• Name the CREDENTIAL TYPE
• In the field marked INPUT CONFIGURATION cut and paste 
fields:
 - id: tower_license
  type: string
  label: Tower License
required:
 - tower_license
• In the field marked INJECTOR CONFIGURATION cut and paste
extra_vars:
 tower_license: '{{ tower_license }}'

Example below:

• Choose "SAVE"

Create A Credential For Skylight – Windows 
------------
• Open the 50 node license in a text editor Above the "company_name" insert ""eula_accepted": true," make it look like the graphic below
• Highlight and copy the text.
• Select "Credentials" from the menu 
• Click the add button, which launches the NEW CREDENTIAL
• Name the Credential (Skylight – Windows)
• Select the Credential Type that we just created (Skylight - Windows)
• 

• Paste the license into the TOWER LICENSE fieldChoose "SAVE"

What this has done is, it has created an example of a way you can push a license to a system as it is built .

TEMPLATES
------------

A job template is a definition and set of parameters for running an Ansible job. Job templates are useful to execute the same job many times. Job templates also encourage the reuse of Ansible playbook content and collaboration between teams. While the REST API allows for the execution of jobs directly, Tower requires that you first create a job template.
The () menu opens a list of the job templates that are currently available. The default view is collapsed (Compact), showing the template name, template type, and the statuses of the jobs that ran using that template, but you can click Expanded to view more information. This list is sorted alphabetically by name, but you can sort by other criteria, or search by various fields and attributes of a template.

Now for each of the environments that are built there needs to be a way to build them when needed and to tear them down when you are done, so the following templates must be created. 

1. LinkLight – Linux – Provision
2. SkyLight – Windows – Provision
3. LinkLight – Linux – Teardown
4. SkyLight - Windows – Teardown

• From the menu on the left select "Templates"
• Click the add button, Chose "Job Template" 
• Follow the tables below to complete each template.

NOTE: LinkLight and SkyLight playbook examples are designed to install groups of 4 servers for Linux and 7 system for Windows for each student. Be sure to check the box Prompt on launch so you may change the “EXTRA VARIABLES” you need for creating each node set. By default the vars that are usually changed are “ec2_name_prefix: <orginazation>-LinkLight-Test“ and “student_total: 1“ you can set these up as SURVEY questions if you like. Try running with the default first and then look in the inventory to see what has been created. You will need to use the same <orginazation>-LinkLight-Test in your tear down template

PROVISION 
FIELD
ENTRY
NAME:
LinkLight – Linux – Provision
DESCRIPTION:
Provision Linux Environments
JOB TYPE:
Run
INVENTORY:
Demo Inventory
PROJECT:
LinkLight
PLAYBOOK:
provisioner/provision_lab.yml
CREDENTIAL(s):
EC2, EC2_Machine
ENABLE PRIVILEGE ESCALATION:
X
ENABLE CONCURRENT JOBS:
X
USE FACT CACHE:
X

EXTRA VARIABLES:

admin_password: r3dh4t7!
create_login_page: true
dns_type: aws
ec2_az: us-east-1a
ec2_name_prefix: spg-linux-test
ec2_region: us-east-1
f5workshop: false
ibm_community_grid: false
student_total: 1
towerinstall: true
workshop_dns_zone: rhdemo.io
workshop_type: rhel
xrdp: true

FIELD
ENTRY
NAME:
SkyLight – Windows – Provision
DESCRIPTION:
Provision Windows Environments
JOB TYPE:
Run
INVENTORY:
Demo Inventory
PROJECT:
SkyLight
PLAYBOOK:
provision.yml
CREDENTIAL(s):
EC2, EC2_Machine, SkyLight
ENABLE PRIVILEGE ESCALATION:

ENABLE CONCURRENT JOBS:
X
USE FACT CACHE:
X

EXTRA VARIABLES:
---
dns_domain_name: ansibleworkshop.com
domain_admin_password: MyP@ssw0rd21
ec2_region: us-east-1
name_prefix: <orginazation>Skylight-TestHS
root_user: ec2-user
user_count: 1
user_prefix: student
users_password: AnsibleWorkshop21#

 
TEARDOWN
FIELD
ENTRY
NAME:
LinkLight – Linux – Teardown
DESCRIPTION:
Destroy Linux Environment
JOB TYPE:
RUN
INVENTORY:
Demo Inventory
PROJECT:
LinkLight
PLAYBOOK:
provisioner/teardown.yml
CREDENTIAL(s):
EC2, EC2_Machine 
ENABLE PRIVILEGE ESCALATION:
X
ENABLE CONCURRENT JOBS:
X
USE FACT CACHE:
X
EXTRA VARIABLES:
---
ec2_region: us-east-1 # region where the nodes will live
ec2_az: us-east-1a # availability zone
ec2_name_prefix: <orginazation>-LinkLight  # name prefix for all the VMs
admin_password: r3dh4t7!
localsecurity: false # skips firewalld installation and SE Linux when false
student_total: 1 # automatically creates students if you don’t define a user.yml
create_login_page: true
towerinstall: true
f5workshop: false
xrdp: true
workshop_type: rhel

FIELD
ENTRY
NAME:
SkyLight - Windows – Teardown
DESCRIPTION:
Destroy Windows Environment
JOB TYPE:
RUN
INVENTORY:
SkyLight
PROJECT:
SkyLight
PLAYBOOK:
teardown.yml
CREDENTIAL(s):
EC2, EC2_Machine, SkyLight
ENABLE PRIVILEGE ESCALATION:

ENABLE CONCURRENT JOBS:
X
USE FACT CACHE:
X
EXTRA VARIABLES:
---
dns_domain_name: ansibleworkshop.com
domain_admin_password: MyP@ssw0rd21
ec2_region: us-east-1
name_prefix: <orginazation>Skylight-Test
root_user: ec2-user
user_count: 1
user_prefix: student
users_password: AnsibleWorkshop21#

SERVICENOW
------------

Obtain a developer ServiceNow account 
https://developer.servicenow.com/app.do#!/home

ServiceNow Dynamic Inventory 
------------
We are going to set up this dynamic inventory for ServiceNow but the following method can be used with any CMDB.
The custom inventory script has already been made and can be available here.
https://raw.githubusercontent.com/ServiceNowITOM/ansible-sn-inventory/master/now.py

From the main menu select "Inventory Scripts" 
• Click the add button, which launches the "NEW CUSTOM INVENTORY"
• Name the script "ServiceNow"
• Copy and paste the raw now.py into the "CUSTOM SCRIPT" field.
• Choose "SAVE"
• Now pass a credential to connect to ServiceNow the following 3 environment variables are needed.

SN_INSTANCE
SN_USERNAME
SN_PASSWORD

Now we will create a custom credential type so the credentials will be encrypted.
From the main menu select "Credential Types"
• Click the add button, which launches the "NEW CREDENTIAL TYPE"
• Name the credential type "ServiceNow"

• Now enter the following into the "INPUT CONFIGURATION"

 fields:
 - id: username
  type: string
  label: Username
 - id: password
  type: string
  label: Password
  secret: true
 - id: instance
  type: string
  label: Instance

NOTE: if you want the password to be encrypted and not stored in plain text make sure you use the " - secret: true"
• Now enter the following into the "Injector Configuration" we will add in the relevant ServiceNow environment tags.

env:
 SN_INSTANCE: '{{instance}}'
 SN_PASSWORD: '{{password}}'
 SN_USERNAME: '{{username}}'
• 
• Choose "SAVE"

Create a credential for ServiceNow
------------
Navigate to credentials 
From the main menu select "Credentials"
• Click the add button, which launches the "NEW CREDENTIAL"
• Name the credential "ServiceNow"
• Select a "CREDENTIAL TYPE" search for "ServiceNow" and select "ServiceNow"
• Enter the "TYPE DETAILS" 

USERNAME: admin
PASSWORD: r3dh4t7!SN
SERVICENOW INSTANCE: <name>.service-now.com/
• Choose "SAVE”
Create The Inventory 
From the main menu select "INVENTORIES"
• Click the add button, which launches the "NEW INVENTORY"
• Name the inventory "ServiceNow"
• Choose "SAVE"
• Now the buttons at the top of the "INVENTORIES / ServiceNow" screen should be selectable 
• Choose "SOURCES"Click the add button, which launches the "CREATE SOURCE"
• Name the source "ServiceNow"
• Use the drop down "SOURCE" and select "Custom Script"Under "CREDENTIAL" choose "ServiceNow"
• Under "CUSTOM INVENTORY SCRIPT" choose "ServiceNow"
• Choose the checkboxes "OVERWRITE" and "UPDATE ON LAUNCH"

Choose "SAVE"
Now you will be able to use ServiceNow as a CMDB to control nodes and actions in Ansible Tower.

CREATING AN APPLICATION IN ANSIBLE TOWER
USERNAME: admin
PASSWORD: r3dh4t7!SN
SERVICENOW INSTANCE: <name>.service-now.com

In Ansible Tower, navigate to Applications on the left side of the screen.
• Click the green plus button, which will present you with a New Application dialog screen. Fill in the following fields:
• Click the add button, which launches the "CREATE APPLICATION"
• Name the source "ServiceNow"
• Use the magnifying glass icon to choose the "ORGANIZATION" that will own the application 
• Select the "AUTHORIZATION GRANT TYPE" and when you select the text box a menu will drop down choose "Authorization code" 
Select the "Redirect URIS" https://<name>.service-now.com/oauth_redirect.do
• Then to the right under the "CLIENT TYPE" choose Confidential
• Choose "SAVE"
NOTE: A window will pop up, presenting you with the Client ID and Client Secret needed for ServiceNow to make API calls into Tower. This will only be presented ONCE, so capture these values for later use.

Next, navigate to Settings->System on the left side of the screen. You’ll want to toggle the Allow External Users to Create Oauth2 Tokens option to on. Click the green Save button to commit the change.
• 
Moving over to ServiceNow, Navigate to System Definitions->Certificates. This will take you to a screen of all the certificates ServiceNow uses. Click on the blue New button, and fill in these details:Name: Descriptive name of the certificate
Format: PEM
Type: Trust Store Cert
PEM Certificate: The certificate to authenticate against Ansible Tower with. You can use the built-in certificate on your Tower server, located at /etc/tower/tower.cert. Copy the contents of this file into the field in ServiceNow.
• Click the Submit button at the bottom.

In ServiceNow, Navigate to System OAuth->Application Registry. This will take you to a screen of all the Applications ServiceNow communicates with. 
• Click on the blue New button, and you will be asked What kind of Oauth application you want to set up. 
• Select Connect to a third party Oauth Provider.

• On the new application screen, fill in these details:
Name: Ansible Tower
Client ID: XIAOeAgXiz36ZrUCmntbDGXtHnZLBp4jH9vZK392
Client Secret: 4jCM61emnhO1Wyo6qlK4JDaS7DwrfyQZ9b3XcrjvXPcaKa60iXDicDy0qg9xAywPFJXRTcBOyFs5J1tQptSCkqRu15OYmrvcExDQmVXuTMzEL4y7j5ty3b7gIBRlx8e9
Default Grant Type: Authorization Code
Authorization URL: https://<student>.<orginazation>.rhdemo.io/api/o/authorize/
Token URL: https://<student>.<orginazation>.rhdemo.io/api/o/token/
Redirect URL: https://https://<name>.service-now.com//oauth_redirect.do

• Click the Submit button at the bottom.

You should be taken out to the list of all Application Registries. 
• Click back into the Application you just created. At the bottom, there should be two tabs: 
• Click on the tab Oauth Entity Scopes. 
• Under here, there is a section called Insert a new row…. 
• Double click here, and fill in the field to say Writing Scope. 
• Click on the green check mark to confirm this change. 
• Then, right-click inside the grey area at the top where it says Application Registries and click Save in the menu that pops up.

The writing scope should now be Clickable. 
• Click on it, and in the dialog window that you are taken to, type write in the Oauth scope box. 
• Click the Update button at the bottom.

Back in the Application Settings page, scroll back to the bottom.
• Click the Oauth Entity Profiles tab. 

There should be an entity profile populated - click into it.
You will be taken to the Oauth Entity Profile Window. At the bottom, 
• Type “Writing Scope” into the Oauth Entity Scope field. 
• Click the green check mark and update.Navigate to System Web Services→ Outbound → REST Messages. Click the blue New button. In the resulting dialog window.
• Fill in the following fields:
Name: Ansible Tower
Endpoint: The url endpoint of the Ansible Tower action you wish to do. This can be taken from the browsable API at https://<student>.<orginazation>.rhdemo.io/api/v2/job_templates/ search for the template SkyLight – Windows and you should find 

• Above that you should find the launch api " "launch": "/api/v2/job_templates/12/launch/", Fill in the endpoint https://<student>.<orginazation>.rhdemo.io/api/v2/job_templates/12/launch/
Authentication Type: Oauth 2.0

Oauth Profile: Select the Oauth profile you created
• 
• Right-click inside the grey area at the top; click Save.Click the Get Oauth Token button on the REST Message screen. 
This will generate a pop-up window asking to authorize ServiceNow against your Tower instance/cluster. 
• Click Authorize. ServiceNow will now have an Oauth2 token to authenticate against your Ansible Tower server.

Under the HTTP Methods section at the bottom, 
• Click the blue New button. At the new dialog window that appears, 
• Fill in the following fields:
HTTP Method type POST
Name: Descriptive HTTP Method Name
Endpoint: The url endpoint of the Ansible Tower action you wish to do. This can be taken from the browsable API at https://<tower_url>/api

HTTP Headers (under the HTTP Request tab picture below)
The only HTTP Header that should be required is Content-Type: application/json
You can kick off a RESTful call to Ansible Tower using these parameters with the Test link.

• NOTE: Before you click test open your Ansible Tower jobs window so you can watch it kick off.Click the Test link will take you to a results screen, which should indicate that the Restful call was sent successfully to Ansible Tower. In this example, ServiceNow kicks off an Ansible Tower job Template, and the response includes the Job ID in Ansible Tower: 276.

You can confirm that this Job Template was in fact started by going back to Ansible Tower and clicking the Jobs section on the left side of the screen; a Job with the same ID should be in the list (and, depending on the playbook size, may still be in process):

At this point you can see that we can make calls from ServiceNow to Ansible Tower.

EXTRA – CREATING A CATALOG ITEM 
Now that you are able to make outbound RESTful calls from ServiceNow to Ansible Tower, it’s time to create a catalog item for users to select in ServiceNow in a production self-service fashion. While in the HTTP Method options.
• Click the Preview Script Usage link:
• Copy the resulting script the appears, and paste it into a text editor to reference later.In ServiceNow, navigate to Workflow->Workflow Editor. This will open a new tab with a list of all existing ServiceNow workflows. Click on the blue New Workflow button:

In the New Workflow dialog box that appears, fill in the following options:
• Name: A descriptive name of the workflow
• Table: Requested Item [sc_req_item
]
Everything else can be left alone. 
• Click the Submit button. 

The resulting Workflow Editor will have only a Begin and End box. 
• Click on the line (it will turn blue to indicate it has been selected), then press delete to get rid of it.

On the right side of the Workflow Editor Screen, select the Core tab and, under Core Activities → Utilities, drag the Run Script option into the Workflow Editor. In the new dialog box that appears. 
• Type in a descriptive name, and paste in the script you captured from before. Click Submit to save the Script.
• Draw a connection from Begin, to the newly created Run Script Box, and another from the Run Script box to End. Afterward, 
• click on the three horizontal lines to the left of the Workflow name, and select the Publish option. 
You are now ready to associate this workflow with a catalog item.

Navigate to Service Catalog → Catalog Definitions→Maintain Items. 
• Click the blue New button on the resulting item list. In the resulting dialog box, fill in the following fields:
Name: Descriptive name of the Catalog Item
Catalog: The catalog that this item should be a part of
Category: Required if you wish users to be able to search for this item
In the Process Engine tab, populate the Workflow field with the Workflow you just created. 
• Click the Submit Button. You’ve not created a new catalog item!

Lastly, to run this catalog item, navigate to Self-Service → Homepage and search for the catalog item you just created. Once found, 
• Click the order now button. You can see the results page pop up in ServiceNow, and you can confirm that the Job is being run in Ansible Tower.


