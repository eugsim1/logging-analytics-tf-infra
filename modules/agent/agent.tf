## https://docs.oracle.com/en-us/iaas/management-agents/doc/perform-prerequisites-deploying-management-agents.html#GUID-EFD288F4-55C4-4DEF-900D-0DEAA24360A2
###


locals {
  begin_dyn_rule_AGENT = "Any {resource.type='management-agents',resource.compartment.id = '"
  end_dyn_rule_AGENT   = "'}"
}

### Step1 create Agent Group
resource "oci_identity_compartment" "AGENT_compartment" {
  #Required
  compartment_id = var.agent.oci_identity_compartment_AGENT_compartment_compartment_id ##"ocid1.compartment.oc1..aaaaaaaakjdnf7ik2kejcaj73uwx6tsochnlq5olj3vebgbwcf67bjnab3ya"
  description    = var.agent.oci_identity_compartment_AGENT_compartment_description    #"AGENT Analytics compartment"
  name           = var.agent.oci_identity_compartment_AGENT_compartment_name           #"AGENT_LoggingAnalytics" 
  enable_delete  = true

  #Optional
  defined_tags = { "Oracle-Tags.ResourceAllocation" = "Logging-Analytics" }
  freeform_tags = {
    "Project"     = "log_analytics"
    "Role"        = "log_analytics for HOL "
    "Comment"     = "log_analytics setup for HOL "
    "Version"     = "0.0.0.0"
    "Responsible" = "Eugene Simos"
  }
  lifecycle {
    ignore_changes = [
      defined_tags,
      freeform_tags,
    ]
  }
}

##Step 2: Create a user group
resource "oci_identity_group" "AGENT_ADMINS_identity_group" {
  depends_on     = [oci_identity_compartment.AGENT_compartment]
  name           = "AGENT_ADMINS"
  description    = "log analytics group"
  compartment_id = var.oci_provider.tenancy_id

  #Optional
  defined_tags = { "Oracle-Tags.ResourceAllocation" = "Logging-Analytics" }
  freeform_tags = {
    "Project"     = "log_analytics"
    "Role"        = "log_analytics for HOL "
    "Comment"     = "log_analytics setup for HOL "
    "Version"     = "0.0.0.0"
    "Responsible" = "Eugene Simos"
  }
  lifecycle {
    ignore_changes = [
      defined_tags,
      freeform_tags,
    ]
  }

}

### create policies
###					 
resource "oci_identity_policy" "AGENT_ADMINS_policy" {
  depends_on     = [oci_identity_group.AGENT_ADMINS_identity_group]
  name           = var.agent.oci_identity_policy_AGENT_ADMINS_policy_name #"AGENT_ADMINS_policy"
  description    = var.agent.oci_identity_policy_AGENT_ADMINS_description #"AGENT_ADMINS policy"
  compartment_id = var.oci_provider.tenancy_id
  #Optional
  defined_tags = { "Oracle-Tags.ResourceAllocation" = "Logging-Analytics" }
  freeform_tags = {
    "Project"     = "log_analytics"
    "Role"        = "log_analytics for HOL "
    "Comment"     = "log_analytics setup for HOL "
    "Version"     = "0.0.0.0"
    "Responsible" = "Eugene Simos"
  }
  lifecycle {
    ignore_changes = [
      defined_tags,
      freeform_tags,
    ]
  }

  statements = [
    "ALLOW GROUP AGENT_ADMINS TO MANAGE management-agents IN  TENANCY",
    "ALLOW GROUP AGENT_ADMINS TO MANAGE management-agent-install-keys IN  TENANCY",
    "ALLOW GROUP AGENT_ADMINS TO READ METRICS IN TENANCY",
    "ALLOW GROUP AGENT_ADMINS TO READ USERS IN TENANCY",
  ]
}



resource "oci_identity_dynamic_group" "AGENT_dynamic_group" {
  depends_on = [oci_identity_compartment.AGENT_compartment]
  #Required
  compartment_id = var.oci_provider.tenancy_id
  description    = var.agent.oci_identity_dynamic_group_AGENT_dynamic_group_description                                                  #"dynamic group for loggin analytics"                                                                                  #var.dynamic_group_description
  matching_rule  = format("%s%s%s", local.begin_dyn_rule_AGENT, oci_identity_compartment.AGENT_compartment.id, local.end_dyn_rule_AGENT) #var.dynamic_group_matching_rule
  name           = var.agent.oci_identity_dynamic_group_AGENT_dynamic_name                                                               #"ManagementAgentAdmins"                                                                                               #var.dynamic_group_name

  #Optional
  defined_tags = { "Oracle-Tags.ResourceAllocation" = "Logging-Analytics" }
  freeform_tags = {
    "Project"     = "log_analytics"
    "Role"        = "log_analytics for HOL "
    "Comment"     = "log_analytics setup for HOL "
    "Version"     = "0.0.0.0"
    "Responsible" = "Eugene Simos"
  }
  lifecycle {
    ignore_changes = [
      defined_tags,
      freeform_tags,
    ]
  }
}

resource "oci_identity_policy" "dyn_loggingAnalytics_policy" {
  depends_on     = [oci_identity_compartment.AGENT_compartment, oci_identity_dynamic_group.AGENT_dynamic_group]
  name           = var.agent.oci_identity_policy_dyn_loggingAnalytics_policy_name        ##"AGENT_dynamic_group_policy"
  description    = var.agent.oci_identity_policy_dyn_loggingAnalytics_policy_description ##"AGENT_dynamic_group  policy"
  compartment_id = var.oci_provider.tenancy_id                                           ##oci_identity_compartment.AGENT_compartment.id
  #Optional
  defined_tags = { "Oracle-Tags.ResourceAllocation" = "Logging-Analytics" }
  freeform_tags = {
    "Project"     = "log_analytics"
    "Role"        = "log_analytics for HOL "
    "Comment"     = "log_analytics setup for HOL "
    "Version"     = "0.0.0.0"
    "Responsible" = "Eugene Simos"
  }
  lifecycle {
    ignore_changes = [
      defined_tags,
      freeform_tags,
    ]
  }
  ### doesnt work "ALLOW DYNAMIC-GROUP ManagementAgentAdmins TO USE tag-namespaces in compartment Workshops:AGENT_LoggingAnalytics"
  statements = [
    "allow dynamic-group ManagementAgentAdmins to MANAGE management-agents IN tenancy",
    "allow dynamic-group ManagementAgentAdmins to USE METRICS IN tenancy",
    "allow dynamic-group ManagementAgentAdmins to {LOG_ANALYTICS_LOG_GROUP_UPLOAD_LOGS} in tenancy",
    "allow dynamic-group ManagementAgentAdmins to USE loganalytics-collection-warning in tenancy",
    "ALLOW DYNAMIC-GROUP ManagementAgentAdmins TO USE tag-namespaces in tenancy"
  ]
  #    "ALLOW DYNAMIC-GROUP ManagementAgentAdmins TO MANAGE management-agents IN COMPARTMENT  Workshops:AGENT_LoggingAnalytics",
  #    "ALLOW DYNAMIC-GROUP ManagementAgentAdmins TO USE METRICS IN COMPARTMENT Workshops:AGENT_LoggingAnalytics",

}



resource "oci_management_agent_management_agent_install_key" "AGENT_management_agent_install_key" {
  depends_on     = [oci_identity_compartment.AGENT_compartment]
  compartment_id = oci_identity_compartment.AGENT_compartment.id

  #Optional
  allowed_key_install_count = var.agent.oci_management_agent_management_agent_install_key_AGENT_management_agent_install_key_allowed_key_install_count ##"200"
  display_name              = var.agent.oci_management_agent_management_agent_install_key_AGENT_management_display_name                                ##"AGENT_Linux"
  time_expires              = var.agent.oci_management_agent_management_agent_install_key_AGENT_management_time_expires                                ##"2021-06-06T23:59:59.398Z"
}


data "oci_management_agent_management_agent_install_key" "AGENT__management_agent_install_key" {
  #Required
  management_agent_install_key_id = oci_management_agent_management_agent_install_key.AGENT_management_agent_install_key.id
}


resource "local_file" "AGENT_key" {
  depends_on = [data.oci_management_agent_management_agent_install_key.AGENT__management_agent_install_key]

  file_permission = "0700"
  filename        = "config/agent.txt"
  content         = <<EOT
### jdk install
sudo su<<EOA
cd /tmp
wget -c --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn-pub/java/jdk/8u281-b09/89d678f2be164786b292527658ca1605/jdk-8u281-linux-x64.tar.gz
mkdir -p /usr/lib/jvm
cd /usr/lib/jvm
tar -xvzf /tmp/jdk-8u281-linux-x64.tar.gz
update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.8.0_281/bin/java" 0
update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/jdk1.8.0_281/bin/javac" 0
update-alternatives --set java /usr/lib/jvm/jdk1.8.0_281/bin/java
update-alternatives --set javac /usr/lib/jvm/jdk1.8.0_281/bin/javac
update-alternatives --list java
update-alternatives --list javac
java -version
wget https://objectstorage.us-ashburn-1.oraclecloud.com/n/idtskf8cjzhp/b/installer/o/Linux-x86_64/latest/oracle.mgmt_agent.rpm
### install
sudo rpm -Uvh oracle.mgmt_agent.rpm  
EOA
cd /home/opc
cat<<EOF>/home/opc/input.rsp  
managementAgentInstallKey = ${data.oci_management_agent_management_agent_install_key.AGENT__management_agent_install_key.key}
FreeFormTags = [{"Responsible":"Eugene Simos"}, {"Project":"log_analytics"}]
DefinedTags = [{"Oracle-Tags":{"ResourceAllocation":"Logging-Analytics"}}]
CredentialWalletPassword = WElcome142312#
Service.plugin.logan.download=true
Service.plugin.dbaas.download=true
EOF
chmod -R ugo+rx /home/opc
sudo /opt/oracle/mgmt_agent/agent_inst/bin/setup.sh opts=/home/opc/input.rsp
EOT
}