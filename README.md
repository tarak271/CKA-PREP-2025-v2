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

# Start the exam (resets cluster, then starts 2-hour timer)
bash exercises/cka-exam.sh start

# Reset cluster only (without starting exam)
bash exercises/reset.sh

# Optional: dedicated live timer in another terminal (updates every second)
bash exercises/cka-exam.sh timer

# After completing the current question, check your answer
bash exercises/cka-exam.sh check

# Move to the next question (cleanup + lab setup)
bash exercises/cka-exam.sh next

# Go back to the previous question (cleanup + lab setup)
bash exercises/cka-exam.sh prev

# View timer and running score
bash exercises/cka-exam.sh status

# Pause for a break (break time excluded from exam timer)
bash exercises/cka-exam.sh pause

# Resume after a break
bash exercises/cka-exam.sh resume

# End early and see final score
bash exercises/cka-exam.sh finish

# Start over
bash exercises/cka-exam.sh reset
```

### Exam workflow

1. `start` — runs `exercises/reset.sh` to rebuild a clean cluster, verifies no user objects remain, then begins the timed exam.
2. The timer **pauses automatically** while cleanup and lab setup scripts run (setup time is excluded).
3. Use `pause` and `resume` for manual breaks (break time is also excluded).
4. Work through the tasks on your cluster using `kubectl` and other tools.
5. `check` — validates each sub-task and awards 1 mark per passing check. Overall percentage is calculated against all **51** exam marks.
6. `next` — cleans up the previous question's cluster artifacts, then runs lab setup for the next question.
7. `prev` — go back one question (re-runs cleanup and lab setup for that question).
8. `finish` — shows your final score with a per-question breakdown.

The live timer stays pinned to the **top line** of the terminal; all command output appears below it.

For a dedicated full-screen timer in a second terminal: `bash exercises/cka-exam.sh timer`

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

## Killer.sh Practice Exam (Set-A / Set-B)

A separate shell-based exam using Killer Shell question banks from `Killer.sh-test/Set-A.md` and `Set-B.md`:

```bash
# Start Set-A or Set-B (2-hour timed exam)
bash Killer.sh-test/killer-exam.sh start --set A
bash Killer.sh-test/killer-exam.sh start --set B

bash Killer.sh-test/killer-exam.sh check
bash Killer.sh-test/killer-exam.sh next
bash Killer.sh-test/killer-exam.sh prev
```

See [Killer.sh-test/README.md](Killer.sh-test/README.md) for full documentation.
