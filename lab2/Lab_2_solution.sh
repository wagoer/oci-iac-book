oci iam compartment create -c ocid1.tenancy.oc1..aaaaaaaal1fvgn[…] –-name “POCCOMP1” --description “POC Compartment”
set-variable POCCOMP1 "ocid1.compartment.oc1..aaaaaaaaoadg47pc2djpkgk3yckfnmlehna4plyf2k4ofr7lhshim7alq5oq"

oci network vcn create -c $POCCOMP1 --display-name "POCVCN1" --dns-label “pocvcn1” --cidr-block "10.0.0.0/16"
set-variable POCVCN1 "ocid1.vcn.oc1.eu-frankfurt-1.aaaaaaaa3bvbdop74kcwttcnnyv47nuba2ydyvrbkvuqc2eltyzuufkyjsba"

oci network security-list create --generate-full-command-json-input > syntaxsl.json

oci network security-list create  --from-json file://create-POCSL1.json

oci network security-list list -c $POCCOMP1 --vcn-id $POCVCN1

oci network subnet create --vcn-id $POCVCN1 -c $POCCOMP1 --availability-domain "GDyP:EU-FRANKFURT-1-AD-1"
   --display-name “POCSN1” --dns-label "pocsn1" --cidr-block "10.0.0.0/16"
   --security-list-ids
       ‘[\"ocid1.securitylist.oc1.eu-frankfurt-1.aaaaaaaa73pu[…]\",
         \"ocid1.securitylist.oc1.eu-frankfurt-1.aaaaaaaauglr[…]\"]’

set-variable POCSN1 "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaakksygt3vdx2wqilglunek323dsa656f4ztj4ania7fjqbmmagqva"

oci network internet-gateway create -c $POCCOMP1 --is-enabled true --vcn-id $POCVCN1 --display-name “POCIG1”

oci network route-table list -c $POCCOMP1 --vcn-id $POCVCN1

oci network route-table update --rt-id ocid1.routetable.oc1.eu-frankfurt-1.aaaaaaaacj6jbu[…]
   --route-rules
      ‘[{\"cidrBlock\":\"0.0.0.0/0\",
         \"networkEntityId\":\"ocid1.internetgateway[…]\"}]’

oci compute image list -c $POCCOMP1

oci compute shape list -c $POCCOMP1 --availability-domain "GDyP:EU-FRANKFURT-1-AD-1"

oci compute instance launch -c $POCCOMP1 --availability-domain "GDyP:EU-FRANKFURT-1-AD-1" --display-name “POCLINUX1”
   --shape "VM.Standard1.1" --image-id "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaajdge4yzm5j7ci7ryzte7f3qgcekljjw7p6nexhnsvwt6hoybcu3q"
   --ssh-authorized-keys-file “~/POC.pub” --subnet-id $POCSN1

oci compute image list -c $POCCOMP1

oci compute instance launch -c $POCCOMP1 --availability-domain "GDyP:EU-FRANKFURT-1-AD-1" --display-name “POCWINDOWS1”
   --shape "VM.Standard1.1" --image-id "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaabd3goasbc74pfphlyysurtvgox55ryngz5r6tpwnpkx5kddvud6q"
   --subnet-id $POCSN1

oci compute instance list-vnics --instance-id "ocid1.instance.oc1.eu-frankfurt-1.abtheljtoiszzzscx6t5z44aoasyfkovskoyiuvzisbfeegb7wkw557zk5ua"

oci bv volume create -c $POCCOMP1 --availability-domain "GDyP:EU-FRANKFURT-1-AD-1" --display-name “POCBV1” --size-in-mbs 51200

oci compute volume-attachment attach
   --instance-id "ocid1.instance.oc1.eu-frankfurt-1.abtheljtoiszzzscx6t5z44aoasyfkovskoyiuvzisbfeegb7wkw557zk5ua" --type "iscsi"
   --volume-id "ocid1.volume.oc1.eu-frankfurt-1.abtheljt3rkllaemb2b4hgnqmpjfzfaj4bzexpt2r3hbpzjr35yezo2p4grq”


