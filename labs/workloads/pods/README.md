# Lab: Pods

> Domain: Workloads | Difficulty: Beginner

## Objective

In this lab you will learn how to declaratively create, inspect, and interact with single-container and multi-container Pods, including sharing data between containers using a volume.

## Prerequisites

- Running cluster (`make up` from repo root)

## Key Concepts

- A Pod is the smallest deployable object in Kubernetes.
- Pods can contain one or more containers that share the same network namespace and storage volumes.
- Pods are typically managed by higher-level controllers (like Deployments) rather than being created directly.

## Steps

### Step 1 — Create a Single-Container Pod

We will deploy a basic Pod running an NGINX web server. 

```bash
kubectl apply -f manifests/01-pod-single.yaml
```

Verify:
```bash
kubectl get pod pod-single
```

Expected output:
```
NAME         READY   STATUS    RESTARTS   AGE
pod-single   1/1     Running   0          ...
```

### Step 2 — Create a Multi-Container Pod

We will deploy a Pod with two containers: an NGINX web server and a busybox sidecar. The sidecar container writes a message to a shared `emptyDir` volume, which NGINX then serves.

```bash
kubectl apply -f manifests/02-pod-multi.yaml
```

Verify the Pod is running with 2 out of 2 containers ready:
```bash
kubectl get pod pod-multi
```

Expected output:
```
NAME        READY   STATUS    RESTARTS   AGE
pod-multi   2/2     Running   0          ...
```

Verify the shared volume works by sending a request to the NGINX container:
```bash
kubectl exec pod-multi -c nginx -- curl -s localhost
```

Expected output:
```
Hello from the sidecar!
```

### Step 3 — Break It & Troubleshoot

The `manifests/99-broken-image.yaml` manifest contains a common typo in the container image name.

Apply the broken manifest:
```bash
kubectl apply -f manifests/99-broken-image.yaml
```

Check the status:
```bash
kubectl get pod pod-broken
```

You will see the status `ErrImagePull` or `ImagePullBackOff`.
To find out why, check the Pod's events:
```bash
kubectl describe pod pod-broken
```

**Fix it imperatively:**
Instead of fixing the YAML (to keep the broken example), you can fix the Pod directly in the cluster using `kubectl set image`. The `image` field is one of the few fields in a Pod that is mutable.
```bash
kubectl set image pod/pod-broken app=nginx:1.25
```

## Validation

Run these commands to verify that the Pods are functioning correctly.

```bash
# Verify both pods are running
kubectl get pods -l app.kubernetes.io/part-of=cka-lab
```

Expected output:
```
NAME         READY   STATUS    RESTARTS   AGE
pod-multi    2/2     Running   0          ...
pod-single   1/1     Running   0          ...
```

```bash
# Verify single pod NGINX is responding
kubectl exec pod-single -- curl -s localhost | grep "<title>"
```

Expected output:
```
<title>Welcome to nginx!</title>
```

```bash
# Verify multi pod is serving the file created by the sidecar
kubectl exec pod-multi -c nginx -- curl -s localhost
```

Expected output:
```
Hello from the sidecar!
```

## Cleanup

```bash
# Remove all lab resources
kubectl delete -f manifests/
```

## Lessons Learned

- **Core object**: Pods are the basic building blocks in Kubernetes, encapsulating one or more containers.
- **Shared resources**: Containers within the same Pod share the same network namespace and can share storage volumes (like `emptyDir`).
- **Mutability**: You cannot change most fields of a running Pod, but the `image` field is an exception.

### CKA Tips

- Use `kubectl run nginx --image=nginx -o yaml --dry-run=client > pod.yaml` to quickly generate a Pod manifest during the exam.
- Know how to use `kubectl set image` to quickly fix image-related errors without needing to delete and recreate the Pod.
- For multi-container Pods, always remember to specify the container name using `-c <container_name>` when checking logs (`kubectl logs`) or executing commands (`kubectl exec`).

### Common Mistakes

- **Typos in image names**: This immediately results in an `ImagePullBackOff`. Always check `kubectl describe pod` events to confirm.
- **Forgetting `-c` in multi-container Pods**: If you try to exec or view logs of a multi-container Pod without specifying a container, Kubernetes will often default to the first container, which might not be the one you want.
