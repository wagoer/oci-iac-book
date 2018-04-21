variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}

# OCID for POCCOMP1 compartment. Adapt to your environment!
variable "compartment_ocid" {
  default = "ocid1.compartment.oc1..aaaaaaaal7yma7iwruue2altr2cmgns4svg57relimneoixu7t5hefneolxa"
}

variable "InstanceShape" {
  default = "VM.Standard1.2"
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

variable "VPC-CIDR" {
  default = "10.0.0.0/16"
}

variable "DemoSubnetAD1CIDR" {
  default = "10.0.1.0/24"
}

variable "InstanceBootStrap" {
  default = "./userdata/instance"
}

variable "AD" {
  default = "1"
}

variable "2TB" {
  default = "2097152"
}

variable "50GB" {
  default = "51200"
}
