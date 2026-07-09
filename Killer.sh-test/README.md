# Killer.sh CKA Practice Exam

Shell-based timed exam using questions from **Set-A** and **Set-B** (parsed from `Set-A.md` / `Set-B.md`).

## Quick Start

```bash
cd CKA-PREP-2025-v2

# Start Set-A exam (2 hours, 17 questions)
bash Killer.sh-test/killer-exam.sh start --set A

# Or Set-B
bash Killer.sh-test/killer-exam.sh start --set B

# Check current question
bash Killer.sh-test/killer-exam.sh check

# Navigate
bash Killer.sh-test/killer-exam.sh next
bash Killer.sh-test/killer-exam.sh prev

# Timer / status
bash Killer.sh-test/killer-exam.sh status
bash Killer.sh-test/killer-exam.sh timer   # dedicated view in 2nd terminal

# Pause / resume break (excluded from timer)
bash Killer.sh-test/killer-exam.sh pause
bash Killer.sh-test/killer-exam.sh resume

# Finish or reset
bash Killer.sh-test/killer-exam.sh finish
bash Killer.sh-test/killer-exam.sh reset
```

## Practice a Single Question

```bash
bash scripts/run-killer-question.sh --set A a01
bash Killer.sh-test/validate.sh a01
```

## Features

| Feature | Implementation |
|---------|------------------|
| **Set A / Set B** | Separate question banks (`set-a/`, `set-b/`) |
| **Navigation** | `next`, `prev` (re-runs cleanup + lab setup) |
| **Scoring** | `check` runs per-question validators (1 mark per sub-task) |
| **2-hour timer** | Background daemon, pinned top line, non-blocking |
| **Lab cleanup** | `cleanup-set-*.sh` removes stale objects before each setup |
| **Setup pause** | Timer pauses during cleanup and lab setup |

## Prerequisites

- Ubuntu / Killercoda with Kubernetes
- `kubectl`, `python3`, `helm` (Set-A Q2 MinIO)
- Write access to `/opt/course` (or set `KILLER_COURSE_DIR`)

## Structure

```
Killer.sh-test/
├── Set-A.md / Set-B.md       # Source question dumps
├── killer-exam.sh            # Timed exam runner
├── validate.sh             # Single-question validator
├── exam-config-set-a.yaml  # Question catalog + marks
├── exam-config-set-b.yaml
├── lib/
│   ├── course.sh           # /opt/course helpers
│   ├── cleanup-set-a.sh    # Pre-setup cleanup
│   ├── cleanup-set-b.sh
│   └── questions-set-*.sh
├── checks/set-a/           # a01.sh … a17.sh
├── checks/set-b/           # b01.sh … b17.sh
├── set-a/Question-*/       # LabSetUp, Questions, SolutionNotes
└── set-b/Question-*/
```

## Regenerating from Markdown

After editing `Set-A.md` or `Set-B.md`:

```bash
python3 Killer.sh-test/scripts/generate-exam.py
```

## Scoring

- **Set-A**: 35 marks (17 questions)
- **Set-B**: 40 marks (17 questions)

State is stored in `~/.killer-exam/`.

## Notes

- Questions are adapted from Killer Shell for local/single-node clusters.
- SSH node references (`cka9412`, etc.) are replaced with local cluster instructions.
- Some control-plane questions (kubeadm upgrade, etcd, kubelet) require cluster-admin access on the exam node.
