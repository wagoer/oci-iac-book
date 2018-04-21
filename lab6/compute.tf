resource "oci_core_instance" "DemoInstance" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "Demo-Instance"
  image               = "${var.instance_image_ocid[var.region]}"
  shape               = "${var.InstanceShape}"
  subnet_id           = "${oci_core_subnet.SN-DemoSubnetAD1.id}"

  metadata {
    ssh_authorized_keys = "${file("~\\.oci\\oci_ssh_key.pub")}"
    user_data           = "${base64encode(file(var.InstanceBootStrap))}"
  }
}
