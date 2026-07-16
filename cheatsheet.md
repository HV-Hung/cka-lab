# CKA Cheatsheet

Quick reference for the CKA exam. For deep explanations, see each lab's README.

---

## Shell Configuration & Aliases

```bash
# Basic setup
alias k=kubectl
complete -o default -F __start_kubectl k

# Useful variables for fast resource creation
export do="--dry-run=client -o yaml"
export now="--force --grace-period=0"
```

---

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

---

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

---

## Pod / Application Troubleshooting

1. **Check Pod Status**:
   ```bash
   k get pods -o wide
   k get pods -n <namespace>
   ```
2. **Describe Pod for Event logs**:
   ```bash
   k describe pod <pod-name>
   ```
3. **Check Container Logs**:
   ```bash
   k logs <pod-name>
   k logs <pod-name> -c <container-name>
   k logs <pod-name> --previous
   ```
4. **Shell/Command Line debug**:
   ```bash
   k exec -it <pod-name> -- /bin/sh
   ```

---

## Control Plane & Node Troubleshooting

1. **Check Node Status**:
   ```bash
   k get nodes -o wide
   k describe node <node-name>
   ```
2. **Inspect Systemd Services (SSH to node)**:
   ```bash
   systemctl status kubelet
   systemctl status container-engine (e.g. docker, containerd)
   journalctl -u kubelet -n 100 --no-pager
   ```
3. **Verify Static Pod Manifests (SSH to control plane)**:
   Check `/etc/kubernetes/manifests/` for control plane components:
   - `kube-apiserver.yaml`
   - `kube-controller-manager.yaml`
   - `kube-scheduler.yaml`
   - `etcd.yaml`
4. **Check Logs of Static Pods**:
   If the api-server is down, use container runtime commands on the host:
   ```bash
   crictl ps
   crictl logs <container-id>
   ```

---

## Network Troubleshooting

1. **Verify Services & Endpoints**:
   ```bash
   k get svc,endpoints
   ```
2. **Test DNS Resolution**:
   ```bash
   k run dns-test --image=busybox -it --rm --restart=Never -- nslookup kubernetes.default
   ```
3. **Check CoreDNS Pods**:
   ```bash
   k get pods -n kube-system -l k8s-app=kube-dns
   ```

---

## Common YAML Templates

### Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: web
spec:
  containers:
  - name: nginx
    image: nginx:1.21.6
    ports:
    - containerPort: 80
```

### Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: web
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx:1.21.6
        ports:
        - containerPort: 80
```

### PersistentVolume & Claim

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-volume
spec:
  storageClassName: manual
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pv-claim
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 3Gi
```

### NetworkPolicy

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: test-network-policy
  namespace: default
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - ipBlock:
        cidr: 172.17.0.0/16
        except:
        - 172.17.1.0/24
    - namespaceSelector:
        matchLabels:
          project: myproject
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 6379
```
