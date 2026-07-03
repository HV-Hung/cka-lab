# kubectl

`kubectl` is the primary command-line client for interacting with the Kubernetes API Server.

It is not part of the Kubernetes control plane. It is a client application that reads local configuration, builds API requests, sends them to the API Server, and formats the API response for humans.

## Learning Status

| Area | Status |
| --- | --- |
| kubectl architecture | Completed |
| kubeconfig concepts | Completed |
| TLS, PKI, and authentication basics | Completed |
| API resources and discovery | Not started |
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

## Next Topics

1. Kubernetes API resources and API groups
2. `kubectl api-resources`
3. `kubectl explain`
4. Imperative resource creation
5. Output formatting for the CKA exam
