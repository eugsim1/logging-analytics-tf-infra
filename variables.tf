#### general variables 

# Identity and access parameters
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "compartment_ocid" { default = "" }

variable "ad" { default = "" }
variable "ssh_public_key" {}
variable "bastion_shape" {}
variable "use_compute" { default = "" }

variable "instance_count" {}
variable "display_name" {}
variable "need_provisioning" {}
variable "instance_ocpus" { default = "" }
variable "instance_memory_in_gbs" { default = "" }
variable "ip_adress_backend" { default = "" }
variable "bastion_user" { default = "" }
variable "bastion_ssh_private_key" { default = "" }
variable "bastion_hostname_label" { default = "" }
variable "bastion_timezone" { default = "" }
variable "bastion_upgrade" {}
variable "use_bastion" {}


variable "is_dbcs_public" { default = "" }

variable "managed_agent_id" { default = "" } 