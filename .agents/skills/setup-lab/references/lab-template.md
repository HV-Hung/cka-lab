# Lab README Template

Use this template when filling in a lab's `README.md`. Replace all `<!-- ... -->` comments with real content. Remove the comments after filling in each section.

---

```markdown
# Lab: <Topic Name>

> Domain: <CKA Domain> | Difficulty: <Beginner/Intermediate/Advanced>

## Objective

State clearly what the user will learn and build. One to three sentences.

Example: "In this lab you will create a Deployment that manages a ReplicaSet of nginx Pods, perform a rolling update, and roll back to a previous revision."

## Prerequisites

- Running cluster (`make up` from repo root)
- List any additional requirements (e.g., "metrics-server installed", "ingress controller deployed")

## Key Concepts

Brief theory recap — 3 to 5 bullet points covering the most important things to understand before starting. This is NOT a full explanation; that belongs in Phase 1 (Discuss). This is a quick refresher.

Example:
- A Deployment manages ReplicaSets, which in turn manage Pods.
- Rolling updates create a new ReplicaSet and gradually scale it up while scaling the old one down.
- The `spec.strategy.type` field controls how updates are applied.

## Steps

Break the lab into numbered steps. Each step should:
1. State what you are doing and why.
2. Show the manifest or command.
3. Show what to expect.

### Step 1 — <Description>

<Explanation of what this step does and why>

```bash
kubectl apply -f manifests/01-<resource>.yaml
```

Verify:
```bash
kubectl get <resource>
```

Expected output:
```
NAME    READY   STATUS    AGE
...
```

### Step 2 — <Description>

<Continue the pattern>

## Validation

List all commands needed to verify the entire lab is working correctly. Include expected output for each command.

```bash
# Verify pods are running
kubectl get pods -l app.kubernetes.io/name=<name>

# Verify the service is reachable (if applicable)
kubectl exec -it <pod> -- curl <service-name>:<port>
```

## Cleanup

```bash
# Remove all lab resources
kubectl delete -f labs/<domain>/<topic>/manifests/
```

If a namespace was created:
```bash
kubectl delete namespace <namespace>
```

## Lessons Learned

Summarize the key takeaways after completing the lab AND the troubleshooting exercise. Include:

- What you learned about the resource.
- What the most common failure modes are.
- What diagnostic commands were most useful.
- Any CKA exam tips related to this topic.

### CKA Tips

- Bullet points of exam-specific advice.
- Example: "Use `kubectl create deployment --image=nginx --dry-run=client -o yaml` to generate manifests quickly during the exam."

### Common Mistakes

- Bullet points of things that often go wrong.
- Example: "Forgetting to match the selector labels between the Service and the Deployment."
```

---

## Section Guidelines

| Section | Required? | When to fill in |
|---|---|---|
| Objective | Yes | Phase 2 (Design) |
| Prerequisites | Yes | Phase 2 (Design) |
| Key Concepts | Yes | Phase 3 (Implement) |
| Steps | Yes | Phase 3 (Implement) — update as each manifest is created |
| Validation | Yes | Phase 4 (Validate) |
| Cleanup | Yes | Phase 7 (Document) |
| Lessons Learned | Yes | Phase 7 (Document) — after troubleshooting is complete |
| CKA Tips | Yes | Phase 7 (Document) |
| Common Mistakes | Yes | Phase 7 (Document) — informed by the Break It scenario |
