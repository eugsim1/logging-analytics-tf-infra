### bastion
bastion_hostname_label = "bastionanalytics"
bastion_timezone       = "Europe/Helsinki"
bastion_upgrade        = "false"
use_bastion            = "true"

use_compute    = false
ssh_public_key = "wls-wdt-testkey-pub.txt"
bastion_shape  = "VM.Standard.E3.Flex"

display_name            = "webserver"
need_provisioning       = false
instance_shape          = "VM.Standard.E3.Flex"
instance_ocpus          = "1"
instance_memory_in_gbs  = "4"
bastion_user            = "opc"
bastion_ssh_private_key = "wls-wdt-testkey-priv.txt"
instance_count          = 1