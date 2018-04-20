# Python function to create a VCN

import oci

def create_vcn(virtual_network, compartment_id, vcn_name, dns_label, cidr_block):
    result = virtual_network.create_vcn(
        oci.core.models.CreateVcnDetails(
            cidr_block=cidr_block,
            display_name=vcn_name,
            compartment_id=compartment_id,
            dns_label=dns_label
        )
    )
    get_vcn_response = oci.wait_until(
        virtual_network,
        virtual_network.get_vcn(result.data.id),
        'lifecycle_state',
        'AVAILABLE'
    )
    print('Created VCN: {}'.format(get_vcn_response.data.id))

    return get_vcn_response.data

config = oci.config.from_file()
virtual_network_client = oci.core.VirtualNetworkClient(config)
compartment_id = config["tenancy"]

try:
    vcn = create_vcn(virtual_network_client, compartment_id, "pythonvcn1", "pythonvcn1", "172.0.0.0/16")
    print(vcn)

finally:
    exit()
