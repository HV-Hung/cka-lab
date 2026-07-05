# OpenAPI Schema and kubectl explain

## Overview

Kubernetes is a self-describing API system.

The API Server does not only store Kubernetes objects. It also exposes metadata that helps clients understand what the cluster supports and how API objects are structured.

The previous topic covered the Discovery API:

```text
Discovery API answers:
What API resources exist?
```

This topic adds the next layer:

```text
OpenAPI schema answers:
What does each resource look like?
```

`kubectl explain` uses the OpenAPI schema exposed by the API Server to show resource fields, nested structures, field types, and descriptions.

The goal is not to memorize YAML. The goal is to understand how Kubernetes objects are modeled.

---

## Mental Model

```text
kubectl
  ↓
API Discovery
  ↓
learn groups, versions, resources, verbs, scope, shortNames
  ↓
OpenAPI schema
  ↓
learn fields, types, nesting, descriptions, validation hints
```

Discovery and OpenAPI solve different problems.

```text
Discovery API
  = resource catalog

OpenAPI schema
  = object blueprint
```

Example:

```text
Discovery API tells kubectl:
- deployments exists
- group = apps
- version = v1
- namespaced = true
- verbs = get, list, create, update, patch, delete, watch

OpenAPI schema tells kubectl:
- Deployment has metadata
- Deployment has spec
- spec has replicas
- spec has selector
- spec has template
- template has pod spec
- containers is a list
- container.image is a string
```

---

## Discovery API vs OpenAPI Schema vs Objects

These are three separate concepts.

```text
Discovery API
  tells what API resources exist

OpenAPI schema
  tells what fields those resources support

Kubernetes objects
  represent the current desired state stored through the API Server
```

Example:

```text
GET /apis/apps/v1
```

This tells the client that `deployments` exists in `apps/v1`.

OpenAPI tells the client that a Deployment contains fields such as:

```text
Deployment.spec.replicas
Deployment.spec.selector
Deployment.spec.template
Deployment.spec.template.spec.containers
```

A real object stores actual desired state:

```text
Deployment named nginx
replicas = 3
image = nginx:1.27
```

A useful summary:

```text
Discovery = catalog
OpenAPI  = blueprint
Objects  = actual records
```

---

## Why Kubernetes Uses OpenAPI

Kubernetes could have been designed in several ways.

### Option A: Hardcode all schemas in every client

In this design, every client would need built-in knowledge of every Kubernetes field.

```text
kubectl
client-go
Terraform Kubernetes provider
Argo CD
Lens
IDE plugins
custom clients
```

Problem:

```text
API changes
  ↓
every client must update its own schema knowledge
```

This causes version drift and makes the ecosystem harder to maintain.

### Option B: Invent a Kubernetes-specific schema format

Kubernetes could have created a custom schema system.

Problem:

```text
New Kubernetes-specific schema format
  ↓
new parsers
new generators
new documentation tools
new IDE support
new validation libraries
```

That would create unnecessary ecosystem cost.

### Option C: Publish OpenAPI schema from the API Server

Kubernetes chose a standard API description format.

Benefits:

- clients can learn schemas from the server
- tools can generate documentation
- clients can be generated from API definitions
- IDEs and YAML tooling can use schema information
- CRDs can expose their own schemas
- the API Server remains the source of truth

The design principle is:

```text
The server describes itself.
```

Clients should discover capabilities and schemas from the API Server instead of embedding assumptions.

---

## Why OpenAPI Matters for CRDs

CustomResourceDefinitions extend Kubernetes without modifying the API Server source code.

When a CRD is installed, the API Server reads the CRD object and registers a new API resource.

A CRD defines:

```text
group
versions
kind
plural name
scope
schema
```

The schema is provided inside the CRD itself:

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

After the CRD is accepted, the API Server updates:

```text
Discovery API
  adds the new resource

OpenAPI schema
  adds the new resource schema
```

Then a command such as this can work without updating the `kubectl` binary:

```bash
kubectl explain database.spec
```

Conceptual flow:

```text
Install CRD
  ↓
API Server reads CRD schema
  ↓
API Server publishes resource through Discovery API
  ↓
API Server publishes structure through OpenAPI schema
  ↓
kubectl can get, apply, and explain the custom resource
```

Important separation:

```text
API Server
  registers API, validates objects, stores objects, publishes schema

Controller
  watches objects, interprets desired state, reconciles actual state, updates status
```

The controller is responsible for behavior, not API definition.

---

## Validation Responsibility

The API Server is responsible for enforcing the API contract before objects are persisted.

Example CRD schema:

```yaml
spec:
  storage:
    type: integer
```

Invalid object:

```yaml
spec:
  storage: "100"
```

The value is a string, not an integer.

The API Server should reject this object because validation must happen before persistence.

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

Because not every client is `kubectl`.

Objects may be created by:

- kubectl
- Helm
- Argo CD
- Terraform
- client-go
- Python clients
- Java clients
- controllers
- direct REST calls

The server must never trust the client.

Why not the controller?

Because by the time the controller sees the object, the object has already been persisted and may already have been observed by other components.

Invalid data should not enter cluster state.

---

## What kubectl explain Does

`kubectl explain` is not just a help command.

A better mental model is:

```text
kubectl explain
  ↓
uses API metadata from the API Server
  ↓
walks the OpenAPI schema tree
  ↓
renders field documentation for humans
```

It is an interactive API reference for the live cluster.

Instead of searching online for YAML examples, the user can ask the cluster itself:

```text
What fields does this resource support?
Where is this field located?
What is the type of this field?
What does this field mean?
```

This is especially useful because:

- the schema matches the cluster version
- CRDs can be explained
- internet access is not required
- it helps avoid YAML nesting mistakes
- it is useful during the CKA exam

---

## Schema Traversal Mental Model

`kubectl explain` walks a schema tree.

Example path:

```text
Deployment.spec.template.spec.containers
```

This path means:

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

Every dot means one level deeper in the object schema.

The path is not random. It reflects real Kubernetes API object composition.

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

---

## Why Deployment Uses spec.template.spec.containers

A Deployment does not own containers directly.

The runtime ownership chain is:

```text
Deployment
  ↓
ReplicaSet
  ↓
Pod
  ↓
Container
```

The API schema reflects that separation.

A Deployment contains:

```text
spec.replicas
  = how many Pods should exist

spec.template
  = what each future Pod should look like
```

A Deployment does not describe one Pod. It describes a desired set of replaceable Pods created from a template.

That is why the field is called `template`, not `pod`.

If the API were designed like this:

```yaml
spec:
  pod:
    spec:
      containers:
```

it would misleadingly suggest that the Deployment owns one specific Pod.

The real design is:

```yaml
spec:
  replicas: 3
  template:
    spec:
      containers:
```

This separates two concerns:

```text
replicas
  = number of desired Pods

template
  = blueprint used to create each Pod
```

Changing `replicas` scales the workload without changing the Pod template.

Changing `template` creates a new desired Pod blueprint, which drives rollout behavior through ReplicaSets.

---

## Why Kubernetes Uses a Template

A Pod has many fields:

- containers
- initContainers
- volumes
- affinity
- tolerations
- nodeSelector
- securityContext
- serviceAccountName
- imagePullSecrets
- DNS policy
- restart policy

If Deployment copied all Pod fields directly into `Deployment.spec`, the API would duplicate the Pod schema.

Instead, Kubernetes composes existing object structures:

```text
DeploymentSpec
  contains PodTemplateSpec
    contains PodSpec
```

This follows a common software engineering principle:

```text
composition over duplication
```

The long YAML path exists because Kubernetes is reusing the Pod object model inside workload controllers.

---

## Key Takeaways

- Discovery API tells clients what resources exist.
- OpenAPI schema tells clients what fields those resources contain.
- Kubernetes objects represent actual desired state.
- `kubectl explain` uses OpenAPI schema from the API Server.
- The API Server is the source of truth for resource schemas.
- CRDs provide their schema inside the CRD object.
- Controllers implement behavior; they do not define API schemas.
- The API Server validates objects before storing them.
- `kubectl explain` should be understood as schema-tree traversal.
- `Deployment.spec.template` is a Pod blueprint, not a real Pod object.
- `replicas` answers how many Pods are desired.
- `template` answers what each Pod should look like.

---

## Common Mistakes

### Mistake 1: Thinking kubectl explain reads the Kubernetes website

Wrong model:

```text
kubectl explain
  ↓
Kubernetes documentation website
```

Correct model:

```text
kubectl explain
  ↓
API Server metadata
  ↓
OpenAPI schema
```

### Mistake 2: Confusing Discovery and OpenAPI

Discovery does not explain fields.

Discovery tells clients that a resource exists.

OpenAPI explains the structure of that resource.

### Mistake 3: Thinking the controller defines the schema

The controller reconciles objects after they are accepted.

The schema comes from built-in API definitions or from the CRD object.

### Mistake 4: Thinking Deployment directly owns containers

A Deployment owns ReplicaSets.

ReplicaSets own Pods.

Pods own containers.

Deployment only contains a Pod template.

### Mistake 5: Thinking template means current Pods

The template is a blueprint for future Pods.

Existing Pods do not mutate just because the template changes. New Pods are created from the new template during rollout.

---

## Current Learning Status

This topic is partially completed.

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

Still pending:

- practical `kubectl explain` command usage
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
- For workload controllers, remember that container fields usually live under `spec.template.spec.containers`.
- Use `kubectl explain` to avoid indentation and nesting mistakes.
- Learn the object model deeply enough that `kubectl explain` becomes a confirmation tool, not your only source of knowledge.

---

## References

- Kubernetes API concepts
- Kubernetes kubectl explain reference
- Kubernetes CustomResourceDefinition documentation
