---
name: setup-lab
description: >
  Set up a complete hands-on Kubernetes lab for a specific CKA topic.
  Follows the 7-step learning workflow: Discuss, Design, Implement,
  Validate, Break It, Troubleshoot, Document.
---

# Setup Lab Skill

You are helping a learner build a hands-on Kubernetes lab for CKA exam preparation. Your goal is **deep understanding**, not speed. Follow every phase below in strict order. **Stop after each phase** and wait for the user to continue.

---

## 1. Resolve the Topic

When the user asks to set up a lab (e.g., "set up the pods lab", "create a lab for RBAC", "build the services lab"):

1. Read the topic map at `.agents/skills/setup-lab/references/topic-map.md` to resolve the user's input to a **domain** and **directory path**.
2. Confirm the target directory exists: `labs/{domain}/{topic}/`.
3. Read the existing `labs/{domain}/{topic}/README.md` to see current state.
4. Do **NOT** scan the entire `labs/` tree or read unrelated lab directories.

If the topic is ambiguous (e.g., "pv" could mean persistent-volumes or persistent-volume-claims), ask the user to clarify.

---

## 2. Check Cluster Prerequisites

Before starting, verify the cluster is running:

```bash
make status
```

If the cluster is not running, tell the user to run `make up` from the repository root and stop.

---

## 3. Execute the 7-Phase Learning Workflow

### Phase 1 — Discuss (Concept Only, No YAML)

Before explaining the topic, gather authoritative information from two sources:

**Step A — Fetch official Kubernetes documentation:**

Look up the **Docs URL** from the topic map and fetch it using `read_url_content`. Summarize the key points — do not dump the raw page to the user. If the URL fails, fall back to your own knowledge but tell the user.

**Step B — Show the live API schema:**

If the topic map has a **Resource** value (not `—`), run:

```bash
kubectl explain <resource> --recursive
```

Present only the most important fields with brief descriptions. For nested resources (e.g., `pod.spec.affinity.nodeAffinity`), use `kubectl explain <path>` to drill into the relevant subtree.

> These two sources mirror the only references available during the CKA exam: the official docs at kubernetes.io and `kubectl explain` on the live cluster.

**Step C — Explain the topic to the user.** Cover:

- **What is it?** — Definition and purpose.
- **Why does it exist?** — The problem it solves.
- **How does it work?** — Internal mechanism (e.g., how the kubelet manages Pods, how kube-proxy implements Services).
- **Where is it used?** — Real production use cases.
- **Trade-offs** — When to use it vs. alternatives.
- **CKA relevance** — What the exam tests about this topic.

Rules for this phase:
- Do **NOT** generate any YAML or manifests.
- Do **NOT** create or modify any files.
- Build from simple to advanced.
- Use diagrams (mermaid) when helpful.
- Compare with similar Kubernetes features.
- Cite the official docs URL at the end for the user's reference.

**⛔ STOP and wait for the user before proceeding to Phase 2.**

---

### Phase 2 — Design (Propose the Lab)

Propose the smallest working lab that demonstrates the key concepts. Present:

1. **Lab objective** — One sentence describing what the user will learn.
2. **Manifest list** — Which YAML files you will create, in order. Use numbered filenames:
   - `manifests/01-<resource>.yaml`
   - `manifests/02-<resource>.yaml`
3. **What each manifest demonstrates** — Brief explanation of each file's purpose.
4. **Namespace** — If the lab needs a dedicated namespace, include it.

Rules for this phase:
- Propose the **minimum** number of manifests needed to demonstrate the concept.
- Do **NOT** write the YAML yet. Only describe what each file will contain.
- Ask for confirmation before continuing.

**⛔ STOP and wait for user approval before proceeding to Phase 3.**

---

### Phase 3 — Implement (Create Manifests)

Create the manifests **one at a time**, incrementally:

1. Read the lab README template at `.agents/skills/setup-lab/references/lab-template.md`.
2. Create each manifest file in `labs/{domain}/{topic}/manifests/`.
3. After creating each manifest, **explain every important field** in the YAML.
4. Apply each manifest to the cluster and show the result.
5. Update the lab `README.md` as you go — fill in the Objective, Prerequisites, Key Concepts, and Steps sections.

Manifest conventions:
- Use **stable API versions** (e.g., `apps/v1`, `v1`, `networking.k8s.io/v1`).
- Use **Kubernetes recommended labels**:
  ```yaml
  labels:
    app.kubernetes.io/name: <name>
    app.kubernetes.io/part-of: cka-lab
    app.kubernetes.io/managed-by: manual
  ```
- Keep YAML **minimal** — no unnecessary fields.
- Prefer **explicit configuration** over hidden defaults.
- Use comments in YAML sparingly, only for non-obvious choices.

**⛔ STOP after each manifest is applied and verified. Wait for the user before continuing to the next manifest or phase.**

---

### Phase 4 — Validate

Provide validation commands and expected output:

1. List the **exact kubectl commands** the user should run to verify the lab.
2. Show the **expected output** so the user knows what success looks like.
3. Include functional testing where applicable (e.g., `curl` a Service, `exec` into a Pod).
4. Run the validation commands on the live cluster and confirm results.
5. Update the lab README **Validation** section with these commands.

Do **not** proceed until validation succeeds.

**⛔ STOP and confirm with the user that everything works before proceeding to Phase 5.**

---

### Phase 5 — Break It (Create a Failure Scenario)

Create **one realistic failure scenario** relevant to the topic:

1. Describe what you are about to break and why this failure is common.
2. Create a broken manifest or modify an existing one. Save it as `manifests/99-broken-<description>.yaml`.
3. Apply the broken manifest to the cluster.
4. Tell the user **only the symptom** they should observe (e.g., "The Pod is stuck in Pending").
5. Do **NOT** reveal the root cause or the fix yet.

Examples of good failure scenarios by domain:
- **Workloads**: ImagePullBackOff, CrashLoopBackOff, wrong command
- **Networking**: Wrong selector, wrong port, missing NetworkPolicy
- **Storage**: PVC Pending, wrong StorageClass, access mode mismatch
- **Scheduling**: Unschedulable, taint with no toleration, insufficient resources
- **Security**: RBAC denied, wrong ServiceAccount, forbidden SecurityContext
- **Cluster Admin**: Certificate expired, etcd connection refused

**⛔ STOP and let the user investigate before proceeding to Phase 6.**

---

### Phase 6 — Troubleshoot (Guide, Don't Solve)

Guide the user through systematic debugging. Do **NOT** reveal the answer immediately.

1. Suggest **one diagnostic command at a time**:
   - `kubectl get <resource> -o wide`
   - `kubectl describe <resource>`
   - `kubectl logs <pod>`
   - `kubectl get events --sort-by='.lastTimestamp'`
   - `kubectl exec -it <pod> -- <command>`
2. After each command, ask the user: **"What do you see? What does this tell you?"**
3. If the user is stuck, provide a **hint** rather than the answer.
4. Only reveal the root cause after the user has attempted diagnosis.
5. Guide the user to apply the fix and verify recovery.

Troubleshooting philosophy:
1. Observe symptoms
2. Collect evidence
3. Form hypotheses
4. Verify hypotheses
5. Identify root cause
6. Apply the fix
7. Verify recovery

**⛔ STOP after the fix is verified. Wait for the user before proceeding to Phase 7.**

---

### Phase 7 — Document (Finalize the Lab)

Complete the lab documentation:

1. Update the lab `README.md` with all sections filled in:
   - **Objective**: What was learned.
   - **Prerequisites**: What's needed to run this lab.
   - **Key Concepts**: Brief theory recap.
   - **Steps**: All commands and manifests, in order.
   - **Validation**: Commands and expected output.
   - **Cleanup**: Commands to remove all lab resources.
   - **Lessons Learned**: Key takeaways from the lab AND the troubleshooting scenario.
   - **CKA Tips**: Exam-specific advice for this topic.
   - **Common Mistakes**: Informed by the Break It scenario.

2. Add a **Cleanup** section:
   ```bash
   kubectl delete -f labs/{domain}/{topic}/manifests/
   ```

3. Confirm with the user that the lab is complete.

---

## Context Optimization Rules

To keep context usage efficient:

- **DO** read: The topic map, lab template, and the specific lab directory you're working in.
- **DO** read: `AGENTS.md` for the learning workflow rules.
- **DO NOT** read: Other lab directories, unrelated docs, or the entire repository tree.
- **DO NOT** read: The lab template if you already have its content in context.
- **Prefer** running kubectl commands over reading cluster state from files.
- **Reuse** the topic map resolution from Phase 1 — don't re-read it in later phases.
