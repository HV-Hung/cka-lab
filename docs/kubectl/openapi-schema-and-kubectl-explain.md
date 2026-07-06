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

`kubectl explain` uses schema information published by the API Server to show fields, nested structure, types, and descriptions for Kubernetes resources.

The goal is not to memorize YAML. The goal is to understand the Kubernetes object model and use `kubectl explain` to confirm exact field paths.

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

## How kubectl explain Resolves Resources

When running:

```bash
kubectl explain deploy.spec.template.spec.containers
```

`kubectl` first needs to resolve `deploy`.

It uses Discovery API metadata to understand that:

```text
deploy
  ↓
deployments
  ↓
deployments.apps
  ↓
apps/v1 Deployment
```

After the resource is resolved, `kubectl` uses the OpenAPI schema to walk the field path:

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

Resource aliases usually resolve to the same resource:

```bash
kubectl explain deploy
kubectl explain deployment
kubectl explain deployments
kubectl explain deployments.apps
```

For learning and exam usage, prefer clear paths:

```bash
kubectl explain deployment.spec.template.spec.containers
```

---

## Field Path Navigation

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

Practical workflow:

```bash
kubectl explain deployment
kubectl explain deployment.spec
kubectl explain deployment.spec.template
kubectl explain deployment.spec.template.spec
kubectl explain deployment.spec.template.spec.containers
kubectl explain deployment.spec.template.spec.containers.image
```

This avoids guessing YAML nesting.

Example mistake:

```bash
kubectl explain deployment.spec.restartPolicy
```

`restartPolicy` does not belong directly to `DeploymentSpec`.

Correct path:

```bash
kubectl explain deployment.spec.template.spec.restartPolicy
```

Reason:

```text
Deployment
└── spec                  # DeploymentSpec
    └── template          # PodTemplateSpec
        └── spec          # PodSpec
            └── restartPolicy
```

---

## Why kubectl explain Preserves the Tree

`kubectl explain` does not flatten all fields into one list because Kubernetes objects are not flat.

The hierarchy reflects the actual API model:

```text
Container
  belongs inside PodSpec

PodSpec
  belongs inside PodTemplateSpec

PodTemplateSpec
  belongs inside workload controllers such as Deployment, DaemonSet, StatefulSet, Job, and ReplicaSet
```

Preserving the tree has two benefits:

```text
Accuracy
  The CLI output mirrors the real API structure.

Usability
  Users can inspect one field path instead of reading the whole schema.
```

This is why paths such as this are meaningful:

```text
Deployment.spec.template.spec.containers
```

They are not just YAML syntax. They represent nested API types.

---

## Why kubectl explain Resolves One Level at a Time

`kubectl explain` does not search the entire schema for a field name and print the first match.

It resolves the path one level at a time:

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
  ↓
resources
  ↓
limits
```

This is important because many field names are reused across Kubernetes APIs.

Examples:

```text
metadata.name
metadata.labels
spec.selector
spec.template
status.conditions
```

A field name only has meaning inside its parent object.

For example, `selector` may exist in different resources with different meanings:

```text
Service.spec.selector
Deployment.spec.selector
NetworkPolicy.spec.podSelector
PodDisruptionBudget.spec.selector
```

Searching globally for `selector` would be ambiguous.

Path-based traversal is correct because Kubernetes APIs are hierarchical and composed from nested types.

---

## API Composition

Kubernetes reuses common API structures instead of duplicating fields in every resource.

Conceptual model:

```text
DeploymentSpec
  contains PodTemplateSpec
    contains PodSpec
      contains []Container
```

Many workload resources eventually contain a Pod template:

```text
Deployment
  ↓
PodTemplateSpec

DaemonSet
  ↓
PodTemplateSpec

StatefulSet
  ↓
PodTemplateSpec

Job
  ↓
PodTemplateSpec

CronJob
  ↓
JobTemplateSpec
  ↓
PodTemplateSpec
```

This keeps the API consistent.

If Kubernetes adds or improves a field in `PodSpec`, workload resources that embed `PodSpec` can reuse the same model instead of redefining Pod fields repeatedly.

Design principle:

```text
composition over duplication
```

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

---

## --recursive

By default, `kubectl explain` shows the current node and its direct child fields.

Example:

```bash
kubectl explain pod.spec
```

With `--recursive`, it prints the nested field tree below the selected path:

```bash
kubectl explain pod.spec --recursive
```

Mental model:

```text
without --recursive
  show this node and direct children

with --recursive
  show this node and all nested descendants
```

Useful examples:

```bash
kubectl explain pod.spec --recursive | less
kubectl explain deployment.spec.template.spec --recursive | less
kubectl explain service.spec --recursive | less
```

Use `--recursive` when:

- exploring a resource for the first time
- looking for a field when the exact path is unknown
- building mental memory of object structure

Avoid overusing `--recursive` when:

- solving a timed CKA task
- the output becomes too large
- the exact field path is already known
- detailed descriptions are needed, because recursive output is less readable

Best exam habit:

```text
Use --recursive to discover possible field names.
Then use direct field paths to inspect details.
```

---

## kubectl explain vs kubectl api-resources

These commands answer different questions.

`kubectl api-resources` answers:

```text
What API resources exist in this cluster?
```

It shows resource-level metadata:

```text
NAME          SHORTNAMES   APIVERSION   NAMESPACED   KIND
deployments   deploy       apps/v1      true         Deployment
pods          po           v1           true         Pod
```

It does not explain fields inside the resource.

`kubectl explain` answers:

```text
What fields exist inside this resource?
Where does this field belong?
What does this field mean?
```

Example:

```bash
kubectl explain deployment.spec.template.spec.containers.resources.limits
```

Summary:

```text
kubectl api-resources = resource discovery
kubectl explain       = schema navigation
```

Practical rule:

```text
Use api-resources when you do not know the resource name, API group, short name, or scope.
Use explain when you know the resource and need to write correct YAML.
```

---

## CRD Behavior with kubectl explain

`kubectl explain` can work with CRDs because Kubernetes publishes CRD schemas through the API Server.

Good CRD schema:

```yaml
spec:
  versions:
  - name: v1
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              replicas:
                type: integer
              image:
                type: string
              storage:
                type: integer
```

This allows useful commands such as:

```bash
kubectl explain myresource.spec.image
kubectl explain myresource.spec.replicas
```

Weak CRD schema:

```yaml
spec:
  type: object
```

or schemas that preserve unknown fields too broadly may give poor `kubectl explain` output.

Important point:

```text
If kubectl explain shows little useful detail for a CRD,
the problem is usually the CRD schema,
not the controller logic.
```

The controller implements behavior. The CRD schema defines the API structure that `kubectl explain` can display.

---

## Best Practices

- Use `kubectl explain` to confirm exact field paths instead of guessing YAML indentation.
- Start broad, then navigate deeper.
- Think in object paths, not isolated field names.
- Use `kubectl api-resources` when resource identity is unclear.
- Use `kubectl explain` when field structure is unclear.
- Use `--recursive` for exploration, then inspect specific paths directly.
- For workload controllers, remember that container fields usually live under `spec.template.spec.containers`.
- For CRDs, expect `kubectl explain` quality to depend on CRD schema quality.

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

### Thinking kubectl explain searches every field globally

Wrong:

```text
Find any field named limits anywhere in the schema.
```

Correct:

```text
Resolve one path level at a time:
Deployment → spec → template → spec → containers → resources → limits
```

### Thinking the controller defines the schema

The schema comes from built-in API definitions or from the CRD object. The controller reconciles accepted objects.

### Thinking kubectl explain invents documentation

`kubectl explain` renders schema information from the API Server. It does not create its own separate resource model.

### Thinking Deployment directly owns containers

Deployment owns ReplicaSets. ReplicaSets own Pods. Pods own containers.

Deployment only contains a Pod template.

### Thinking template means current Pods

The template is a blueprint for future Pods. Existing Pods do not mutate just because the template changes.

---

## CKA Tips

Use `kubectl explain` when you forget where a field belongs.

High-value examples:

```bash
kubectl explain pod.spec.containers
kubectl explain pod.spec.containers.resources
kubectl explain pod.spec.containers.livenessProbe
kubectl explain deployment.spec.strategy
kubectl explain deployment.spec.template.spec.nodeSelector
kubectl explain service.spec
kubectl explain persistentvolumeclaim.spec
```

Memorize the main object model, not every field.

Important paths:

```text
Deployment
  spec
    replicas
    selector
    template
      metadata
      spec
        containers

Pod
  spec
    containers
    volumes
    nodeSelector
    tolerations
    affinity

Service
  spec
    selector
    ports
    type
```

Exam habit:

```text
1. Use api-resources if the resource name or API group is unclear.
2. Use explain to find the correct field path.
3. Write the YAML.
4. Use kubectl apply --dry-run=server or kubectl apply to validate with the API Server.
```

---

## Key Takeaways

- Discovery tells clients what resources exist.
- OpenAPI tells clients what fields those resources contain.
- Objects store actual desired state.
- `kubectl explain` reads schema information from the API Server.
- `kubectl explain` first resolves the resource, then walks the field path.
- Field paths are hierarchical because Kubernetes API objects are hierarchical.
- CRDs provide their schema inside the CRD object.
- API Server validates objects before storing them.
- Controllers reconcile behavior; they do not define schemas.
- `kubectl explain` is best understood as schema-tree traversal.
- The schema tree is preserved because it mirrors real API composition.
- `Deployment.spec.template` is a blueprint for future Pods.
- `--recursive` is useful for exploration but can be noisy.
- `api-resources` and `explain` solve different problems.

---

## Current Learning Status

Status: **Concept complete; hands-on pending**

Completed:

- OpenAPI purpose
- Discovery API vs OpenAPI schema
- API Server as schema source of truth
- CRD schema registration model
- API Server validation responsibility
- `kubectl explain` mental model
- resource resolution
- schema traversal
- practical field path navigation
- why `kubectl explain` preserves the schema tree
- why `kubectl explain` resolves one level at a time
- API composition
- why Deployment uses `spec.template.spec.containers`
- why `template` is not called `pod`
- `--recursive` concept and usage
- difference between `kubectl explain` and `kubectl api-resources`
- CRD explain behavior
- CKA usage best practices

Pending:

- hands-on field navigation exercises
- hands-on `--recursive` exercises
- hands-on CRD explain behavior
- intentional breakage
- troubleshooting
- final cheat sheet

---

## References

- Kubernetes API concepts
- Kubernetes kubectl explain reference
- Kubernetes CustomResourceDefinition documentation
