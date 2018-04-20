# Adapted from:
# https://github.com/oracle/terraform-provider-oci/blob/master/docs/examples/compute/multi_vnic/multi_vnic.tf

# The usual variable declaration
variable "tenancy_ocid" {}

variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}

# A public key needed for ssh'ing into the VM
# This needs to be adapted to your environment!!! Go to line 95 and change the path there!

# How many secondary VNICs do you want?
variable "SecondaryVnicCount" {
  default = 1
}

# Default Availability Domain per region for provisioning
variable "AD" {
  default = "1"
}

# Default instance shape
variable "InstanceShape" {
  default = "VM.Standard1.1"
}

# OCIDs for Oracle-provided Linux 7.4 images per region
variable "instance_image_ocid" {
  type = "map"

  default = {
    // See https://docs.us-phoenix-1.oraclecloud.com/images/image/0e74ccdd-860a-4e0c-ab1e-897e0d4a5e1c/
    // Oracle-provided image "Oracle-Linux-7.4-2018.02.21-1"
    us-phoenix-1 = "ocid1.image.oc1.phx.aaaaaaaaupbfz5f5hdvejulmalhyb6goieolullgkpumorbvxlwkaowglslq"

    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaajlw3xfie2t5t52uegyhiq2npx7bqyu4uvi2zyu3w3mqayc2bxmaa"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa7d3fsb6272srnftyi4dphdgfjf6gurxqhmv6ileds7ba3m2gltxq"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaaa6h6gj6v4n56mqrbgnosskq63blyv2752g36zerymy63cfkojiiq"
  }
}

# Initialization of the oci provider with environment variables
provider "oci" {
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region           = "${var.region}"
}

# Populate oci availability domains for our tenancy
data "oci_identity_availability_domains" "ADs" {
  compartment_id = "${var.tenancy_ocid}"
}

# Define a VCN in our compartment
resource "oci_core_virtual_network" "ExampleVCN" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "ExampleVCN"
  dns_label      = "examplevcn"
}

# Define a subnet in our VCN
resource "oci_core_subnet" "ExampleSubnet" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}"
  cidr_block          = "10.0.1.0/24"
  display_name        = "ExampleSubnet"
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.ExampleVCN.id}"
  route_table_id      = "${oci_core_virtual_network.ExampleVCN.default_route_table_id}"
  security_list_ids   = ["${oci_core_virtual_network.ExampleVCN.default_security_list_id}"]
  dhcp_options_id     = "${oci_core_virtual_network.ExampleVCN.default_dhcp_options_id}"
  dns_label           = "examplesubnet"
}

# Define a VM instance in our subnet
resource "oci_core_instance" "ExampleInstance" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "ExampleInstance"
  image               = "${var.instance_image_ocid[var.region]}"
  shape               = "${var.InstanceShape}"
  subnet_id           = "${oci_core_subnet.ExampleSubnet.id}"

  # Create the primary VNIC and attach to our subnet
  create_vnic_details {
    subnet_id      = "${oci_core_subnet.ExampleSubnet.id}"
    hostname_label = "exampleinstance"
  }

  metadata {
    ssh_authorized_keys = "${file("~\\.oci\\oci_ssh_key.pub")}"
  }

  timeouts {
    create = "60m"
  }
}

# Create secondary VNICs and attach to our instance and subnet
resource "oci_core_vnic_attachment" "SecondaryVnicAttachment" {
  instance_id  = "${oci_core_instance.ExampleInstance.id}"
  display_name = "SecondaryVnicAttachment_${count.index}"

  create_vnic_details {
    subnet_id              = "${oci_core_subnet.ExampleSubnet.id}"
    display_name           = "SecondaryVnic_${count.index}"
    assign_public_ip       = true
    skip_source_dest_check = true
  }

  count = "${var.SecondaryVnicCount}"
}

# Print out primary IP adresses (public and private) of the VM
output "PrimaryIPAddresses" {
  value = ["${oci_core_instance.ExampleInstance.public_ip}",
    "${oci_core_instance.ExampleInstance.private_ip}",
  ]
}
