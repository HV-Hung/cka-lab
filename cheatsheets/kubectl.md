# Kubectl Cheatsheet

A curated list of essential `kubectl` commands and aliases for CKA exam preparation.

## Shell Configuration & Aliases

Add these to your shell profile (`~/.bashrc` or `~/.zshrc`) or run them in your active terminal:

```bash
# Basic setup
alias k=kubectl
complete -o default -F __start_kubectl k

# Useful variables for fast resource creation
export do="--dry-run=client -o yaml"
export now="--force --grace-period=0"
```

## Imperative Commands (Fast Creation)

### Pods
```bash
# Create a pod
k run nginx --image=nginx $do

# Create a pod with a custom command/args
k run busybox --image=busybox $do -- sleep 3600
```

### Deployments
```bash
# Create a deployment
k create deployment my-dep --image=nginx --replicas=3 $do
```

### Services
```bash
# Expose a pod as ClusterIP service
k expose pod nginx --port=80 --target-port=80 --name=nginx-svc $do

# Create NodePort service
k create service nodeport nginx-np --tcp=80:80 $do
```

### ConfigMaps & Secrets
```bash
# Create a ConfigMap from literal values
k create configmap my-config --from-literal=key1=val1 --from-literal=key2=val2

# Create a Secret (generic) from literal
k create secret generic my-secret --from-literal=password=supersecret
```

### RBAC
```bash
# Create a ServiceAccount
k create sa custom-sa

# Create a Role
k create role pod-reader --verb=get,list,watch --resource=pods

# Create a RoleBinding
k create rolebinding read-pods --role=pod-reader --serviceaccount=default:custom-sa
```

## Troubleshooting & Inspection

```bash
# Get details of a resource
k describe pod nginx

# View logs of a container
k logs nginx -c container-name

# Stream logs
k logs -f nginx

# Execute command inside a pod
k exec -it nginx -- sh

# Explain a resource schema (extremely useful during exam!)
k explain pod.spec.containers
```
