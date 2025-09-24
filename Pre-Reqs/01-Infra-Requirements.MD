# Infrastructure Requirements

- [Infrastructure Requirements](#infrastructure-requirements)
  - [1. vCenter Requirements](#1-vcenter-requirements)
  - [2. Machine Requirements](#2-machine-requirements)
  - [3. Network Requirements](#3-network-requirements)
    - [3.1 DHCP Configuration](#31-dhcp-configuration)
    - [3.2 Ports to be open between OCP machines](#32-ports-to-be-open-between-ocp-machines)
    - [3.3 LoadBalancer Ports](#33-loadbalancer-ports)
    - [3.4 VMWare Network Interface MAC Address Ranges:](#34-vmware-network-interface-mac-address-ranges)
    - [3.5 User-provisioned DNS requirements](#35-user-provisioned-dns-requirements)
  - [4. vCenter User Setup](#4-vcenter-user-setup)

## 1. vCenter Requirements

- vSphere version: 6.7U2 or higher
  - Supports VMware NSX-T
  - Supports vSAN, VMFS and NFS using in-tree VCP

- While vSphere 6.5 with Hardware version 13 is supported, OpenShift Container Platform clusters are subject to the following restrictions:

    - NSX-T SDN is not supported.

    - You must use another SDN or storage provider that OpenShift Container Platform supports.

***If you use a vSphere version 6.5 instance, consider upgrading to 6.7U2 before you install OpenShift Container Platform.***

Source: https://docs.openshift.com/container-platform/4.7/installing/installing_vsphere/installing-vsphere.html

<br />

## 2. Machine Requirements

- Minimum cluster must include the following:
  - 1 temporary bootstrap node
  - 3 control plane nodes (masters)
  - 2 compute nodes (workers)

The minimum specs for machines installed using the ***terraform UPI templates*** are as follows:

| Machine | OS | vCPU | RAM | Storage |
|--|--|--|--|--|
| Bootstrap | RHCOS  | 4 | 16 GB | 120 GB |
| Control Plane | RHCOS  | 4 | 16 GB | 120 GB |
| Compute | RHCOS  | 2 | 16 GB | 120 GB |

- For using the template with *storage enabled*, the following are the requirements for 3 OCS nodes in a minimal deployment

| Machine | OS | vCPU | RAM | Storage |
|--|--|--|--|--|
| Storage | RHCOS  | 10 | 24 GB | 120 GB |



<br />

## 3. Network Requirements

### 3.1 DHCP Configuration
For installation using the terraform upi templates, a temporary DHCP server is needed in the subnet for the duration of the install. See this example [dhcpd.conf] file


### 3.2 Ports to be open between OCP machines

| Protocol | Port | Description |
|--|--|--|
| **TCP** | ``2379``-``2380`` | etcd, server, peer and metrics ports |
| | ``6443`` | Kubernetes API |
| | ``9000``-``9999`` | Host level services, including the node exporter on ports ``9100-9101`` and the Cluster Version Operator on port ``9099`` |
| | ``10249``-``10259`` | The default ports that Kubernetes reserves |
| | ``10256`` | openshift-sdn |
| **UDP** | `4789` | VXLAN and GENEVE |
| | ``6081`` | VXLAN and GENEVE |
| | ``9000-9999`` | Host level services, including the node exporter on ports ``9100``-``9101`` |
| | ``30000-32767`` | Kubernetes NodePort |

### 3.3 LoadBalancer Ports

| Port | Machines | Internal | External | Description |
|--|--|--|--|--|
| `6443` | Bootstrap and Control Plane. Remove bootstrap from LB after bootstrap phase complete | x | x | Kubernetes API Server |
| `22623` | Bootstrap and Control Plane. Remove bootstrap from LB after bootstrap phase complete | x |  | Machine Config Server |
| `443` | Machines that run ingress router pods, default compute/worker | x | x | HTTPS traffic |
| `80` | Machines that run ingress router pods, default compute/worker | x | x | HTTP traffic |

### 3.4 VMWare Network Interface MAC Address Ranges:

The NIC MAC Address should fall within these VMWare Organizationally Unique Identifier (OUI) ranges:

  - ``00:05:69:00:00:00`` to ``00:05:69:FF:FF:FF``
  - ``00:0c:29:00:00:00`` to ``00:0c:29:FF:FF:FF``
  - ``00:1c:14:00:00:00`` to ``00:1c:14:FF:FF:FF``
  - ``00:50:56:00:00:00`` to ``00:50:56:FF:FF:FF``

### 3.5 User-provisioned DNS requirements

- For an example of BIND compatible DNS records that need to be in place, please refer to example zonefiles:
    - [Forward zonefile](example-forward.db)
    - [Reverse zonefile](example-reverse.db)
    - See final version excel sheet used prior to provisioning for further info

- In each record, ``<cluster-name>`` from `install-config.yaml` is the cluster name and ``<base_domain>`` is cluster base domain.
  - Complete DNS record takes the form:
    - ``<component>``.``<cluster-name>``.``<base_domain>``
    - for .e.g: `control-plane1.ocp4.example.com`

<br />


## 4. vCenter User Setup

In order for the automated template based install to work, the simplest way to do this is to assign admin role to a specifically created service account for deploying openshift. 


Alternatively, vsphere roles need to be setup with the following privileges:

- **Openshift Deployer Role**:
```
Datastore
   Allocate space
   Low level file operations

Folder
   Create folder
   Delete folder

Network
   Assign network

Resource
   Assign vApp to resource pool
   Assign virtual machine to resource pool
   Create resource pool
   Remove resource pool

vApp
   Clone
   View OVF environment
   vApp application configuration
   vApp instance configuration
   vApp resource configuration

Virtual machine
   Change Configuration
       Acquire disk lease
       Add existing disk
       Add new disk
       Add or remove device
       Advanced configuration
       Change CPU count
       Change Memory
       Change Settings
       Change Swapfile placement
       Change resource
       Configure Host USB device
       Configure Raw device
       Configure managedBy
       Display connection settings
       Extend virtual disk
       Modify device settings
       Query Fault Tolerance compatibility
       Query unowned files
       Reload from path
       Remove disk
       Rename
       Reset guest information
       Set annotation
       Toggle disk change tracking
       Toggle fork parent
       Upgrade virtual machine compatibility
   Edit Inventory
       Create from existing
       Create new
       Move
       Register
       Remove
       Unregister
   Guest operations
       Guest operation alias modification
       Guest operation alias query
       Guest operation modifications
       Guest operation program execution
       Guest operation queries
   Interaction
       Answer question
       Backup operation on virtual machine
       Configure CD media
       Configure floppy media
       Connect devices
       Console interaction
       Create screenshot
       Defragment all disks
       Drag and drop
       Guest operating system management by VIX API
       Inject USB HID scan codes
       Install VMware Tools
       Pause or Unpause
       Perform wipe or shrink operations
       Power off
       Power on
       Record session on virtual machine
       Replay session on virtual machine
       Reset
       Resume Fault Tolerance
       Suspend
       Suspend Fault Tolerance
       Test failover
       Test restart Secondary VM
       Turn off Fault Tolerance
       Turn on Fault Tolerance
   Provisioning
       Allow disk access
       Allow file access
       Allow read-only disk access
       Allow virtual machine download
       Allow virtual machine files upload
       Clone template
       Clone virtual machine
       Create template from virtual machine
       Customize guest
       Deploy template
       Mark as template
       Mark as virtual machine
       Modify customization specification
       Promote disks
       Read customization specifications
```

- **Openshift Storage View** (*vCenter* level)
```
Profile Driven Storage View
```

- **VMDK Dynamic Provisioning**
from [VSphere Storage for Kubernetes](https://vmware.github.io/vsphere-storage-for-kubernetes/documentation/vcp-roles.html#dynamic-provisioning)