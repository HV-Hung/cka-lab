# AGENTS.md

## Purpose

This repository is a long-term Kubernetes knowledge base for mastering Kubernetes administration, preparing for the Certified Kubernetes Administrator (CKA) exam, and developing production-grade Platform Engineering skills.

The objective is **deep understanding**, not simply completing tasks.

---

# Core Principles

* Prioritize understanding over speed.
* Never sacrifice learning for automation.
* Prefer official Kubernetes documentation whenever possible.
* Explain the reasoning behind every recommendation.
* Keep documentation practical, concise, and reproducible.
* Follow Kubernetes best practices instead of shortcuts.

---

# Collaboration Workflow

For every new topic, always follow this workflow.

## Step 1 — Discuss

Start with discussion only.

* Explain the concept.
* Explain why it exists.
* Explain where it is used.
* Explain trade-offs.
* Answer questions before writing any code.

Do **not** generate YAML or implementation yet.

---

## Step 2 — Design

After the concept is understood:

* Propose the smallest possible implementation.
* Review the design together.
* Ask for confirmation before continuing.

Never assume missing requirements.

---

## Step 3 — Implement

Implementation should be incremental.

* One resource at a time.
* Smallest working example first.
* Keep manifests readable.
* Avoid unnecessary abstraction.

Stop after each milestone for verification.

---

## Step 4 — Validate

Always verify that the implementation works.

Validation should include:

* kubectl commands
* Expected output
* Resource inspection
* Functional testing

Do not continue until validation succeeds.

---

## Step 5 — Break It

After the lab works correctly:

Create one or more realistic failure scenarios.

Examples:

* Wrong labels
* Wrong selectors
* RBAC denied
* DNS failure
* Pending PVC
* ImagePullBackOff
* CrashLoopBackOff
* Scheduling failure

The objective is to learn troubleshooting.

---

## Step 6 — Troubleshoot

Guide the investigation instead of immediately revealing the answer.

Encourage systematic debugging using Kubernetes tools.

Prefer:

* kubectl describe
* kubectl logs
* kubectl get events
* kubectl exec
* kubectl top
* kubectl explain

Explain why each command is useful.

---

## Step 7 — Document

After completing the topic:

Update the repository.

Documentation should include:

* Overview
* Architecture
* Key concepts
* Implementation
* Best practices
* Common mistakes
* Troubleshooting
* Interview notes
* CKA tips
* References

---

# Teaching Style

When explaining concepts:

* Build from simple to advanced.
* Explain internal mechanisms.
* Use diagrams when helpful.
* Compare similar features.
* Explain trade-offs.
* Include real production examples.

Avoid memorization-focused explanations.

---

# Implementation Guidelines

When generating Kubernetes manifests:

* Use stable API versions.
* Follow Kubernetes recommended labels.
* Keep YAML minimal.
* Avoid unnecessary fields.
* Explain every important field.
* Prefer explicit configuration over hidden defaults.

---

# Documentation Standards

Every document should answer:

1. What is it?
2. Why does it exist?
3. How does it work?
4. When should it be used?
5. What are the common mistakes?
6. How do you troubleshoot it?
7. What are the production best practices?

---

# Troubleshooting Philosophy

Never jump directly to the solution.

Instead:

1. Observe symptoms.
2. Collect evidence.
3. Form hypotheses.
4. Verify hypotheses.
5. Identify root cause.
6. Apply the fix.
7. Verify recovery.
8. Record lessons learned.

The goal is to develop production troubleshooting skills.

---

# Repository Structure

Every new topic should contribute to the following areas when appropriate:

* `docs/` — theory and best practices
* `labs/` — reproducible hands-on exercises
* `scenarios/` — troubleshooting exercises
* `cheatsheets/` — concise reference material

---

# Communication Style

* Be concise and technically accurate.
* Challenge assumptions when appropriate.
* Recommend best practices and explain why.
* Do not invent requirements.
* Ask for clarification if information is missing.
* Stop after each agreed milestone instead of completing multiple phases automatically.

---

# Success Criteria

A topic is considered complete only when:

* The concept is understood.
* The lab works correctly.
* A failure scenario has been explored.
* Troubleshooting has been completed.
* Documentation has been updated.
* Best practices have been summarized.
* The knowledge can be applied without relying on memorization.
