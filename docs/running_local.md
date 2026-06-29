# Running Locally

## Purpose

This document explains how to run one local smoke test of the DCI-based harness.

The first goal is not benchmarking or evaluation. The first goal is simply:

> Run one question, produce artifacts, and confirm the system works.

The base DCI-style repo already supports a programmatic runner that writes artifacts such as `question.txt`, `final.txt`, `conversation.json`, `conversation_full.json`, `latest_model_context.json`, `events.jsonl`, `state.json`, and `stderr.txt` under `outputs/runs/<timestamp>/`.

---

## Prerequisites

Install:

```text
Python 3.10+
uv
Node.js 20+
npm
ripgrep / rg
```

The base repo expects a local Pi checkout unless configured otherwise. The setup guide in the base repo uses a local `pi-mono` checkout and builds the Pi coding agent before running the wrapper.

---

## Environment Setup

Create a local environment file:

```bash
cp .env.example .env
```

Fill in the required provider keys or local model settings.

Example variables:

```bash
OPENAI_API_KEY=...
ANTHROPIC_API_KEY=...
```

Do not commit `.env`.

---

## Install Python Dependencies

From the repo root:

```bash
uv sync
```

---

## Prepare Pi Checkout

If the repo does not already include or reference a built Pi checkout, clone and build it locally.

```bash
git clone https://github.com/jdf-prog/pi-mono.git pi-mono
cd pi-mono
npm install
npm run build
cd ..
```

Verify the CLI exists:

```bash
node pi-mono/packages/coding-agent/dist/cli.js --version
```

The exact branch or fork may change depending on the chosen base repo. Record the selected Pi commit in the project README or a future `docs/reproducibility.md`.

---

## Prepare a Local Corpus

For the first smoke test, use a small local corpus.

Recommended first structure:

```text
corpus/
  smoke/
    doc1.txt
    doc2.txt
```

The first smoke corpus should be tiny. Avoid downloading large benchmark corpora until the runner works.

Example document idea:

```text
corpus/smoke/doc1.txt
corpus/smoke/doc2.txt
```

Each file can contain a few paragraphs of known facts so that the first run is easy to inspect manually.

Large benchmark corpora can be added later.

---

## Add a Smoke-Test Question

Create:

```text
examples/questions/smoke_test.txt
```

The question should be answerable from the small local corpus.

Example:

```text
According to the local documents, what is the main topic described in doc1?
```

Keep this question simple. The purpose is to verify the harness, not the model.

---

## Basic Smoke Run

From the repo root:

```bash
uv run dci-agent-lite \
  --provider openai \
  --model <MODEL_NAME> \
  --package-dir "$PWD/pi-mono/packages/coding-agent" \
  --agent-dir "$PWD/pi-mono/.pi/agent" \
  --cwd "$PWD/corpus/smoke" \
  --tools read,bash \
  --max-turns 6 \
  --question-file "$PWD/examples/questions/smoke_test.txt"
```

Replace:

```text
<MODEL_NAME>
```

with the model configured in your environment.

The base repo documents `read,bash` as the typical enabled tool set for local corpus interaction.

---

## Expected Output

A successful run should create a directory like:

```text
outputs/runs/<timestamp>/
  events.jsonl
  state.json
  conversation_full.json
  conversation.json
  latest_model_context.json
  final.txt
  stderr.txt
  question.txt
```

Check the final answer:

```bash
cat outputs/runs/<timestamp>/final.txt
```

Check errors or warnings:

```bash
cat outputs/runs/<timestamp>/stderr.txt
```

Check the raw event stream:

```bash
head outputs/runs/<timestamp>/events.jsonl
```

---

## Run With Explicit Output Directory

For repeatable local testing:

```bash
uv run dci-agent-lite \
  --provider openai \
  --model <MODEL_NAME> \
  --package-dir "$PWD/pi-mono/packages/coding-agent" \
  --agent-dir "$PWD/pi-mono/.pi/agent" \
  --cwd "$PWD/corpus/smoke" \
  --tools read,bash \
  --max-turns 6 \
  --output-dir "$PWD/outputs/runs/smoke-test" \
  --question-file "$PWD/examples/questions/smoke_test.txt"
```

If the output directory already exists and is non-empty, use `--resume` only when intentionally reusing it.

---

## Resume a Run

```bash
uv run dci-agent-lite \
  --resume "$PWD/outputs/runs/smoke-test" \
  --provider openai \
  --model <MODEL_NAME> \
  --package-dir "$PWD/pi-mono/packages/coding-agent" \
  --agent-dir "$PWD/pi-mono/.pi/agent" \
  --cwd "$PWD/corpus/smoke" \
  --tools read,bash \
  --max-turns 6
```

Resuming reuses the artifact directory. True model-session continuity may require session-related options from the base runner.

---

## Context-Management Level

Runtime context-management levels are useful for later experiments and ablations. For the first smoke test, keep the default behavior unless debugging context pressure.

Example:

```bash
uv run dci-agent-lite \
  --provider openai \
  --model <MODEL_NAME> \
  --package-dir "$PWD/pi-mono/packages/coding-agent" \
  --agent-dir "$PWD/pi-mono/.pi/agent" \
  --cwd "$PWD/corpus/smoke" \
  --tools read,bash \
  --max-turns 6 \
  --extra-arg="--context-management-level level3" \
  --question-file "$PWD/examples/questions/smoke_test.txt"
```

The base DCI docs describe runtime context-management levels as a behavior-changing layer for experiments and ablations.

---

## Local Observability

OpenTelemetry and Jaeger are covered in:

```text
docs/observability.md
```

For the first local run, it is acceptable to verify artifacts first and tracing second.

Recommended order:

```text
1. Run smoke test.
2. Confirm final.txt exists.
3. Confirm stderr.txt has no fatal error.
4. Confirm events.jsonl exists.
5. Then verify OpenTelemetry traces.
```

---

## Common Failures

### `pi-mono` is missing

Symptom:

```text
package-dir does not exist
```

Fix:

```bash
git clone https://github.com/jdf-prog/pi-mono.git pi-mono
cd pi-mono
npm install
npm run build
cd ..
```

---

### Node build missing

Symptom:

```text
dist/cli.js not found
```

Fix:

```bash
cd pi-mono
npm install
npm run build
cd ..
```

---

### Missing API key

Symptom:

```text
authentication error
missing API key
```

Fix:

```bash
cp .env.example .env
```

Then fill in the correct key and reload your shell environment.

---

### Empty or missing `final.txt`

Check:

```bash
cat outputs/runs/<timestamp>/stderr.txt
cat outputs/runs/<timestamp>/events.jsonl
```

Likely causes:

* model call failed
* provider config is wrong
* tool command failed
* max turns too low
* corpus path is wrong

---

### Corpus path is wrong

Symptom:

```text
no such file or directory
```

Fix:

```bash
ls "$PWD/corpus/smoke"
```

Make sure `--cwd` points to an existing local corpus folder.

---

### Tool access problem

Symptom:

```text
tool not allowed
command failed
```

Fix:

Use the minimal first-iteration tool set:

```text
read,bash
```

Avoid adding more tools until the baseline is stable.

---

## First Local Run Checklist

A smoke run is successful when:

```text
[ ] command exits cleanly
[ ] outputs/runs/<timestamp>/ exists
[ ] question.txt exists
[ ] final.txt exists
[ ] stderr.txt exists
[ ] events.jsonl exists
[ ] final answer is manually inspectable
[ ] generated artifacts are not committed
```

---

## What This Does Not Prove

A successful local run does not prove:

* answer correctness
* retrieval quality
* benchmark performance
* semantic faithfulness
* model robustness
* agent efficiency

It only proves:

> The local harness can run one question and produce inspectable artifacts.

