# kubectl

`kubectl` is the primary command-line client for interacting with the Kubernetes API Server.

It is not part of the Kubernetes control plane. It is a client application that reads local configuration, builds API requests, sends them to the API Server, and formats the API response for humans.

## Learning Status

| Area | Status |
| --- | --- |
| kubectl architecture | Completed |
| kubeconfig concepts | Completed |
| TLS, PKI, and authentication basics | Completed |
| API resources and discovery | Completed |
| OpenAPI schema and kubectl explain | Concept and hands-on completed; breakage/troubleshooting pending |
| Imperative commands | Not started |
| Output formatting | Not started |
| Labels and annotations | Not started |
| Edit, apply, and patch | Not started |
| Debugging with kubectl | Not started |
| CKA shortcuts | Not started |

## Documents

- [Architecture](./architecture.md)
- [Kubeconfig](./kubeconfig.md)
- [TLS, PKI, and Authentication](./tls-pki-authentication.md)
- [API Resources and Discovery](./api-resources-and-discovery.md)
- [OpenAPI Schema and kubectl explain](./openapi-schema-and-kubectl-explain.md)

> Note: Some linked documents may still need to be created as the learning notes are polished topic by topic.

## Core Mental Model

```text
kubectl
  ↓
read kubeconfig
  ↓
select current context
  ↓
resolve cluster + user + namespace
  ↓
connect to API Server over HTTPS
  ↓
authenticate
  ↓
authorize with RBAC
  ↓
discover API groups, versions, and resources
  ↓
read OpenAPI schema when field-level structure is needed
  ↓
API Server reads or updates cluster state
  ↓
kubectl formats the response
```

## Key Takeaways

- `kubectl` talks only to the Kubernetes API Server.
- `kubectl` does not talk directly to Pods, Nodes, kubelet, controllers, scheduler, or etcd.
- The API Server is the single entry point for Kubernetes control-plane access.
- Kubeconfig controls which cluster, user, and namespace `kubectl` uses.
- The cluster CA certificate verifies the API Server TLS certificate.
- The user section authenticates the caller using a client certificate, token, or dynamic credential plugin.
- Authentication answers: who are you?
- Authorization answers: what are you allowed to do?
- Kubernetes exposes cluster state through API resources.
- API Groups organize related resources and allow independent versioning.
- The Core API Group uses `apiVersion: v1`; named groups use values such as `apps/v1` and `batch/v1`.
- `kubectl` uses the Discovery API to learn available groups, versions, resources, verbs, scope, and short names.
- `kubectl explain` uses OpenAPI schema from the API Server to understand resource fields and nested object structure.
- Discovery answers what resources exist; OpenAPI answers what those resources look like.
- Practical `kubectl explain` field navigation has been completed on the AKS cluster.
- The next step is intentional breakage and troubleshooting using wrong field paths, wrong types, and schema validation.

## Next Topics

1. Intentionally break `kubectl explain` field paths
2. Troubleshoot wrong YAML nesting using `kubectl explain`
3. Compare client-side understanding with API Server validation
4. Explore `kubectl explain` behavior for CRDs
5. Final `kubectl explain` cheat sheet
