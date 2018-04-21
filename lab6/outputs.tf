# Output the public IP of the instances

output "InstancePublicIP" {
  value = ["${data.oci_core_vnic.InstanceVnic.public_ip_address}"]
}
