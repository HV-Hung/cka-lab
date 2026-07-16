# Topic Map

This file maps topic keywords to their CKA domain, directory path, primary Kubernetes resource, and official documentation URL.

Use this to resolve the user's request to the correct lab directory.

## Matching Rules

1. Match against the **Aliases** column (case-insensitive).
2. If multiple matches are found, ask the user to clarify.
3. The **Path** column is relative to the repository root.
4. Use the **Docs URL** during Phase 1 to fetch authoritative content via `read_url_content`.
5. Use the **Resource** column during Phase 1 to run `kubectl explain <resource> --recursive`.

---

## Workloads

| Topic | Aliases | Path | Resource | Docs URL |
|---|---|---|---|---|
| Pods | pod, pods | `labs/workloads/pods/` | `pod` | https://kubernetes.io/docs/concepts/workloads/pods/ |
| ReplicaSets | replicaset, replicasets, rs | `labs/workloads/replicasets/` | `replicaset` | https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/ |
| Deployments | deployment, deployments, deploy | `labs/workloads/deployments/` | `deployment` | https://kubernetes.io/docs/concepts/workloads/controllers/deployment/ |
| DaemonSets | daemonset, daemonsets, ds | `labs/workloads/daemonsets/` | `daemonset` | https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/ |
| StatefulSets | statefulset, statefulsets, sts | `labs/workloads/statefulsets/` | `statefulset` | https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/ |
| Jobs | job, jobs | `labs/workloads/jobs/` | `job` | https://kubernetes.io/docs/concepts/workloads/controllers/job/ |
| CronJobs | cronjob, cronjobs, cj | `labs/workloads/cronjobs/` | `cronjob` | https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/ |

## Networking

| Topic | Aliases | Path | Resource | Docs URL |
|---|---|---|---|---|
| Services | service, services, svc | `labs/networking/services/` | `service` | https://kubernetes.io/docs/concepts/services-networking/service/ |
| DNS | dns, coredns, kube-dns | `labs/networking/dns/` | `service` | https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/ |
| Ingress | ingress, ing | `labs/networking/ingress/` | `ingress` | https://kubernetes.io/docs/concepts/services-networking/ingress/ |
| Gateway API | gateway, gateway-api, gatewayclass, httproute | `labs/networking/gateway-api/` | `gateway` | https://kubernetes.io/docs/concepts/services-networking/gateway/ |
| Network Policies | networkpolicy, networkpolicies, netpol | `labs/networking/network-policies/` | `networkpolicy` | https://kubernetes.io/docs/concepts/services-networking/network-policies/ |

## Storage

| Topic | Aliases | Path | Resource | Docs URL |
|---|---|---|---|---|
| Volumes | volume, volumes, vol, emptydir, hostpath | `labs/storage/volumes/` | `pod.spec.volumes` | https://kubernetes.io/docs/concepts/storage/volumes/ |
| Persistent Volumes | persistentvolume, pv | `labs/storage/persistent-volumes/` | `persistentvolume` | https://kubernetes.io/docs/concepts/storage/persistent-volumes/ |
| Persistent Volume Claims | persistentvolumeclaim, pvc | `labs/storage/persistent-volume-claims/` | `persistentvolumeclaim` | https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims |
| Storage Classes | storageclass, storageclasses, sc | `labs/storage/storage-classes/` | `storageclass` | https://kubernetes.io/docs/concepts/storage/storage-classes/ |
| CSI Drivers | csi, csi-driver, csi-drivers | `labs/storage/csi-drivers/` | `csidriver` | https://kubernetes.io/docs/concepts/storage/volumes/#csi |

## Scheduling

| Topic | Aliases | Path | Resource | Docs URL |
|---|---|---|---|---|
| Node Selector | nodeselector, node-selector | `labs/scheduling/node-selector/` | `pod.spec.nodeSelector` | https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector |
| Node Affinity | nodeaffinity, node-affinity | `labs/scheduling/node-affinity/` | `pod.spec.affinity.nodeAffinity` | https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity |
| Pod Affinity | podaffinity, pod-affinity, podantiaffinity, pod-anti-affinity | `labs/scheduling/pod-affinity/` | `pod.spec.affinity.podAffinity` | https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity |
| Taints & Tolerations | taint, taints, toleration, tolerations, taints-tolerations | `labs/scheduling/taints-tolerations/` | `pod.spec.tolerations` | https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/ |
| Priority Classes | priorityclass, priority-class, priority-classes, preemption | `labs/scheduling/priority-classes/` | `priorityclass` | https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/ |
| Resource Requests & Limits | resources, requests, limits, resource-requests, resource-limits, resourcequota, limitrange | `labs/scheduling/resource-requests-limits/` | `pod.spec.containers.resources` | https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/ |

## Security

| Topic | Aliases | Path | Resource | Docs URL |
|---|---|---|---|---|
| Service Accounts | serviceaccount, serviceaccounts, sa | `labs/security/service-accounts/` | `serviceaccount` | https://kubernetes.io/docs/concepts/security/service-accounts/ |
| RBAC | rbac, role, clusterrole, rolebinding, clusterrolebinding | `labs/security/rbac/` | `role` | https://kubernetes.io/docs/reference/access-authn-authz/rbac/ |
| Secrets | secret, secrets | `labs/security/secrets/` | `secret` | https://kubernetes.io/docs/concepts/configuration/secret/ |
| Security Context | securitycontext, security-context, runasuser, capabilities | `labs/security/security-context/` | `pod.spec.securityContext` | https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| Admission Controllers | admission, admission-controller, admission-controllers, webhook, validatingwebhook, mutatingwebhook | `labs/security/admission-controllers/` | `validatingwebhookconfiguration` | https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/ |

## Cluster Administration

| Topic | Aliases | Path | Resource | Docs URL |
|---|---|---|---|---|
| kubeadm | kubeadm, kubeadm-init, kubeadm-join | `labs/cluster-admin/kubeadm/` | — | https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/ |
| Cluster Upgrade | upgrade, cluster-upgrade, kubeadm-upgrade | `labs/cluster-admin/cluster-upgrade/` | — | https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/ |
| Certificate Management | certificate, certificates, cert, certs, csr, certificate-management | `labs/cluster-admin/certificate-management/` | `certificatesigningrequest` | https://kubernetes.io/docs/tasks/administer-cluster/certificates/ |
| etcd Backup | etcd-backup, etcdctl-backup, etcd-snapshot | `labs/cluster-admin/etcd-backup/` | — | https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#backing-up-an-etcd-cluster |
| etcd Restore | etcd-restore, etcdctl-restore | `labs/cluster-admin/etcd-restore/` | — | https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/#restoring-an-etcd-cluster |
| Control Plane | control-plane, controlplane, kube-apiserver, kube-scheduler, kube-controller-manager, etcd | `labs/cluster-admin/control-plane/` | — | https://kubernetes.io/docs/concepts/overview/components/#control-plane-components |
