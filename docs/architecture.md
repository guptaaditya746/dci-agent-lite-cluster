# Architecture

## Scope

This repository is a **DCI-based research harness**.

It starts from the DCI pattern: an agent interacts directly with a local corpus, produces run artifacts, and lets the researcher inspect what happened. The first iteration focuses on making the baseline reproducible and observable, not on adding evaluation frameworks or new agent abstractions.

The base repo already writes useful artifacts such as `events.jsonl`, `conversation.json`, `conversation_full.json`, `latest_model_context.json`, `final.txt`, `question.txt`, and `stderr.txt`. These remain the center of the workflow.

---

## First-Iteration Architecture

```text
Developer
  |
  v
DCI Runner CLI
  |
  v
Pi / Agent Runner
  |
  +--> Local Corpus
  |
  +--> Run Artifacts
  |      outputs/runs/<timestamp>/
  |        events.jsonl
  |        conversation.json
  |        conversation_full.json
  |        latest_model_context.json
  |        final.txt
  |        question.txt
  |        stderr.txt
  |
  +--> OpenTelemetry Spans
           |
           v
      OTel Collector
           |
           v
        Jaeger UI
```

---

## Core Components

### 1. DCI Runner

The runner is the main entrypoint.

Responsibilities:

* accept a question
* configure provider/model/tool options
* launch the underlying agent runner
* write run artifacts
* return the final answer
* emit basic telemetry

The runner should stay close to the base DCI behavior.

---

### 2. Agent Runner

The agent runner performs the actual task.

Responsibilities:

* interact with the local corpus
* use allowed tools
* manage the conversation loop
* produce final output

This layer is treated as the experiment subject, not something we rewrite in the first iteration.

---

### 3. Local Corpus

The corpus is read by the agent through the existing DCI-style workflow.

Responsibilities:

* store documents locally
* support direct corpus interaction
* avoid requiring a vector database or offline index in the first iteration

No custom retrieval server is added yet.

---

### 4. Run Artifacts

Artifacts are the main debugging and research record.

Responsibilities:

* preserve the full run trace
* store final answer
* store stderr
* store latest model context
* support later analysis and evaluation

Artifacts remain file-based in the first iteration. No database is added.

---

### 5. OpenTelemetry

OpenTelemetry records the harness lifecycle.

Responsibilities:

* trace run start and finish
* trace subprocess execution
* trace artifact creation
* trace errors
* attach safe metadata such as model, provider, output directory, exit code, and run status

OpenTelemetry must not export secrets, full prompts, full answers, or full corpus passages.

---

### 6. OTel Collector + Jaeger

The local observability stack is minimal.

Responsibilities:

* receive traces from the app
* route traces through the collector
* display traces in Jaeger

Only these services are used in the first iteration:

```text
otel-collector
jaeger
```

No Grafana, Tempo, Postgres, Redis, or MCP server yet.

---

## Repository Layout

```text
repo-root/
  README.md
  pyproject.toml
  .env.example
  .gitignore
  LICENSE

  docs/
    architecture.md
    development_milestones.md
    running_local.md
    observability.md
    roadmap_later.md

  configs/
    otel-collector.yaml

  docker/
    docker-compose.observability.yml

  prompts/
    system_prompt.txt

  scripts/
    examples/
    benchmark/
    dev/

  src/
    dci/
      runner/
      artifacts/
      observability/
      benchmark/

  outputs/
    .gitkeep
```

---

## What Is Implemented First

First iteration includes:

* DCI base repo structure
* local smoke run
* artifact output
* minimal docs
* OpenTelemetry spans
* OTel Collector
* Jaeger

---

## Deferred Work

The following are intentionally deferred:

* Inspect AI
* DeepEval
* RAGAS
* MCP / FastMCP
* Pydantic AI
* Pydantic artifact schemas
* custom retrieval server
* Grafana / Tempo
* Postgres
* Redis
* CI benchmark automation

These may be added after the first working iteration is complete.

---

## Later Architecture Direction

Later, the repo may grow like this:

```text
DCI Runner
  |
  +--> Run Artifacts
  |       |
  |       +--> Typed Artifact Parser
  |       +--> Evaluation Harness
  |       +--> MCP Artifact Inspector
  |
  +--> OpenTelemetry
          |
          +--> Jaeger now
          +--> Tempo/Grafana later if needed
```

Future tools should support the research workflow without replacing the DCI baseline too early.

---

## Limitations

The first iteration does not provide:

* automatic correctness evaluation
* semantic answer grading
* retrieval quality metrics
* benchmark dashboards
* database-backed experiment history
* production deployment
* agent supervision
* MCP-compatible developer tools

The first iteration only proves:

> The DCI baseline can run, produce artifacts, and emit useful traces.

