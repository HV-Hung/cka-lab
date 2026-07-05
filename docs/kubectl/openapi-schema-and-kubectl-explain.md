# OpenAPI Schema and kubectl explain

## Overview

Kubernetes is a self-describing API system.

The API Server exposes two important kinds of metadata:

```text
Discovery API
  answers: what resources exist?

OpenAPI schema
  answers: what does each resource look like?
```

`kubectl explain` uses the OpenAPI schema published by the API Server to show fields, nested structure, types, and descriptions for Kubernetes resources.

The goal is not to memorize YAML. The goal is to understand the Kubernetes object model.

---

## Core Mental Model

```text
kubectl
  ↓
Discovery API
  ↓
resolve resource: group, version, name, scope, verbs
  ↓
OpenAPI schema
  ↓
resolve fields: nesting, types, descriptions, validation hints
```

Summary:

```text
Discovery = resource catalog
OpenAPI  = object blueprint
Objects  = actual desired state
```

Example:

```text
Discovery tells kubectl:
- deployments exists
- group = apps
- version = v1
- namespaced = true
- supported verbs include get, list, create, patch, update, delete, watch

OpenAPI tells kubectl:
- Deployment has metadata
- Deployment has spec
- spec has replicas, selector, and template
- template has a Pod spec
- containers is a list
- container.image is a string
```

---

## Why OpenAPI Exists

Without server-published schemas, every client would need to hardcode Kubernetes API structures.

That would affect:

- `kubectl`
- client-go
- Terraform Kubernetes provider
- Argo CD
- Lens
- IDE plugins
- custom clients

Problem:

```text
API changes
  ↓
every client must update its own schema knowledge
  ↓
version drift and maintenance cost
```

Kubernetes avoids this by making the API Server publish schemas.

Design principle:

```text
The server describes itself.
```

Benefits:

- clients learn schemas from the server
- tools can generate documentation
- IDEs can provide YAML assistance
- validation can use the same API contract
- CRDs can expose their own schemas
- clients do not need built-in knowledge of every resource

---

## OpenAPI and CRDs

CustomResourceDefinitions extend Kubernetes without modifying API Server source code.

A CRD defines both the resource identity and its schema:

```text
group
version
kind
plural name
scope
schema
```

Simplified CRD schema example:

```yaml
spec:
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              engine:
                type: string
              storage:
                type: integer
```

After the CRD is accepted:

```text
API Server
  ↓
registers the new resource
  ↓
publishes it through Discovery API
  ↓
publishes its structure through OpenAPI schema
```

That is why this can work without updating the `kubectl` binary:

```bash
kubectl explain database.spec
```

Important separation:

```text
API Server
  defines API availability, schema, validation, and persistence

Controller
  watches objects, reconciles actual state, and updates status
```

The controller implements behavior. It does not define the API schema.

---

## Validation Responsibility

The API Server validates objects before storing them.

Example schema:

```yaml
storage:
  type: integer
```

Invalid object:

```yaml
storage: "100"
```

The value is a string, not an integer. The API Server should reject it before persistence.

Request flow:

```text
request
  ↓
API Server
  ↓
authentication
  ↓
authorization
  ↓
admission
  ↓
schema validation
  ↓
etcd persistence
```

Why not `kubectl`?

Because not every client is `kubectl`. Objects may come from Helm, Argo CD, Terraform, client libraries, controllers, or direct REST calls.

Why not the controller?

Because the controller sees objects after they have already been accepted and stored. Invalid data should not enter cluster state.

---

## What kubectl explain Does

`kubectl explain` is an interactive API reference for the live cluster.

Mental model:

```text
kubectl explain
  ↓
uses API metadata from the API Server
  ↓
walks the OpenAPI schema tree
  ↓
renders field documentation for humans
```

It helps answer:

```text
What fields does this resource support?
Where is this field located?
What type is this field?
What does this field mean?
```

It is useful because:

- the schema matches the cluster version
- CRDs can be explained
- internet access is not required
- YAML nesting mistakes are easier to avoid
- it is allowed and useful during the CKA exam

---

## Schema Traversal

`kubectl explain` walks a field path through the schema tree.

Example:

```text
Deployment.spec.template.spec.containers
```

Traversal:

```text
Deployment
  ↓
spec
  ↓
template
  ↓
spec
  ↓
containers
```

This path reflects real Kubernetes API composition:

```text
Deployment
  ↓
DeploymentSpec
  ↓
PodTemplateSpec
  ↓
PodSpec
  ↓
Container
```

Every dot means one level deeper in the object schema.

---

## Why Deployment Uses spec.template.spec.containers

A Deployment does not own containers directly.

Runtime ownership chain:

```text
Deployment
  ↓
ReplicaSet
  ↓
Pod
  ↓
Container
```

Deployment separates two concerns:

```text
spec.replicas
  = how many Pods should exist

spec.template
  = what each future Pod should look like
```

The template is a Pod blueprint, not a real Pod object.

This is why the field is called `template`, not `pod`.

If the API used this shape:

```yaml
spec:
  pod:
    spec:
      containers:
```

it would imply that the Deployment owns one specific Pod.

The real structure is:

```yaml
spec:
  replicas: 3
  template:
    spec:
      containers:
```

Changing `replicas` scales the workload without changing the Pod blueprint.

Changing `template` creates a new Pod blueprint and drives rollout behavior through ReplicaSets.

Kubernetes reuses existing object structures instead of duplicating Pod fields directly under Deployment:

```text
DeploymentSpec
  contains PodTemplateSpec
    contains PodSpec
```

This is composition over duplication.

---

## Key Takeaways

- Discovery tells clients what resources exist.
- OpenAPI tells clients what fields those resources contain.
- Objects store actual desired state.
- `kubectl explain` reads schema information from the API Server.
- CRDs provide their schema inside the CRD object.
- API Server validates objects before storing them.
- Controllers reconcile behavior; they do not define schemas.
- `kubectl explain` is best understood as schema-tree traversal.
- `Deployment.spec.template` is a blueprint for future Pods.

---

## Common Mistakes

### Thinking kubectl explain reads the Kubernetes website

Wrong:

```text
kubectl explain → Kubernetes documentation website
```

Correct:

```text
kubectl explain → API Server metadata → OpenAPI schema
```

### Confusing Discovery and OpenAPI

```text
Discovery: what resources exist?
OpenAPI: what does each resource look like?
```

### Thinking the controller defines the schema

The schema comes from built-in API definitions or from the CRD object. The controller reconciles accepted objects.

### Thinking Deployment directly owns containers

Deployment owns ReplicaSets. ReplicaSets own Pods. Pods own containers.

Deployment only contains a Pod template.

### Thinking template means current Pods

The template is a blueprint for future Pods. Existing Pods do not mutate just because the template changes.

---

## Current Learning Status

Status: **In progress**

Completed:

- OpenAPI purpose
- Discovery API vs OpenAPI schema
- API Server as schema source of truth
- CRD schema registration model
- API Server validation responsibility
- `kubectl explain` mental model
- schema traversal
- why Deployment uses `spec.template.spec.containers`
- why `template` is not called `pod`

Pending:

- practical `kubectl explain` usage
- `--recursive`
- field navigation exercises
- CRD explain behavior
- hands-on lab
- intentional breakage
- troubleshooting
- final cheat sheet

---

## CKA Tips

- Use `kubectl explain` when you forget where a field belongs.
- Think in field paths, not copied YAML snippets.
- For workload controllers, container fields usually live under `spec.template.spec.containers`.
- Use `kubectl explain` to avoid indentation and nesting mistakes.
- Learn the object model so `kubectl explain` becomes a confirmation tool, not your only source of knowledge.

---

## References

- Kubernetes API concepts
- Kubernetes kubectl explain reference
- Kubernetes CustomResourceDefinition documentation
