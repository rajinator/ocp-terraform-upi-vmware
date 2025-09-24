# vCenter prep - Template upload and resource pool info

- [vCenter prep - Template upload and resource pool info](#vcenter-prep---template-upload-and-resource-pool-info)
  - [1. Procure and upload template](#1-procure-and-upload-template)
  - [2. Create GOVC Credentials ENV file](#2-create-govc-credentials-env-file)
  - [3. Fetch Resource Pool info](#3-fetch-resource-pool-info)

## 1. Procure and upload template

For this environment, we are going to use the **`ova`** file provided by Red Hat, in conjuction with **`Terraform`** to deploy an **OCP 4.7** cluster

The location for the version used for the clusters deployed with this repo as of writing is - https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.7/4.7.13/

1. Download the file `https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.7/4.7.13/rhcos-4.7.13-x86_64-vmware.x86_64.ova` and upload to vCenter as a template. Ideally place it in the parent subfolder of the cluster's folder
2. Rename it to `rhcos-4.7.13-template` for easy use of the sample `terraform.tfvars` file

## 2. Create GOVC Credentials ENV file

Create a file like this to set `govc` env variables. The user and password for the openshift deployer Service account should be used here.

**Note:** This file should only be readable by an admin level linux account on the cluster Admin Host

```bash
mkdir -p ~/.govc/
vim ~/.govc/env-source.sh
export GOVC_URL='vcsa.example.com'
export GOVC_USERNAME='openshift-svc@example.com'
export GOVC_PASSWORD='<service-account-password>'
export GOVC_INSECURE=1'
```

Verify that the login works
``` bash
$ source govc-creds.sh
$ govc about
Name: VMware vCenter Server
Vendor: VMware, Inc.
Version: 6.7.0
...
```

## 3. Fetch Resource Pool info

Find a resource pool that can be used for OCP. For example on Tustin:

```
bash
$ govc find / -type p | grep -i open
/DC1/host/ResourcePool1/Resources
```

The part of the pool path to use in terraform.tfvars is the relative path after the **host** like below:
```
ResourcePool1/Resources
```