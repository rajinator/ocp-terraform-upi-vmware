# Post Deploy Configuration - Image Registry Setup

- [Post Deploy Configuration - Image Registry Setup](#post-deploy-configuration---image-registry-setup)
    - [Preamble](#preamble)
    - [Pre-reqs](#pre-reqs)
    - [1.1 Create the PVC](#11-create-the-pvc)
    - [1.2 Edit Image Registry Operator](#12-edit-image-registry-operator)
    - [1.3 Verification](#13-verification)

**Note**: This is for the Cluster's ***internal*** image registry, **NOT** Quay.

Sources:
- [Configuring Image Registry to use OpenShift Container Storage](https://access.redhat.com/documentation/en-us/red_hat_openshift_container_storage/4.7/html/managing_and_allocating_storage_resources/configure-storage-for-openshift-container-platform-services_rhocs#configuring-image-registry-to-use-openshift-container-storage_rhocs)
- [Image Registry removed during installation](https://docs.openshift.com/container-platform/4.7/installing/installing_vsphere/installing-vsphere.html#registry-removed_installing-vsphere)


### Preamble

On platforms that do not provide shareable object storage or storage with access mode `ReadWriteMany`, the OpenShift Image Registry Operator bootstraps itself as Removed. This allows openshift-installer to complete installations on these platform types.

After installation, you must edit the Image Registry Operator configuration to switch the `ManagementState` from `Removed` to `Managed`.


The Prometheus console provides an ImageRegistryRemoved alert, for example:

```
"Image Registry has been removed. ImageStreamTags, BuildConfigs and DeploymentConfigs which reference ImageStreamTags may not work
 as expected. Please configure storage and update the config to Managed state by editing configs.imageregistry.operator.openshift.io."
```

**Note**: The registry claim must be atleast "**100Gi**" in size.

<br />


### Pre-reqs

-  You have administrative access to OpenShift Web Console.
- OpenShift Container Storage Operator is installed and running in the **openshift-storage** namespace. In OpenShift Web Console, click **Operators → Installed Operators** to view installed operators.
- Image Registry Operator is installed and running in the openshift-image-registry namespace. In OpenShift Web Console, click **Administration → Cluster Settings → Cluster Operator**s to view cluster operators.
- A storage class with provisioner `openshift-storage.cephfs.csi.ceph.com` is available. In OpenShift Web Console, click **Storage → Storage Classes** to view available storage classes.

### 1.1 Create the PVC

1. In the OpenShift Web Console, click Storage → Persistent Volume Claims.
Set the Project to openshift-image-registry.
2. Click Create Persistent Volume Claim.

   - From the list of available storage classes retrieved above, specify the Storage Class with the provisioner `openshift-storage.cephfs.csi.ceph.com`.
   - Specify the Persistent Volume Claim **Name**, for example, **ocs4registry**.
   - Specify an **Access Mode** of Shared Access (**ReadWriteMany/RWX**).
   - Specify a Size of at least `100 GB`. (`250 GB` recommended)
3. Click Create.

Wait until the status of the new Persistent Volume Claim is listed as Bound.

### 1.2 Edit Image Registry Operator

1. Edit ClusterOperator Config to use PVC by setting the following fields - `managementState` and `storage.pvc.claim`
     ``` bash
     $ oc edit configs.imageregistry.operator.openshift.io
     ```
     ```yaml
     spec:
       managementState: Managed
       storage:
         pvc:
           claim: "ocs4registry"
     ```
2. check ClusterOperator status

     ``` bash
     $ oc get clusteroperators.config.openshift.io image-registry
     NAME             VERSION   AVAILABLE   PROGRESSING   DEGRADED   SINCE
     image-registry   4.7.13     True        False         False      10d
     ```

### 1.3 Verification

A. Watch image-registry pods come up

     ``` bash
     $ watch -n5 oc get pods -n openshift-image-registry
     NAME                                             READY   STATUS    RESTARTS   AGE
     cluster-image-registry-operator-xxxxxxxx-xxxx    2/2     Running   2          10d
     image-registry-xxxxxxxx-xxxxx                    1/1     Running   1          10d
     node-ca-xxxx                                     1/1     Running   2          10d
     node-ca-xxxx                                     1/1     Running   2          10d
     node-ca-xxxx                                     1/1     Running   2          10d
     node-ca-xxxx                                     1/1     Running   2          10d
     node-ca-xxxx                                     1/1     Running   2          10d
     ```

or 

B. Gui Verification:

1. Click **Workloads → Pods**.
2. Set the Project to **openshift-image-registry**.
3. Verify that the new **image-registry-*** pod appears with a status of `Running`, and that the previous **image-registry-*** pod terminates.
4. Click the new image-registry-* pod to view pod details.
5. Scroll down to **Volumes** and verify that the registry-storage volume has a **Type** that matches your new Persistent Volume Claim, for example, **ocs4registry**.