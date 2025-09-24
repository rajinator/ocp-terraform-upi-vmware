// ID identifying the cluster to create. Use your username so that resources created can be tracked back to you.
cluster_id = "ocp4"

// Domain of the cluster. This should be "${cluster_id}.${base_domain}".
cluster_domain = "ocp4.example.com"

// Base domain from which the cluster domain is a subdomain.
base_domain = "example.com"

// Name of the vSphere server. The dev cluster is on "vcsa.vmware.devcluster.openshift.com".
vsphere_server = "vcsa.example.com"

// User on the vSphere server.
vsphere_user = "user"

// Password of the user on the vSphere server.
vsphere_password = ""

// Name of the vSphere cluster. The dev cluster is "devel".
vsphere_cluster = "Cluster"

// Name of the vSphere data center. The dev cluster is "dc1".
vsphere_datacenter = "DC1"

// Name of the vSphere data store to use for the VMs. The dev cluster uses "nvme-ds1".
vsphere_datastore = "datastore1"

// Name of the vSphere network to use for the VMs
vm_network = "/DC1/network/ocp-network"

// Name of the vsphere folder to use
vsphere_folder = "OpenShift/OCP4"

// Name of the vsphere resource pool to use
vsphere_resource_pool = "ResourcePool1/Resources"

// Name of the VM template to clone to create VMs for the cluster. The dev cluster has a template named "rhcos-latest".
vm_template = "rhcos-4.7.13-template"

// The machine_cidr where IP addresses will be assigned for cluster nodes.
// Additionally, IPAM will assign IPs based on the network ID. 
machine_cidr = "10.0.0.0/24"

// The DNS server addresses used by the VMs
vm_dns_addresses = ["10.0.0.2", "192.168.1.1"]

// The IP of the gateway used by the VMs
vm_gateway = "10.0.0.1"

// The number of control plane VMs to create. Default is 3.
control_plane_count = 3

// The number of compute VMs to create. Default is 3.
compute_count = 3

// The number of storage VMs to create. Minimum needed for OCS is 3.
storage_count = 3

// Ignition config path for the bootstrap machine
bootstrap_ignition_path = "./bootstrap.ign"

// Ignition config path for the control plane machines
control_plane_ignition_path = "./master.ign"

// Ignition config path for the compute machines
compute_ignition_path = "./worker.ign"


// Set bootstrap_ip, control_plane_ip, and compute_ip if you want to use static
// IPs reserved someone else, rather than the IPAM server.

// The IP address to assign to the bootstrap VM.
bootstrap_ip = [ "10.0.0.10" ]

// The IP addresses to assign to the control plane VMs. The length of this list
// must match the value of control_plane_count.
control_plane_ips = ["10.0.0.11", "10.0.0.12", "10.0.0.13"]

// The IP addresses to assign to the compute VMs. The length of this list must
// match the value of compute_count.
compute_ips = ["10.0.0.14", "10.0.0.15", "10.0.0.16"]

// // The IP addresses to assign to the storage VMs. The length of this list must
// match the value of compute_count.
#storage_ips = ["10.0.0.17", "10.0.0.18", "10.0.0.19"]
