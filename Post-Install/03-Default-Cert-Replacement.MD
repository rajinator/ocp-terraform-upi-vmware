# Post Deploy Configuration - Ingress and API Certificates

- [Post Deploy Configuration - Ingress and API Certificates](#post-deploy-configuration---ingress-and-api-certificates)
  - [1. Trust OCTFCU Root CA Cluster-Wide](#1-trust-octfcu-root-ca-cluster-wide)
    - [1.1 Add Custom Cert bundle in Openshift-Config Namespace](#11-add-custom-cert-bundle-in-openshift-config-namespace)
    - [1.2 Edit the Proxy to trust custom cert bundle](#12-edit-the-proxy-to-trust-custom-cert-bundle)
  - [2. Replace the default ingress certificate](#2-replace-the-default-ingress-certificate)
    - [2.1 Pre-Reqs](#21-pre-reqs)
    - [2.2 Procedure](#22-procedure)
  - [3. Adding API server certificates](#3-adding-api-server-certificates)
    - [3.1 Pre-Reqs](#31-pre-reqs)
    - [3.2 Procedure](#32-procedure)


Sources:
[Replacing the default ingress certificate](https://docs.openshift.com/container-platform/4.7/security/certificates/replacing-default-ingress-certificate.html)
[Adding API Server certificates](https://docs.openshift.com/container-platform/4.7/security/certificates/api-server.html)

## 1. Trust OCTFCU Root CA Cluster-Wide

This step is necessary to ensure reliable LDAP connectivity over secure port as well

### 1.1 Add Custom Cert bundle in Openshift-Config Namespace

- Create the yaml file called `user-ca-bundle.yaml` with the following contents:

```yaml
apiVersion: v1
data:
  #indent matters
  ca-bundle.crt: |
    <Paste-chained-certs-in-pem-format>
kind: ConfigMap
metadata:
  name: user-ca-bundle
  namespace: openshift-config
```

- Create the ConfigMap with the file

```bash
oc create -f user-ca-bundle.yaml
```

<br />

### 1.2 Edit the Proxy to trust custom cert bundle

- Use `oc edit` to modify Proxy config

```bash
oc edit proxy/cluster
```

- Configure the necessary fields `spec.trustedCA.name`
```yaml
apiVersion: config.openshift.io/v1
kind: Proxy
metadata:
  name: cluster
spec:
  trustedCA:
    name: user-ca-bundle
```

<br />

## 2. Replace the default ingress certificate

### 2.1 Pre-Reqs

- You must have a wildcard certificate for the fully qualified `.apps` subdomain and its corresponding private key. Each should be in a separate PEM format file.

- The private key **must be unencrypted**. If your key is encrypted, decrypt it before importing it into OpenShift Container Platform.

- The certificate must include the subjectAltName extension showing `*.apps.<clustername>.<domain>`

Th- e certificate file can contain one or more certificates in a chain. The wildcard certificate must be the first certificate in the file. It can then be followed with any intermediate certificates, and the file should end with the root CA certificate.

- Copy the root CA certificate into an additional PEM format file: already done in [Step #1](#1-trust-octfcu-root-ca-cluster-wide)

### 2.2 Procedure

Create a secret that contains the wildcard certificate chain and key:

```bash
$ oc project openshift-ingress
$ oc create secret tls <secret> \
     --cert=</path/to/cert.crt> \
     --key=</path/to/cert.key> \
     -n openshift-ingress
```
- `secret` is the name of the secret that will contain the certificate chain and private key.
- `</path/to/cert.crt>` is the path to the certificate chain on your local file system.
- `</path/to/cert.key>` is the path to the ***unencrypted*** private key associated with this certificate.

Update the Ingress Controller configuration with the newly created secret:

```bash
oc patch ingresscontroller.operator default --type=merge -p '{"spec":{"defaultCertificate": {"name": "<secret>"}}}' -n openshift-ingress-operator
```
- Replace `secret` with the name of the secret used in previous command


Depending on the load, the cluster can take about ~5-12 mins to replace the default ingress certificate and rollout the new ingress pods

<br />

## 3. Adding API server certificates

### 3.1 Pre-Reqs

- You must have a certificate for the FQDN and its corresponding private key. Each should be in a separate PEM format file.

- The private key must be unencrypted. If your key is encrypted, decrypt it before importing it into OpenShift Container Platform.

- The certificate must include the subjectAltName extension showing the FQDN.

- The certificate file can contain one or more certificates in a chain. The certificate for the API server FQDN must be the first certificate in the file. It can then be followed with any intermediate certificates, and the file should end with the root CA certificate.

- **WARNING:**: Do **not** provide a named certificate for the internal load balancer (host name `api-int.<cluster_name>.<base_domain>`). Doing so will leave your cluster in a degraded state.

### 3.2 Procedure

1. Create a secret that contains the certificate chain and private key in the `openshift-config` namespace.

```bash
$ oc create secret tls <secret> \
     --cert=</path/to/cert.crt> \
     --key=</path/to/cert.key> \
     -n openshift-config
```
- `<secret>` is the name of the secret that will contain the certificate chain and private key.
- `</path/to/cert.crt>` is the path to the certificate chain on your local file system.
- `</path/to/cert.key>` is the path to the private key associated with this certificate.


2. Update the API server to reference the created secret.
```bash
$ oc patch apiserver cluster \
     --type=merge -p \
     '{"spec":{"servingCerts": {"namedCertificates":
     [{"names": ["<FQDN>"], 
     "servingCertificate": {"name": "<secret>"}}]}}}' 
```
- Replace `<FQDN>` with the FQDN that the API server should provide the certificate for.
- Replace `<secret>` with the name used for the secret in the previous step.

3. Examine the apiserver/cluster object and confirm the secret is now referenced.

```bash
$ oc get apiserver cluster -o yaml
```
   Example output

   ```yaml
   spec:
     servingCerts:
       namedCertificates:
       - names:
         - <FQDN>
         servingCertificate:
           name: <secret>
   ```