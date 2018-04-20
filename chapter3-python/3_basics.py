import oci
config = oci.config.from_file()
config
identity = oci.identity.IdentityClient(config)
compartment_id = config["tenancy"]
identity.base_client.endpoint
regions=identity.list_regions()
regions.data
compartment_id = config["tenancy"]
compartment_id
userlist = identity.list_users(compartment_id)
userlist.data
