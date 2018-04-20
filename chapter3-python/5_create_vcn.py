# Creating a VCN in Python demo script
import oci
config = oci.config.from_file()
identity_client = oci.identity.IdentityClient(config)
tenancy_id = config["tenancy"]
compartment = identity_client.list_compartments(tenancy_id)
print(compartment.data)

# change the assignment below to match your POCCOMP1 OCID
compartment_id = "ocid1.compartment.oc1..aaaaaaaal7yma7iwruue2altr2cmgns4svg57relimneoixu7t5hefneolxa"
virtual_network_client = oci.core.virtual_network_client.VirtualNetworkClient(config)

# prepare OCI request by assigning the desired VCN parameters
from oci.core.models import CreateVcnDetails
request = CreateVcnDetails()
request.compartment_id = compartment_id
request.display_name = "pythonvcn"
request.dns_label = "pythonvcn"
request.cidr_block = "172.0.0.0/16"

vcn = virtual_network_client.create_vcn(request)
