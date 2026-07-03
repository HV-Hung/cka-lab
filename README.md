# Kubernetes Platform Lab

> A hands-on Kubernetes learning repository focused on **CKA preparation**, **production best practices**, and **Platform Engineering**.

## Overview

This repository documents my journey to becoming a Kubernetes Platform Engineer. It combines theory, practical labs, troubleshooting scenarios, and operational best practices into a single knowledge base.

The goal is not only to pass the Certified Kubernetes Administrator (CKA) exam, but also to develop the skills required to build, operate, and troubleshoot production Kubernetes clusters.

---

## Objectives

* Prepare for the Certified Kubernetes Administrator (CKA) exam
* Build a solid understanding of Kubernetes internals
* Practice real-world cluster administration
* Develop troubleshooting skills through hands-on scenarios
* Document production best practices
* Create a public portfolio demonstrating Kubernetes expertise

---

## Learning Roadmap

### Phase 1 – Kubernetes Fundamentals

* [ ] kubectl
* [ ] Pods
* [ ] ReplicaSets
* [ ] Deployments
* [ ] DaemonSets
* [ ] StatefulSets
* [ ] Jobs
* [ ] CronJobs

### Phase 2 – Networking

* [ ] Services
* [ ] EndpointSlice
* [ ] DNS
* [ ] Ingress
* [ ] Gateway API
* [ ] NetworkPolicy

### Phase 3 – Storage

* [ ] Volumes
* [ ] PersistentVolumes
* [ ] PersistentVolumeClaims
* [ ] StorageClasses
* [ ] CSI Drivers

### Phase 4 – Scheduling

* [ ] Node Selector
* [ ] Node Affinity
* [ ] Pod Affinity
* [ ] Taints & Tolerations
* [ ] Priority Classes
* [ ] Resource Requests & Limits

### Phase 5 – Security

* [ ] Service Accounts
* [ ] RBAC
* [ ] Secrets
* [ ] Security Context
* [ ] Admission Controllers

### Phase 6 – Cluster Administration

* [ ] kubeadm
* [ ] Cluster Upgrade
* [ ] Certificate Management
* [ ] etcd Backup
* [ ] etcd Restore
* [ ] Control Plane Components

### Phase 7 – Troubleshooting

* [ ] Pod Failures
* [ ] Scheduling Issues
* [ ] Networking Issues
* [ ] DNS Issues
* [ ] Storage Issues
* [ ] Cluster Failures

### Phase 8 – Mock Exams

* [ ] Practice Lab #1
* [ ] Practice Lab #2
* [ ] Full Mock Exam

---

## Repository Structure

```text
.
├── README.md
├── AGENTS.md
│
├── docs/
│   ├── architecture/
│   ├── kubectl/
│   ├── workloads/
│   ├── networking/
│   ├── scheduling/
│   ├── storage/
│   ├── security/
│   ├── cluster-administration/
│   └── troubleshooting/
│
├── labs/
│
├── scenarios/
│
├── cheatsheets/
│
├── scripts/
│
└── assets/
```

---

## Learning Workflow

Each topic follows the same learning process:

1. Learn the concept
2. Understand how it works internally
3. Build the smallest working example
4. Experiment with different configurations
5. Break it intentionally
6. Troubleshoot the problem
7. Document the findings
8. Summarize best practices

---

## Documentation Standards

Every documentation page follows a consistent structure:

* Overview
* Architecture
* Key Concepts
* Hands-on Examples
* Best Practices
* Common Mistakes
* Troubleshooting
* Interview Notes
* CKA Tips
* References

---

## Hands-on Labs

Every lab includes:

* Objective
* Prerequisites
* Deployment Steps
* Validation
* Cleanup
* Lessons Learned

Labs are designed to be reproducible from scratch.

---

## Troubleshooting Scenarios

Each scenario simulates a real production issue.

Topics include:

* CrashLoopBackOff
* ImagePullBackOff
* Pending Pods
* Failed Scheduling
* Service Discovery Issues
* NetworkPolicy Misconfiguration
* DNS Failures
* Storage Problems
* Certificate Issues
* etcd Recovery

The focus is on identifying symptoms, investigating the root cause, and applying the correct solution.

---

## Cheat Sheets

The `cheatsheets/` directory contains concise references for:

* kubectl commands
* YAML snippets
* Debugging commands
* Common workflows
* Exam shortcuts

These notes are intended for quick review rather than learning new concepts.

---

## References

* Kubernetes Official Documentation
* CKA Curriculum
* Killer.sh Practice Environment
* Kubernetes Enhancement Proposals (KEPs)
* CNCF Projects

---

## Progress

This repository is actively maintained as I continue my Kubernetes learning journey. The roadmap and checklist will be updated as new topics, labs, and troubleshooting scenarios are completed.
