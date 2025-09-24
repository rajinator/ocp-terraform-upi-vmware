# Setting Up The Cluster Administration Host

- [Setting Up The Cluster Administration Host](#setting-up-the-cluster-administration-host)
  - [1. Cluster Admin Host Specs](#1-cluster-admin-host-specs)
  - [2. Generate SSH Key](#2-generate-ssh-key)
    - [3 OC CLI tools download and install](#3-oc-cli-tools-download-and-install)
  - [4. Download and setup additional tools](#4-download-and-setup-additional-tools)
    - [4.1 govc download and install](#41-govc-download-and-install)
    - [4.2 Terraform download and install](#42-terraform-download-and-install)

The Cluster Administration Host acts as a jumpbox when ssh access is required directly to the OCP nodes. This helps in reducing attack surface by limiting the location of the OCP ssh keys. It also hosts a few key services required during the install process such as an HTTP server and DHCP server. For redundancy, 2 cluster admin hosts can be set up with both having the same contents.

## 1. Cluster Admin Host Specs

- **OS:** minimum CentOS 7.x/RHEL 7.x
- **CPU:** 2 vCPU
- **RAM:** 8 GB
- **Storage:** 70 GB disk space
- **Additional Yum repos:** `epel-release` for CentOS or `rhel-x-extras` for RHEL

<br />

## 2. Generate SSH Key

On the cluster admin host, generate the ssh-key that the `core` user can use to connect to the OCP cluster nodes. This key will be automatically added to the `~/.ssh/authorized_keys` list on the OCP nodes.

***Command***
``` bash
$ ssh-keygen -t rsa -b 4096 -f <path>/<file_name>
```

<br />

### 3 OC CLI tools download and install
- The cli files for various platforms are hosted here https://mirror.openshift.com/pub/openshift-v4/clients/ocp/
- Download the `openshift-client-linux.tar.gz` and `openshift-install-linux.tar.gz` on the Cluster Admin host:
  ``` bash
  $ wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.7.19/openshift-client-linux-4.7.19.tar.gz
  $ wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.7.19/openshift-install-linux-4.7.19.tar.gz
  ```
- Uncompress the archives and put the executables **`oc`**,**`kubectl`** and **`openshift-install`** in the Cluster Admin host's **`PATH`** such as **`/usr/local/bin/`**
- For **RPM** installation method please refer to [Installing the CLI by using an RPM](https://docs.openshift.com/container-platform/4.7/cli_reference/openshift_cli/getting-started-cli.html#cli-installing-cli-rpm_cli-developer-commands)

<br />

## 4. Download and setup additional tools

In order for the customized terraform template install method to work, the following dependences will be needed:
| Tool | Version | Description | Company |
|--|--|--|--|
|**govc**| 0.26.0 | VMWare/Vsphere CLI | VMWare |
|**Terraform**| 1.0.1 | Infrastructure as Code Tool | HashiCorp |

<br />

### 4.1 govc download and install
**govc** source is https://github.com/vmware/govmomi/tree/master/govc
- Download and setup **govc**:
  ```bash
  $ export GOVC_URL=https://github.com/vmware/govmomi/releases/download/v0.26.0/govc_Linux_x86_64.tar.gz
  $ wget ${GOVC_URL}
  $ tar -xzf govc_Linux_x86_64.tar.gz
  $ chmod +x govc
  $ sudo cp govc /usr/local/bin/govc
  ```
- Verification:
  ``` bash
  $ govc version
  govc 0.26.0
  ```

### 4.2 Terraform download and install
`terraform` source is https://www.terraform.io/downloads.html
- Download and setup **terraform**:
  ``` bash
  $ export TERRAFORM_VERSION=1.0.1
  $ curl -O -L https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
  $ unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
  $ sudo cp terraform /usr/local/bin/terraform
  ```
- Verification:
  ``` bash
  $ terraform -v
  Terraform v1.0.1
  ```