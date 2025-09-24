# OCP 4.7 Installation on VMWare with Static IP and Storage Nodes

Documentation of OCP 4.7 + Storage nodes deployment on VMWare with Terraform

> **Note:** This repo is based on the official OpenShift installer UPI vSphere repository: https://github.com/openshift/installer/tree/main/upi/vsphere

## Table of Contents

## Pre-Reqs

### 1. [Infrastructure Requirements](Pre-Reqs/01-Infra-Requirements.MD)
### 2. [Cluster Administration Host Setup](Pre-Reqs/02-Setup-Cluster-Admin-Host.MD)

## Installation

### 1. [OVA Template and Resource Pool](Installation/01-Template-and-Pool.MD)
### 2. [Install Config and Ignition Generation](Installation/02-Install-Config-and-Ignition.MD)
### 3. [Terraform Preparation and Customization](Installation/03-Prepare-and-Customize-Terraform.MD)
### 4. [Openshift Installation with Terraform](Installation/04-Install-Openshift-with-Terraform.MD)

<br />

## Post Install Configuration

### 1. [Deploy OCS](Post-Install/01-Deploy-OCS.MD)
### 2. [Image Registry Setup on VMWare](Post-Install/02-Setup-Image-Registry.MD)
### 3. [Replacing Default Ingress and API certs](Post-Install/03-Default-Cert-Replacement.MD)

## Quay Deployment

## Links

### cluster-1 <DC-short-name>

**console** - console https://console-openshift-console.apps.ocp4.example.com
**api** - https://api.ocp4.example.com:6443

**jumpbox:**
- **IP**: `<jb ip>`
- **Hostname**: `<jb hostname>`

**kube credentials location:**
```bash
/root/.kube/<short-cluster-name>-config
/root/.kube/<short-cluster-name>-kubeadmpw
```

**terraform location:**
```bash
/root/tf-source/
```