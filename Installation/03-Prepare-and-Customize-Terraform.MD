# Terraform Preparation and Customization

- [Terraform Preparation and Customization](#terraform-preparation-and-customization)
  - [1. Procure Installer templates](#1-procure-installer-templates)
  - [2. Populate `terraform.tfvars`](#2-populate-terraformtfvars)
  - [3. (Optional) Modify `variables.tf` for node sizing](#3-optional-modify-variablestf-for-node-sizing)
  - [4. (Optional) Changing VM default disk size](#4-optional-changing-vm-default-disk-size)

## 1. Procure Installer templates

- Location of installer source on bastion hosts - 
```bash
/root/tf-source/upi-tf-with-storage.zip
```

- Extract to this location
```bash
$ mkdir -p ~/install-base-files/upi-tf-with-storage/
$ cp /root/tf-upi-source/upi-tf-with-storage.zip ~/install-base-files/upi-tf-with-storage/
$ cd ~/install-base-files/upi-tf-with-storage/
$ unzip upi-tf-with-storage.zip
```

- The folder structure for `upi-tf-with-storage` directory should look like this
```bash
$ tree
.
├── OWNERS
├── cluster_domain
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── host_a_record
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── ipam
│   ├── cidr_to_ip.sh
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
│   └── versions.tf
├── main.tf
├── terraform.tfvars
├── terraform.tfvars.example
├── variables.tf
├── versions.tf
└── vm
    ├── main.tf
    ├── variables.tf
    └── versions.tf

```

## 2. Populate `terraform.tfvars`

- Open `terraform.tfvars` in `vim` or an IDE such as VSCode
- Populate the sections as necessary.
- Refer to comments in file and previously used tfvars file for further info

Here is the example of `terraform.tfvars` for the Tustin cluster
**note:** storage nodes were added separately in tustin, but this is how you would use the newest template

```
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


// The hostname prefix to assign to the bootstrap VM
bootstrap_name_prefix = "bootstrap"

// The hostname prefix to assign to the control plane VMs
control_plane_name_prefix = "control-plane-"

// The hostname prefix to assign to the compute VMs
compute_name_prefix = "compute-"

// The hostname prefix to assign to the storage VMs
storage_name_prefix = "storage-"

```

## 3. (Optional) Modify `variables.tf` for node sizing

Check and edit the sections of `variables.tf` to modify node sizing for `control-plane`, `compute` and `storage` nodes. 

For example, here's the relevant resource variables for `storage` nodes.
**Note:** Memory `limit` must be equal or greater than `reservation` and `memory` fields.

```

variable "storage_memory" {
  type    = string
  default = "36864"
}

variable "storage_memory_limit" {
  type    = string
  default = "36864"
}

variable "storage_memory_reservation" {
  type    = string
  default = "36864"
}

variable "storage_num_cpus" {
  type    = string
  default = "10"
}
```

## 4. (Optional) Changing VM default disk size

This applies to **all VMs**

Check and edit `vm/main.tf`  for default disk size which is currently set to `120`, here's the relevant lines:

```
  disk {
    label            = "disk0"
    size             = 120
    thin_provisioned = var.disk_thin_provisioned
  }
```