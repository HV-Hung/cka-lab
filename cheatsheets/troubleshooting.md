# Troubleshooting Cheatsheet

Quick diagnostic steps and checklists for applications, clusters, and nodes.

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

## Network Troubleshooting

1. **Verify Services & Endpoints**:
   ```bash
   k get svc,endpoints
   ```
2. **Test DNS Resolution**:
   ```bash
   k run dns-test --image=busybox -it --rm -- restart=Never -- nslookup kubernetes.default
   ```
3. **Check CoreDNS Pods**:
   ```bash
   k get pods -n kube-system -l k8s-app=kube-dns
   ```
