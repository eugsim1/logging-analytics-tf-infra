data "oci_objectstorage_namespace" "log_namespace" {

    #Optional
    compartment_id = var.logging.compartment_id
}