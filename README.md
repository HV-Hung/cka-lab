# CKA Lab

> Hands-on Kubernetes labs for **CKA exam preparation** and **production troubleshooting skills**.

## Overview

This repository is a self-contained learning environment for mastering Kubernetes administration. Every topic follows a structured 7-step workflow: **Discuss → Design → Implement → Validate → Break It → Troubleshoot → Document**.

The goal is deep understanding — not memorization.

---

## Quick Start

```bash
make up          # Create a Kind cluster (1 control-plane + 1 worker)
make status      # Verify nodes are ready
```

Then open a new conversation and say: **"Set up the pods lab"** — the agent walks you through all 7 phases.

```bash
make down        # Delete the cluster when done
make reset       # Shortcut: delete + recreate
```

---

## Learning Roadmap

### Phase 1 — Workloads

* [ ] [Pods](labs/workloads/pods/)
* [ ] [ReplicaSets](labs/workloads/replicasets/)
* [ ] [Deployments](labs/workloads/deployments/)
* [ ] [DaemonSets](labs/workloads/daemonsets/)
* [ ] [StatefulSets](labs/workloads/statefulsets/)
* [ ] [Jobs](labs/workloads/jobs/)
* [ ] [CronJobs](labs/workloads/cronjobs/)

### Phase 2 — Networking

* [ ] [Services](labs/networking/services/)
* [ ] [DNS](labs/networking/dns/)
* [ ] [Ingress](labs/networking/ingress/)
* [ ] [Gateway API](labs/networking/gateway-api/)
* [ ] [Network Policies](labs/networking/network-policies/)

### Phase 3 — Storage

* [ ] [Volumes](labs/storage/volumes/)
* [ ] [Persistent Volumes](labs/storage/persistent-volumes/)
* [ ] [Persistent Volume Claims](labs/storage/persistent-volume-claims/)
* [ ] [Storage Classes](labs/storage/storage-classes/)
* [ ] [CSI Drivers](labs/storage/csi-drivers/)

### Phase 4 — Scheduling

* [ ] [Node Selector](labs/scheduling/node-selector/)
* [ ] [Node Affinity](labs/scheduling/node-affinity/)
* [ ] [Pod Affinity](labs/scheduling/pod-affinity/)
* [ ] [Taints & Tolerations](labs/scheduling/taints-tolerations/)
* [ ] [Priority Classes](labs/scheduling/priority-classes/)
* [ ] [Resource Requests & Limits](labs/scheduling/resource-requests-limits/)

### Phase 5 — Security

* [ ] [Service Accounts](labs/security/service-accounts/)
* [ ] [RBAC](labs/security/rbac/)
* [ ] [Secrets](labs/security/secrets/)
* [ ] [Security Context](labs/security/security-context/)
* [ ] [Admission Controllers](labs/security/admission-controllers/)

### Phase 6 — Cluster Administration

* [ ] [kubeadm](labs/cluster-admin/kubeadm/)
* [ ] [Cluster Upgrade](labs/cluster-admin/cluster-upgrade/)
* [ ] [Certificate Management](labs/cluster-admin/certificate-management/)
* [ ] [etcd Backup](labs/cluster-admin/etcd-backup/)
* [ ] [etcd Restore](labs/cluster-admin/etcd-restore/)
* [ ] [Control Plane Components](labs/cluster-admin/control-plane/)

---

## Repository Structure

```text
.
├── README.md
├── AGENTS.md
├── Makefile                    # Delegates cluster commands to cluster/Makefile
├── cheatsheet.md               # Consolidated CKA quick reference
│
├── cluster/                    # Cluster configuration & lifecycle management
│   ├── kind-config.yaml        # 1 control-plane, 1 worker node configuration
│   └── Makefile                # CLI wrapper for up, down, status, reset
│
└── labs/                       # CKA domain-grouped hands-on labs
    ├── README.md               # Directory index and TOC
    ├── workloads/              # Pods, Deployments, DaemonSets, StatefulSets, Jobs...
    ├── networking/             # Services, Ingress, DNS, NetworkPolicies...
    ├── storage/                # Volumes, PV/PVCs, StorageClasses, CSI...
    ├── scheduling/             # NodeAffinity, Taints/Tolerations, Resources...
    ├── security/               # ServiceAccounts, RBAC, Secrets, Contexts...
    └── cluster-admin/          # Kubeadm, Upgrades, Certificates, etcd backup...
```

---

## Lab Structure

Every lab follows a consistent structure:

* **Objective** — What you will learn
* **Prerequisites** — Cluster state and dependencies
* **Key Concepts** — Brief theory recap
* **Steps** — Manifests and commands, applied incrementally
* **Validation** — Commands and expected output to verify success
* **Cleanup** — How to remove all lab resources
* **Lessons Learned** — Key takeaways, CKA tips, and common mistakes

Each lab includes a **Break It** scenario that introduces a realistic failure for troubleshooting practice.

Quick reference: [`cheatsheet.md`](cheatsheet.md)

---

## References

* [Kubernetes Official Documentation](https://kubernetes.io/docs/)
* [CKA Curriculum](https://github.com/cncf/curriculum)
* [Killer.sh Practice Environment](https://killer.sh/)
