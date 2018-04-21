resource "oci_core_volume" "DemoBlock0" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "DemoBlock0"
  size_in_gbs         = "50"
}

resource "oci_core_volume_attachment" "DemoBlock0Attach" {
  attachment_type = "iscsi"
  compartment_id  = "${var.compartment_ocid}"
  instance_id     = "${oci_core_instance.DemoInstance.id}"
  volume_id       = "${oci_core_volume.DemoBlock0.id}"
}
