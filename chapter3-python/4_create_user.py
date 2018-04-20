# Creating an OCI user in Python demo script
import oci
config = oci.config.from_file()
identity_client = oci.identity.IdentityClient(config)
compartment_id = config["tenancy"]

# prepare OCI request by assigning the desired user parameters
from oci.identity.models import CreateUserDetails
request = CreateUserDetails()
request.compartment_id = compartment_id
request.name = "python-user"
request.description = "Created with the Python SDK"
user = identity_client.create_user(request)
print(user.data.id)
