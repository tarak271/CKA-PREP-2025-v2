# CKA Practice (Simple Edition)

Straightforward CKA practice labs derived from the [CKA-PREP playlist](https://www.youtube.com). Every question lives in its own folder with three bash files:

- `LabSetUp.bash` — prepares the cluster environment for the scenario.
- `Questions.bash` — the scenario text plus the YouTube link for the walkthrough.
- `SolutionNotes.bash` — a step-by-step solution when you need a hint.

## Prerequisites

- Ubuntu server (or Killercoda playground) with Kubernetes installed
- `kubectl` configured and pointing at your cluster
- `python3` (used by answer validators)
- `helm` (for Question 2 — Argo CD)

## Practice a Single Question

```bash
git clone <this-repo>
cd CKA-PREP-2025-v2

# Run lab setup and print the question
bash scripts/run-question.sh "Question-5 HPA"

# Complete the tasks, then validate your work (1 mark per sub-task)
bash exercises/validate.sh "Question-5 HPA"
# or
bash exercises/validate.sh q05
```

## Timed CKA Practice Exam (2 Hours)

A continuous, exam-style test covering all 17 questions with a **2-hour timer** and **automatic scoring** (1 mark per sub-task, 51 marks total).

```bash
cd CKA-PREP-2025-v2

# Start the exam
bash exercises/cka-exam.sh start

# After completing the current question, check your answer
bash exercises/cka-exam.sh check

# Move to the next question (runs lab setup automatically)
bash exercises/cka-exam.sh next

# View timer and running score
bash exercises/cka-exam.sh status

# End early and see final score
bash exercises/cka-exam.sh finish

# Start over
bash exercises/cka-exam.sh reset
```

### Exam workflow

1. `start` — begins the 2-hour countdown and presents Question 1 with lab setup.
2. Work through the tasks on your cluster using `kubectl` and other tools.
3. `check` — validates each sub-task and awards 1 mark per passing check.
4. `next` — advances to the next question (lab setup runs automatically).
5. `finish` — shows your final score with a per-question breakdown.

**Note:** Question 15 (Etcd-Fix) is presented last because its lab setup temporarily breaks the API server. All other questions should be attempted first.

## Available Questions

| # | Folder | Topic | Marks |
|---|--------|-------|-------|
| 1 | Question-1 MariaDB-Persistent volume | PVC/PV recovery | 4 |
| 2 | Question-2 ArgoCD | Helm install without CRDs | 5 |
| 3 | Question-3 Sidecar | Add sidecar container | 3 |
| 4 | Question-4 Resource-Allocation | WordPress resource requests/limits | 5 |
| 5 | Question-5 HPA | HorizontalPodAutoscaler | 4 |
| 6 | Question-6 CRDs | cert-manager CRD listing + field docs | 2 |
| 7 | Question-7 PriorityClass | Create/patch priority class | 2 |
| 8 | Question-8 CNI & Network Policy | Install Flannel or Calico | 3 |
| 9 | Question-9 Cri-Dockerd | Install cri-dockerd + sysctl tuning | 6 |
| 10 | Question-10 Taints-Tolerations | Taint node + tolerating pod | 2 |
| 11 | Question-11 Gateway-API | Migrate Ingress → Gateway + HTTPRoute | 2 |
| 12 | Question-12 Ingress | NodePort service + Ingress | 2 |
| 13 | Question-13 Network-Policy | Choose least-permissive policy | 2 |
| 14 | Question-14 Storage-Class | Create/patch default StorageClass | 3 |
| 15 | Question-15 Etcd-Fix | Fix kube-apiserver etcd endpoint | 2 |
| 16 | Question-16 NodePort | Expose deployment via NodePort | 3 |
| 17 | Question-17 TLS-Config | Restrict TLS to v1.3, verify with curl | 3 |

**Total: 51 marks**

## Project Structure

```
CKA-PREP-2025-v2/
├── Question-*/              # Lab setup, questions, and solutions
├── scripts/
│   └── run-question.sh        # Run a single question's lab setup
└── exercises/
    ├── cka-exam.sh            # Timed 2-hour exam runner
    ├── validate.sh            # Validate a single question
    ├── exam-config.yaml       # Question and sub-task definitions
    ├── lib/                   # Shared helpers
    └── checks/                # Per-question validators (q01–q17)
```

## Adding New Questions

Copy an existing `Question-*` folder with `LabSetUp.bash`, `Questions.bash`, and `SolutionNotes.bash`. Add a matching validator in `exercises/checks/` and register it in `exercises/lib/questions.sh` and `exercises/exam-config.yaml`.
