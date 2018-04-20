variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}

provider "oci" {
  tenancy_ocid = "${var.tenancy_ocid}"
  user_ocid = "${var.user_ocid}"
  fingerprint = "${var.fingerprint}"
  private_key_path = "${var.private_key_path}"
  region = "${var.region}"
}

resource "oci_identity_user" "user1" {
  name = "TFExampleUser"
  description = "A user managed with Terraform"
}

resource "oci_identity_ui_password" "tf_password" {
  user_id = "${oci_identity_user.user1.id}"
}

output "UserUIPassword" {
  sensitive = false
  value = ["${oci_identity_ui_password.tf_password.password}"]
}
