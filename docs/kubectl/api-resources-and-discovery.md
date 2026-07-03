# Kubernetes API Resources and Discovery

## Overview

Kubernetes is an API-driven system. `kubectl` is not a magic tool that directly controls Pods, Nodes, kubelets, controllers, or etcd. It is an HTTP client that talks to the Kubernetes API Server.

The API Server exposes Kubernetes concepts as API resources. `kubectl` discovers those resources, sends authenticated requests to the correct API endpoint, and formats the response for humans.

This topic continues from the kubectl request flow, kubeconfig, TLS, and authentication topics.

## Architecture

```text
kubectl
  ↓
read kubeconfig
  ↓
connect to API Server over HTTPS
  ↓
authenticate
  ↓
authorize
  ↓
discover API groups, versions, and resources
  ↓
send REST request to the correct endpoint
  ↓
API Server validates and stores/reads objects from etcd
  ↓
controllers watch objects and reconcile actual state
```

The key idea is:

```text
Users and controllers communicate through API objects.
They do not directly call each other.
```

For example, the Scheduler does not call the kubelet directly. It updates the Pod object with `spec.nodeName`. The kubelet watches Pods assigned to its node and starts containers locally.

```text
Scheduler
  ↓ PATCH Pod.spec.nodeName
API Server
  ↓
etcd
  ↓ watch event
Kubelet on selected node
  ↓
container runtime
```

## Key Concepts

### Kubernetes is resource-oriented

Kubernetes could have been designed as a command-oriented system:

```text
start-container
stop-container
restart-container
scale-app
```

Instead, Kubernetes is resource-oriented and declarative.

Users submit desired state:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 3
```

The API Server stores the object. Controllers then reconcile the cluster toward the desired state.

This enables:

- self-healing
- eventual consistency
- clean separation of responsibility
- extensibility through custom resources and controllers
- failure isolation between control-plane components

### Resource vs object

A resource is an API type exposed by the Kubernetes API.

An object is one persisted instance of that resource.

Example:

```text
Resource type: pods
Objects: nginx, redis, backend-api
```

Example:

```text
Resource type: deployments.apps
Objects: frontend, payment-api, user-service
```

A useful analogy is a database table and rows:

```text
Resource = table/type
Object   = row/instance
```

Avoid thinking of a resource as an interface. A Kubernetes resource does not define behavior like a programming interface. It defines an API type and REST endpoint.

### Desired state and controllers

When a Deployment is applied, the API Server does not directly create containers.

The flow is:

```text
kubectl apply -f deployment.yaml
  ↓
API Server validates and stores Deployment object
  ↓
Deployment Controller watches Deployment
  ↓
Deployment Controller creates/updates ReplicaSet
  ↓
ReplicaSet Controller watches ReplicaSet
  ↓
ReplicaSet Controller creates/updates Pods
  ↓
Scheduler watches unscheduled Pods
  ↓
Scheduler assigns nodeName
  ↓
Kubelet watches Pods assigned to its node
  ↓
Kubelet starts containers through the container runtime
```

Important rule:

```text
Only the API Server talks directly to etcd.
Controllers, scheduler, kubelet, and kubectl all talk to the API Server.
```

### Watch-based architecture

Kubernetes components do not usually poll every second. They use the Watch API.

A watch is like a subscription to object changes.

Example kubelet mental model:

```text
Watch Pods where spec.nodeName == this node
```

When a Pod is assigned to a node, the kubelet receives an event, reads the Pod specification, and reconciles the local node state.

The Scheduler and kubelet do not communicate directly.

```text
Scheduler → API Server → Pod object → API Server watch → Kubelet
```

### Pod deletion is also declarative

`kubectl delete pod nginx` is not an SSH command to the node.

The API Server does not directly kill containers.

Deletion is a state transition:

```text
kubectl delete pod nginx
  ↓
API Server sets metadata.deletionTimestamp
  ↓
Pod object still exists temporarily
  ↓
Kubelet receives MODIFIED event
  ↓
Kubelet gracefully stops containers
  ↓
Kubelet cleans up sandbox, volumes, and local state
  ↓
Pod object is eventually removed
```

This avoids orphaned containers where the API object disappears before the node has cleaned up the workload.

### API Groups

An API Group is a logical namespace for related API resources.

Each API Group owns its own versions and can evolve independently.

```text
Kubernetes API
│
├── Core Group (empty group name)
│   └── v1
│       ├── Pod
│       ├── Service
│       ├── Secret
│       ├── ConfigMap
│       └── Namespace
│
├── apps
│   └── v1
│       ├── Deployment
│       ├── ReplicaSet
│       ├── StatefulSet
│       └── DaemonSet
│
├── batch
│   └── v1
│       ├── Job
│       └── CronJob
│
├── networking.k8s.io
│   └── v1
│       ├── Ingress
│       └── NetworkPolicy
│
└── rbac.authorization.k8s.io
    └── v1
        ├── Role
        ├── ClusterRole
        ├── RoleBinding
        └── ClusterRoleBinding
```

The Core API Group has an empty group name. That is why a Pod uses:

```yaml
apiVersion: v1
kind: Pod
```

A Deployment belongs to the `apps` API Group:

```yaml
apiVersion: apps/v1
kind: Deployment
```

The `apiVersion` field contains two pieces of information:

```text
apiVersion: apps/v1

Group   = apps
Version = v1
```

For the Core API Group:

```text
apiVersion: v1

Group   = ""
Version = v1
```

### REST paths

Core API resources use `/api`:

```http
GET /api/v1/pods
GET /api/v1/services
```

Named API Groups use `/apis`:

```http
GET /apis/apps/v1/deployments
GET /apis/batch/v1/jobs
GET /apis/networking.k8s.io/v1/ingresses
```

The difference between `/api` and `/apis` exists for historical compatibility. The original core API path was `/api/v1`; named API Groups were added later under `/apis`.

### Discovery API

`kubectl` does not hardcode every Kubernetes resource.

Instead, it asks the API Server what it supports.

```text
kubectl
  ↓
GET /
  ↓
GET /api
  ↓
GET /apis
  ↓
GET /apis/{group}
  ↓
GET /apis/{group}/{version}
```

This is the Discovery API.

It tells clients:

- which API groups exist
- which versions each group supports
- which version is preferred
- which resources exist in each group/version
- whether a resource is namespaced
- which verbs a resource supports
- resource short names such as `po`, `svc`, and `deploy`

This is why `kubectl` can work with CRDs without being updated.

If a CRD defines:

```yaml
spec:
  names:
    plural: databases
    singular: database
    kind: Database
    shortNames:
      - db
```

then `kubectl get db` can work after the API Server advertises the resource through discovery.

## Hands-on Examples

These commands only inspect the API. They do not create workloads.

### Inspect root API paths

```bash
kubectl get --raw /
```

Expected concept:

```text
The API Server returns available root paths such as /api, /apis, /version, and /openapi.
```

### Inspect the Core API Group

```bash
kubectl get --raw /api | jq
```

Without `jq`:

```bash
kubectl get --raw /api
```

Expected concept:

```text
The response lists versions for the Core API Group, commonly v1.
```

### Inspect named API Groups

```bash
kubectl get --raw /apis | jq
```

Expected concept:

```text
The response lists named API Groups such as apps, batch, networking.k8s.io, storage.k8s.io, and rbac.authorization.k8s.io.
```

### Inspect one API Group

```bash
kubectl get --raw /apis/apps | jq
```

Expected concept:

```text
The response shows the apps API Group, supported versions, and preferredVersion.
```

### Inspect resources in one group/version

```bash
kubectl get --raw /apis/apps/v1 | jq
```

Expected concept:

```text
The response lists resources in apps/v1 such as deployments, replicasets, daemonsets, and statefulsets.
```

### Inspect batch resources

```bash
kubectl get --raw /apis/batch | jq
kubectl get --raw /apis/batch/v1 | jq
```

Expected concept:

```text
/apis/batch shows group versions.
/apis/batch/v1 shows resources such as jobs and cronjobs.
```

### Inspect Core API resources

```bash
kubectl get --raw /api/v1 | jq
```

Look for fields like:

```text
name
kind
namespaced
verbs
shortNames
```

Example concept:

```json
{
  "name": "pods",
  "namespaced": true,
  "kind": "Pod",
  "verbs": ["create", "delete", "get", "list", "patch", "update", "watch"],
  "shortNames": ["po"]
}
```

## Best Practices

- Understand Kubernetes through API resources, not only through commands.
- Use `kubectl get --raw` when learning how kubectl maps commands to API paths.
- Remember that API Server stores object state; controllers perform reconciliation.
- Use API Groups to reason about where a resource belongs.
- Use Discovery API output to understand CRDs and unfamiliar resources.
- Avoid assuming `kubectl` hardcodes resource mappings; most resource metadata comes from API discovery.

## Common Mistakes

### Mistake 1: Thinking kubectl talks directly to nodes

Wrong model:

```text
kubectl → kubelet → container
```

Correct model:

```text
kubectl → API Server → object state → kubelet watch → container runtime
```

### Mistake 2: Thinking the API Server creates containers

The API Server validates and stores objects. It does not run containers.

### Mistake 3: Thinking a Deployment directly creates Pods

The Deployment Controller manages ReplicaSets. The ReplicaSet Controller manages Pods.

### Mistake 4: Thinking deletion is instant removal from etcd

Deletion usually starts by setting `metadata.deletionTimestamp`. The object may remain while cleanup happens.

### Mistake 5: Confusing API Group and API Version

`apps/v1` means:

```text
Group   = apps
Version = v1
```

It does not mean the Deployment object itself is version 1.

### Mistake 6: Using the wrong discovery path

Correct:

```http
GET /apis/batch
GET /apis/batch/v1
```

Wrong:

```http
GET /apis/batch
GET /apis/apps/v1
```

The group name must stay consistent.

## Troubleshooting

### Check whether a resource exists

```bash
kubectl api-resources | grep -i <name>
```

Or inspect discovery directly:

```bash
kubectl get --raw /apis | jq
kubectl get --raw /apis/<group>/<version> | jq
```

### Check whether a resource is namespaced

```bash
kubectl api-resources | grep <resource>
```

Or inspect raw discovery and check:

```text
namespaced: true|false
```

This matters because namespaced resources use paths like:

```http
/apis/apps/v1/namespaces/default/deployments
```

Cluster-scoped resources use paths like:

```http
/api/v1/nodes
```

### Check supported verbs

Raw discovery shows resource verbs:

```text
get
list
watch
create
update
patch
delete
```

This helps explain why some resources cannot be created, updated, or deleted in the same way as normal objects.

### Check short names

```bash
kubectl get --raw /api/v1 | jq '.resources[] | select(.name=="pods")'
```

Look for:

```text
shortNames
```

This explains why commands like these work:

```bash
kubectl get po
kubectl get svc
kubectl get deploy
```

## Interview Notes

- Kubernetes is API-driven and declarative.
- The API Server is the only component that talks directly to etcd.
- Controllers are independent API clients that watch resources and reconcile state.
- The Scheduler watches unscheduled Pods and patches `spec.nodeName`.
- The kubelet watches Pods assigned to its node and starts containers locally.
- API Groups organize related resources and allow independent versioning.
- The Core API Group has an empty group name and uses `apiVersion: v1`.
- Named API Groups use values like `apps/v1`, `batch/v1`, and `networking.k8s.io/v1`.
- `kubectl` uses the Discovery API to learn available groups, versions, resources, verbs, namespaced scope, and short names.
- `kubectl explain` relies on schema information, which will be studied in the OpenAPI schema topic.

## CKA Tips

Useful commands:

```bash
kubectl api-resources
kubectl api-versions
kubectl explain pod
kubectl explain deployment.spec.template.spec.containers
kubectl get --raw /api
kubectl get --raw /apis
kubectl get --raw /apis/apps/v1
```

For the exam, `kubectl api-resources` is useful for quickly checking:

- exact resource names
- short names
- API groups
- whether a resource is namespaced
- supported verbs

Examples:

```bash
kubectl api-resources | grep -i deployment
kubectl api-resources --namespaced=true
kubectl api-resources --namespaced=false
kubectl api-resources --api-group=apps
```

## References

- Kubernetes Official Documentation — API Overview
- Kubernetes Official Documentation — API Concepts
- Kubernetes Official Documentation — Kubernetes API Reference
- Kubernetes Official Documentation — Custom Resources
- Kubernetes Official Documentation — kubectl Cheat Sheet
