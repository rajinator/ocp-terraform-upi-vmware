# Installing and Configuring Red Hat OpenShift Container Storage

- [Installing and Configuring Red Hat OpenShift Container Storage](#installing-and-configuring-red-hat-openshift-container-storage)
  - [1. Pre-Reqs](#1-pre-reqs)
    - [1.1 Disk and datastore setup](#11-disk-and-datastore-setup)
    - [1.2 Label and taint nodes](#12-label-and-taint-nodes)
    - [1.3 Optional - Drain Nodes](#13-optional---drain-nodes)
  - [2 Install Operators](#2-install-operators)
    - [2.1 Install Local Storage Operator](#21-install-local-storage-operator)
    - [2.2 Install OCS Operator](#22-install-ocs-operator)
  - [3 Deploying OCS Storage](#3-deploying-ocs-storage)
    - [3.1 Storage Cluster Creation](#31-storage-cluster-creation)
    - [3.2 Verification](#32-verification)

## 1. Pre-Reqs

There are a few reqs to do on the VM side of things before installing OCS:

Source: [How to use dedicated worker nodes for Red Hat OpenShift Container Storage](https://access.redhat.com/documentation/en-us/red_hat_openshift_container_storage/4.7/html-single/managing_and_allocating_storage_resources/index#how-to-use-dedicated-worker-nodes-for-openshift-container-storage_rhocs)

### 1.1 Disk and datastore setup

- Attach a disk of 3 TB to each of the storage nodes. 
- Make sure each storage node is on a different ESXI host if possible for proper HA
- **Optional:** Depending on how your storage backend is, it ***may*** make sense to use a different datastore for each VM

### 1.2 Label and taint nodes

Label each node in the cluster with the following commands:

- Labeling
```bash
$ oc label node <storage-node-name> node-role.kubernetes.io/infra=""
$ oc label node <storage-node-name> cluster.ocs.openshift.io/openshift-storage=""
```

- Tainting
```bash
$ oc adm taint node <storage-node-name> node.ocs.openshift.io/storage="true":NoSchedule
```

The taints and label will ensure that license entitlements are not counted against OCS nodes.


### 1.3 Optional - Drain Nodes

If the cluster has been up for a while with some workloads, it may be pertinent to drain the nodes to make sure non OCS and infra workloads are removed from the nodes with this command

```bash
$ kubectl drain node <storage-node-name> --ignore-daemonsets --delete-local-data --force
```

<br />

## 2 Install Operators

### 2.1 Install Local Storage Operator

1. Navigate in the web console to the click **Operators → OperatorHub**.
2. Scroll or type a keyword into the Filter by keyword box to search for *Local Storage Operator* and click on it when it appears in search results.
3. Click **Install** on the Local Storage operator page.
4. On the **Install Operator** page, the following required options are selected by default:
   - Update Channel as **stable-4.7**.
   - Installation Mode as **A specific namespace on the cluster**.
   - Installed Namespace as Operator recommended namespace **openshift-local-storage**
5. Select **Approval Strategy** as **Automatic**
6. Click Install.
7. Verify that the Local Storage Operator shows **Status** as `Succeeded`
8. *Might be required*: Apply a namespace selector and taint toleration, via annotations to the `openshift-local-storage` namespace

```bash
$ oc annotate namespace openshift-storage openshift.io/node-selector=
$ oc annotate namespace openshift-storage scheduler.alpha.kubernetes.io/defaultTolerations=[{"operator": "Exists", "effect": "NoSchedule", "key":"node.ocs.openshift.io/storage"}]
```

### 2.2 Install OCS Operator

1. Navigate in the web console to the click **Operators → OperatorHub**.
2. Scroll or type a keyword into the Filter by keyword box to search for OpenShift Container Storage Operator.
3. Click **Install** on the OpenShift Container Storage operator page.
4. On the **Install Operator** page, the following required options are selected by default:

   - Update Channel as `stable-4.7`.
   - Installation Mode as A specific namespace on the cluster.
   - Installed Namespace as Operator recommended namespace `openshift-storage`. If Namespace openshift-storage does not exist, it will be created during the operator installation.
5. Select **Approval Strategy** as **Automatic** or **Manual**.
6. Click Install.

   - If you selected **Automatic** updates, then the Operator Lifecycle Manager (OLM) automatically upgrades the running instance of your Operator without any intervention.

   - If you selected **Manual** updates, then the OLM creates an update request. As a cluster administrator, you must then manually approve that update request to have the Operator updated to the new version.

7. *Might be required*: Apply a namespace selector and taint toleration, via annotations to the `openshift-storage` namespace

```bash
$ oc annotate namespace openshift-storage openshift.io/node-selector=
$ oc annotate namespace openshift-storage scheduler.alpha.kubernetes.io/defaultTolerations=[{"operator": "Exists", "effect": "NoSchedule", "key":"node.ocs.openshift.io/storage"}]
```

<br />

## 3 Deploying OCS Storage

### 3.1 Storage Cluster Creation

1. Log into the OpenShift Web Console.
2. Click **Operators → Installed Operators** to view all the installed operators.
   - Ensure that the **Project** selected is **openshift-storage**.
3. Click **OpenShift Container Storage > Create Instance** link of Storage Cluster.
4. Choose **Select Mode** as **Internal-Attached devices**.
NOTE
You are prompted to install the Local Storage Operator if it is not already installed. Click Install and follows procedure as described in Installing Local Storage Operator.

5. Discover disks
   - Choose `Select nodes` to discover from a subset. In the selection, select storage nodes labelled and tainted earlier
   - **Note:** If tainted nodes from earlier are not shown in node selection process, please follow this knowledgebase solution https://access.redhat.com/solutions/5627951
6. Create Storage Class
   - Name the Volume set `localscblock`
   - Select the storage nodes again
   - Expand the Advanced section, select device type `disk`
   - Minimum size set to `1 TB`

7. Set Storage and Nodes
   - For **Storage Class** selection, the new storage class created in previous step will be selected
   - `Selected Nodes` will show nodes elected in previous step, this list will take a few minutes to reflect the disk selection

8. Review configuration details
9. Click `Create`

### 3.2 Verification

For verification, please confirm deployment details with instructions in this link -  [Verifying OpenShift Container Storage deployment for internal mode](https://access.redhat.com/documentation/en-us/red_hat_openshift_container_storage/4.7/html-single/deploying_openshift_container_storage_on_vmware_vsphere/index#verifying-openshift-container-storage-deployment_rhocs)