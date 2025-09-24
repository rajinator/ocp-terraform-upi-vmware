# Openshift Installation with Terraform

- [Openshift Installation with Terraform](#openshift-installation-with-terraform)
  - [Kick-Off Installation](#kick-off-installation)
  - [Waiting for bootstrap to complete](#waiting-for-bootstrap-to-complete)
  - [Copy Kubeconfig to home .kube dir](#copy-kubeconfig-to-home-kube-dir)
  - [Approve CSRs for worker nodes](#approve-csrs-for-worker-nodes)

## Kick-Off Installation

Having satisfied all requirements, use the following commands:

``` bash
$ cd ~/ocp-prereqs/installer/upi/vsphere
$ terraform init
$ terraform plan
# this should give you output saying it wants to create total number of
# resources equalling 1 bootstrap + 3 control-planes + 3 compute nodes + 3 storage nodes = 11


$ terraform apply
# scroll through output then approve if everything looks good
```

- View vCenter for creation of VMs in folder



## Waiting for bootstrap to complete

- Monitor bootstrap progress with this command
  ```bash
  $ cd ~/<install-config-dir>
  $ openshift-install wait-for bootstrap-complete --dir=./
  INFO Waiting up to 30m0s for the Kubernetes API at https://api.ocp4.example.com:6443...
  ....
  ....
  INFO It is now safe to remove the bootstrap resources
  ....
  ```

- At this point it is now safe to remove the bootstrap node from the cluster as well as loadbalancer

## Copy Kubeconfig to home .kube dir

This step adds Kubeconfig to the default kube path of the cluster admin host

***Copy command***
``` bash
$ cp ~/install-config-base/<install-config-dir>/auth/kubeconfg ~/.kube/config
```

***Verification***
``` bash
$ oc get nodes
```

## Approve CSRs for worker nodes

Watch for incoming CSRs for as many workers and if specified, storage nodes with this command:
```bash
$ oc get csr | grep -i pending
```

Once as many CSRs as the number of worker nodes and storage nodes are seen, approve them by following this syntax:
```bash
$ oc adm certificate approve <csr-name>
```
**Note:** You will have to do this process twice. For example if there are **3 worker nodes** and **3 storage nodes** totalling **6 non control-plane nodes**, the number of CSRs to approve will be:
**6** x **2** = **12** CSRs

<br />

- Now monitor the rest of the progress with this command
  ```bash
  $ openshift-install wait-for install-complete --dir=./
  INFO Waiting up to 30m0s for the cluster at https://api.ocp4.example.com:6443 to initialize...
  ...
  INFO Waiting up to 10m0s for the openshift-console route to be created...
  INFO Install complete!
  INFO To access the cluster as the system:admin user when using 'oc', run 'export KUBECONFIG=~/<install-config-dir>/auth/kubeconfig'
  INFO Access the OpenShift web-console here: https://console-openshift-console.apps.ocp4.example.com
  INFO Login to the console with user: kubeadmin, password: xxxxx-xxxxx-xxxxx-xxxxx
  ```

<br />