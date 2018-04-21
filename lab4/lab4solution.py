# coding: utf-8
# Copyright (c) 2016, 2018, Oracle and/or its affiliates. All rights reserved.

# This script provides a basic example of how to launch a DB system using the Python SDK. This script will:
#
#   * Create a VCN and subnet for the DB system and its related resources
#   * Launch a DB system containing a single DB home and database. See:
#     https://docs.us-phoenix-1.oraclecloud.com/Content/Database/Concepts/overview.htm and
#     https://docs.us-phoenix-1.oraclecloud.com/Content/Database/Tasks/launchingDB.htm
#     for more information
#   * Demonstrate listing and retrieving information on individual DB systems, DB homes and databases
#   * Demonstrate taking action on nodes
#
# Resources created by the script will be removed when the script is done.
#

import oci
import os.path
import sys

ADMIN_PASSWORD = "ADummyPassw0rd_#1"
DB_VERSION = '12.1.0.2'
DB_SYSTEM_CPU_CORE_COUNT = 2
DB_SYSTEM_DB_EDITION = 'ENTERPRISE_EDITION'
DB_SYSTEM_SHAPE = 'VM.Standard1.2'
	

# Change the below variable assignments to fit your specific environment

compartment_id = 'ocid1.compartment.oc1..aaaaaaaaoadg47pc2djpkgk3yckfnmlehna4plyf2k4ofr7lhshim7alq5oq'
availability_domain = 'GDyP:EU-FRANKFURT-1-AD-1'
cidr_block = '10.0.0.0/16'
ssh_public_key_path = 'C:\\Users\\wagoer\\Oracle Documents - Accounts\\Oracle Documents\\Initiatives\\OCI\\Lab4\\POCDB1.pub'


def create_vcn(virtual_network, compartment_id, cidr_block):
    vcn_name = 'POCVCN2'
    result = virtual_network.create_vcn(
        oci.core.models.CreateVcnDetails(
            cidr_block=cidr_block,
            display_name=vcn_name,
            compartment_id=compartment_id,
            dns_label='pocvcn2'
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


def delete_vcn(virtual_network, vcn):
    virtual_network.delete_vcn(vcn.id)
    oci.wait_until(
        virtual_network,
        virtual_network.get_vcn(vcn.id),
        'lifecycle_state',
        'TERMINATED',
        succeed_on_not_found=True
    )
    print('Deleted VCN: {}'.format(vcn.id))


def create_subnet(virtual_network, vcn, availability_domain):
    subnet_name = 'POCSN2'
    result = virtual_network.create_subnet(
        oci.core.models.CreateSubnetDetails(
            compartment_id=vcn.compartment_id,
            availability_domain=availability_domain,
            display_name=subnet_name,
            vcn_id=vcn.id,
            cidr_block=vcn.cidr_block,
            dns_label='pocsn2'
        )
    )
    get_subnet_response = oci.wait_until(
        virtual_network,
        virtual_network.get_subnet(result.data.id),
        'lifecycle_state',
        'AVAILABLE'
    )
    print('Created Subnet: {}'.format(get_subnet_response.data.id))

    return get_subnet_response.data


def delete_subnet(virtual_network, subnet):
    virtual_network.delete_subnet(subnet.id)
    oci.wait_until(
        virtual_network,
        virtual_network.get_subnet(subnet.id),
        'lifecycle_state',
        'TERMINATED',
        succeed_on_not_found=True
    )
    print('Deleted Subnet: {}'.format(subnet.id))


def list_db_system_shapes(database_client, compartment_id):
    list_db_shape_results = oci.pagination.list_call_get_all_results(
        database_client.list_db_system_shapes,
        availability_domain,
        compartment_id
    )

    print('\nDB System Shapes')
    print('===========================')
    print('{}\n\n'.format(list_db_shape_results.data))


def list_db_versions(database_client, compartment_id):
    list_db_version_results = oci.pagination.list_call_get_all_results(
        database_client.list_db_versions,
        compartment_id
    )

    print('\nDB Versions')
    print('===========================')
    print('{}\n\n'.format(list_db_version_results.data))

    list_db_version_results = oci.pagination.list_call_get_all_results(
        database_client.list_db_versions,
        compartment_id,
        db_system_shape=DB_SYSTEM_SHAPE
    )

    print('\nDB Versions by shape: {}'.format(DB_SYSTEM_SHAPE))
    print('===========================')
    print('{}\n\n'.format(list_db_version_results.data))


def list_db_home_and_databases_under_db_system(database_client, compartment_id, db_system):
    list_db_homes_response = oci.pagination.list_call_get_all_results(
        database_client.list_db_homes,
        compartment_id,
        db_system.id
    )
    print('\nDB Homes For DB System')
    print('===========================')
    print('{}\n\n'.format(list_db_homes_response.data))

    db_home_summary = list_db_homes_response.data[0]
    db_home = database_client.get_db_home(db_home_summary.id).data
    print('\nGet DB Home')
    print('===============')
    print('{}\n\n'.format(db_home))

    list_databases_response = oci.pagination.list_call_get_all_results(
        database_client.list_databases,
        compartment_id,
        db_home.id
    )
    print('\nDatabases For DB Home')
    print('===========================')
    print('{}\n\n'.format(list_databases_response.data))

    database_summary = list_databases_response.data[0]
    database = database_client.get_database(database_summary.id).data
    print('\nGet Database')
    print('===============')
    print('{}\n\n'.format(database))


# Default config file and profile
config = oci.config.from_file()
database_client = oci.database.DatabaseClient(config)
virtual_network_client = oci.core.VirtualNetworkClient(config)

list_db_system_shapes(database_client, compartment_id)
list_db_versions(database_client, compartment_id)

vcn = None
subnet = None
try:
    vcn = create_vcn(virtual_network_client, compartment_id, cidr_block)
    subnet = create_subnet(virtual_network_client, vcn, availability_domain)

    with open(ssh_public_key_path, mode='r') as file:
        ssh_key = file.read()

    launch_db_system_details = oci.database.models.LaunchDbSystemDetails(
        availability_domain=availability_domain,
        compartment_id=compartment_id,
        cpu_core_count=DB_SYSTEM_CPU_CORE_COUNT,
        database_edition=DB_SYSTEM_DB_EDITION,
        initial_data_storage_size_in_gb=256,
        db_home=oci.database.models.CreateDbHomeDetails(
            db_version=DB_VERSION,
            display_name='POCDB1',
            database=oci.database.models.CreateDatabaseDetails(
                admin_password=ADMIN_PASSWORD,
                db_name='DB1'
            )
        ),
        display_name='pocdb1',
        hostname='pocdb1',
        shape=DB_SYSTEM_SHAPE,
        node_count=1,
        ssh_public_keys=[ssh_key],
        subnet_id=subnet.id
    )

    launch_response = database_client.launch_db_system(launch_db_system_details)
    print('\nLaunched DB System')
    print('===========================')
    print('{}\n\n'.format(launch_response.data))

    get_db_system_response = oci.wait_until(
        database_client,
        database_client.get_db_system(launch_response.data.id),
        'lifecycle_state',
        'AVAILABLE',
        max_interval_seconds=900,
        max_wait_seconds=21600
    )

    print('\nDB System Available')
    print('===========================')
    print('{}\n\n'.format(get_db_system_response.data))

    list_db_home_and_databases_under_db_system(database_client, compartment_id, get_db_system_response.data)

    get_db_system_response = database_client.get_db_system(launch_response.data.id)
    database_client.terminate_db_system(get_db_system_response.data.id)
    oci.wait_until(
        database_client,
        get_db_system_response,
        'lifecycle_state',
        'TERMINATED',
        succeed_on_not_found=True
    )
    print('Terminated DB system')
finally:
    if subnet:
        delete_subnet(virtual_network_client, subnet)

    if vcn:
        delete_vcn(virtual_network_client, vcn)
