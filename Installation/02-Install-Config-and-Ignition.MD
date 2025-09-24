# Install Config and Ignition Generation

- [Install Config and Ignition Generation](#install-config-and-ignition-generation)
  - [1. Generate `install-config.yaml`](#1-generate-install-configyaml)
    - [1.1 Create install directory:](#11-create-install-directory)
    - [1.2 Get pull secret:](#12-get-pull-secret)
    - [1.3 Create `install-config.yaml` with an IDE (VSCode recommended) or text editor](#13-create-install-configyaml-with-an-ide-vscode-recommended-or-text-editor)
    - [1.4 Backup `install-config.yaml`](#14-backup-install-configyaml)
    - [1.5 Create and modify manifests](#15-create-and-modify-manifests)
  - [2 Generate and host Ignition files](#2-generate-and-host-ignition-files)
  - [2.1 Generate ignition files](#21-generate-ignition-files)
  - [2.2 Copy ignition files to terraform dir](#22-copy-ignition-files-to-terraform-dir)

## 1. Generate `install-config.yaml`

The `install-config.yaml` is used to generate the ignition files necessary for the OCP cluster setup.

The high level steps will be:
- create installation directory
- get RedHat pull secret
- create `install-config.yaml`
- backup `install-config.yaml` for future reference as the install program deletes (consumes) it
- create and modify manifests

<br />

### 1.1 Create install directory:
``` bash
mkdir -p ~/install-base-files/
```

<br />

### 1.2 Get pull secret:

- Location: https://cloud.redhat.com/openshift/install/pull-secret

<br />

### 1.3 Create `install-config.yaml` with an IDE (VSCode recommended) or text editor
``` yaml
#example
apiVersion: v1
baseDomain: example.com
metadata:
  name: ocp4
compute:
- hyperthreading: Enabled
  name: worker
  #replicas has to be 0 for UPI installs
  replicas: 0
controlPlane:
  hyperthreading: Enabled
  name: master
  replicas: 3
networking:
  clusterNetworks:
  - cidr: 10.254.0.0/16
    hostPrefix: 24
  machineNetwork:
  # change this accordingly
  - cidr: 10.0.0.0/24
  networkType: OpenShiftSDN
  serviceNetwork:
  - 172.30.0.0/16  
platform:
  vsphere:
    vcenter: vcsa.example.com
    username: username
    password: password
    datacenter: DC1
    defaultDatastore: datastore1 # relative name of datastore
    folder: "/DC1/vm/OpenShift/OCP4" #Full path to folder check with govc find / -type f
pullSecret: '{"auths": ...}' #redhat pull secret
sshKey: 'ssh-rsa AAAA...' #public key of keypair generated in pre-reqs
```

<br />

### 1.4 Backup `install-config.yaml`

``` bash
$ cp install-config.yaml ~/install-base-files/<datacenter-or-site>-install-config-base-`date +%F`.yaml
```

<br />

### 1.5 Create and modify manifests

**Note**: Do **NOT** reuse install subdir, as the installer generates hidden files that will make a reinstall unsuccessful. delete with `rm -rf` and then reuse the backed up `install-config.yaml`

Copy config to subdir

``` bash
$ mkdir -p ~/install-base-files/ocp-install-config/
$ cp install-config.yaml ~/install-base-files/ocp-install-config/install-config.yaml
$ cd ~/install-base-files/ocp-install-config/
```


Create manifests with this command

``` bash
$ openshift-install create manifests --dir=./
```

**a.** Modify `manifests/cluster-scheduler-02-config.yml` to make masters unschedulabe for app workloads

This section:
``` yaml
spec:
  mastersSchedulable: true
```
change to `false` if `true`
``` yaml
spec:
  mastersSchedulable: false
```

## 2 Generate and host Ignition files

## 2.1 Generate ignition files

Go to the directory where the `openshift-install` command was used.
Then run

```bash
$ openshift-install create ignition-files --dir=./
```

After a successful generation, the folder should look like this
```bash
$ tree
├── auth
│   ├── kubeadmin-password
│   └── kubeconfig
├── bootstrap.ign
├── master.ign
├── metadata.json
└── worker.ign
```

<br />

## 2.2 Copy ignition files to terraform dir

***Command***
```bash
$ cp *.ign ~/install-base-files/tf-upi-with-storage/

$ cd ~/install-base-files/tf-upi-with-storage/

$ ls -l | grep ".ign"
bootstrap.ign
master.ign
worker.ign
```
