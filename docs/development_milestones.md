# Development Milestones for DCI-Based Research Harness

## 1. Purpose

This document defines the first development roadmap for our repository.

The project will be based on a **DCI-style research repo**, not a fresh architecture designed from scratch. The goal is to preserve the research baseline, make it runnable, add useful observability, and only later add evaluation frameworks, MCP tooling, and Pydantic-based developer tools.

The uploaded DCI-style repo already provides a useful baseline structure: a programmatic runner, local corpus interaction, run artifacts, context-management options, setup docs, benchmark scripts, and output folders such as `events.jsonl`, `conversation.json`, `conversation_full.json`, `latest_model_context.json`, `final.txt`, `question.txt`, and `stderr.txt`. These artifacts are valuable because they let us debug behavior before introducing heavier evaluation frameworks.

The first iteration should answer one question:

> Can we run the base system cleanly, save artifacts, and observe what happened?

Everything else is later.

---

## 2. Principles

### 2.1 Research-base first

We will not begin by creating our own agent framework. We will use the DCI repo as the spine and modify it in small, reviewable commits.

### 2.2 No framework soup in iteration one

The following are intentionally **not implemented** in the first iteration:

* Inspect AI
* DeepEval
* RAGAS
* MCP / FastMCP
* Pydantic AI agent runtime
* custom retrieval server
* Grafana dashboards
* Postgres
* Redis

They may be useful later, but adding them now would make the repo feel like “vibe coding” instead of controlled research engineering.

### 2.3 Preserve artifact-first workflow

Before automated evals, the repo should produce clean run artifacts. The DCI baseline already writes run artifacts, and our first job is to organize, document, and observe those artifacts.

### 2.4 Observability before evaluation

OpenTelemetry is useful in the first iteration because it helps us understand run flow, subprocess duration, artifact generation, errors, and event counts. The OpenTelemetry Collector is designed to receive, process, and export telemetry in a vendor-agnostic way, which keeps our tracing backend replaceable later.

---

## 3. First Iteration Scope

### Implement now

* Clean repo arrangement around the DCI base.
* One reproducible local run.
* Minimal docs.
* OpenTelemetry tracing in the runner.
* Docker Compose for:

  * OpenTelemetry Collector
  * Jaeger

### Do not implement now

* no Inspect AI task wrapper
* no DeepEval / RAGAS metrics
* no FastMCP server
* no Pydantic AI agent
* no custom retrieval abstraction
* no database
* no dashboard stack beyond Jaeger UI
* no production deployment

### Why Jaeger first?

Use Jaeger for the first iteration because it is simple for local trace inspection. Jaeger can accept OpenTelemetry Protocol trace data, and Jaeger documentation notes OTLP support for trace data.

Tempo can be evaluated later when we need Grafana integration, high-volume trace storage, metrics from spans, or trace-log-metric linking. Grafana describes Tempo as an open-source distributed tracing backend that can search traces, generate metrics from spans, and link trace data with logs and metrics.

---

## 4. Target Repository Arrangement

This is the intended repo shape after the first iteration.

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
      __init__.py
      runner/
      artifacts/
      observability/
      benchmark/

  outputs/
    .gitkeep
```

This layout keeps the DCI-style source while separating documentation, configs, Docker files, and future work.

---

## 5. Architecture for First Iteration

### Runtime architecture

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
  +--> outputs/runs/<timestamp>/
  |      events.jsonl
  |      conversation.json
  |      conversation_full.json
  |      latest_model_context.json
  |      final.txt
  |      question.txt
  |      stderr.txt
  |
  +--> OpenTelemetry spans
          |
          v
     OTel Collector
          |
          v
       Jaeger UI
```

### What this gives us

* We can run the base system.
* We can inspect raw artifacts.
* We can see trace timing in Jaeger.
* We can document limitations before adding eval systems.

### What this does not give us yet

* automatic correctness scoring
* semantic evaluation
* retrieval quality metrics
* interactive MCP developer tools
* production-grade tracing stack
* multi-model experiment comparison

---

## 6. Milestones and Small Commits

## Milestone 0: Repository Import and Baseline Preservation

### Goal

Bring the DCI base into our repo cleanly without changing behavior.

### Commit 0.1: Initial import

**Purpose:** Add the base repo exactly as the starting point.

**Create/edit files:**

* `README.md`
* `LICENSE`
* `pyproject.toml`
* `.gitignore`
* `.env.example`
* `src/dci/`
* `scripts/`
* `prompts/`
* `assets/` or `docs/`, depending on imported repo structure

**Acceptance criteria:**

* Repo installs locally.
* Original documented commands are still recognizable.
* No architecture changes yet.
* License is preserved.

**Notes:**

Keep this commit boring. It should be the clean fossil layer.

---

### Commit 0.2: Add project-level README note

**Purpose:** Explain that this repo is a modified DCI-based research harness.

**Create/edit files:**

* `README.md`

**README should include:**

* What the project is.
* What it is based on.
* What is implemented now.
* What is intentionally deferred.
* Where run artifacts are written.
* Short local running command reference.

**Acceptance criteria:**

* A new developer can understand the repo goal in under two minutes.
* No code behavior changes.

---

### Commit 0.3: Add milestone document

**Purpose:** Add this document to the repo.

**Create/edit files:**

* `docs/development_milestones.md`

**Acceptance criteria:**

* This milestone plan is versioned.
* Later changes can update the plan instead of floating in chat.

---

## Milestone 1: Local Running Baseline

### Goal

Make one local run reproducible and documented.

The DCI repo already documents a Python RPC wrapper and local running flow, including use of provider, model, corpus path, tools, max turns, and runtime context-management levels.

---

### Commit 1.1: Add local running guide

**Purpose:** Document the smallest successful run.

**Create/edit files:**

* `docs/running_local.md`

**Document should include:**

* prerequisites
* environment setup
* where `.env` comes from
* how to run one example
* where artifacts appear
* how to inspect `final.txt`
* how to inspect `stderr.txt`
* known failure modes

**Acceptance criteria:**

* A developer can reproduce one run using the doc.
* No benchmark or evaluation required.

---

### Commit 1.2: Add example question file

**Purpose:** Avoid typing long commands manually.

**Create/edit files:**

* `examples/questions/smoke_test.txt`

**Content requirements:**

* One simple question.
* No dependency on external network.
* Designed to run quickly.

**Acceptance criteria:**

* The question can be used for a smoke test.
* The output directory is created.
* `final.txt` exists after a successful run.

---

### Commit 1.3: Add outputs directory placeholder

**Purpose:** Make artifact location visible but avoid committing actual runs.

**Create/edit files:**

* `outputs/.gitkeep`
* `.gitignore`

**Rules:**

* Commit `outputs/.gitkeep`.
* Ignore generated run outputs.
* Ignore local corpora if too large.
* Ignore `.env`.

**Acceptance criteria:**

* `outputs/` exists in a clean checkout.
* Generated run artifacts are not committed accidentally.

---

## Milestone 2: Documentation Cleanup and Architecture Record

### Goal

Write down the architecture we are actually using, not the architecture we imagined.

---

### Commit 2.1: Add architecture document

**Purpose:** Explain the first-iteration architecture.

**Create/edit files:**

* `docs/architecture.md`

**Document should include:**

* DCI as base.
* Runner as main execution entrypoint.
* Local corpus interaction.
* Artifact-first debugging.
* OpenTelemetry observability.
* Explicitly deferred eval/MCP/Pydantic AI work.

**Acceptance criteria:**

* The architecture document matches the actual repo.
* No mention of unimplemented components as if they already exist.

---

### Commit 2.2: Add limitations document section

**Purpose:** Avoid overclaiming.

**Create/edit files:**

* `docs/architecture.md`
* or `docs/limitations.md`

**Limitations to mention:**

* No automatic evaluation in iteration one.
* No semantic correctness checking.
* No RAGAS/DeepEval metrics yet.
* No Inspect AI orchestration yet.
* No MCP server yet.
* No production deployment.
* No guarantee that traces explain model reasoning.
* No guarantee that artifact logs capture every model-side behavior.
* No database-backed run history.

**Acceptance criteria:**

* The repo honestly states what it cannot do yet.

---

## Milestone 3: OpenTelemetry Instrumentation

### Goal

Add minimal tracing without changing the agent behavior.

OpenTelemetry should trace the harness, not rewrite the harness. The OpenTelemetry docs describe the Collector as a way to receive, process, and export telemetry, while OTLP defines the encoding, transport, and delivery mechanism between telemetry sources, collectors, and backends.

---

### Commit 3.1: Add observability module skeleton

**Purpose:** Create a clear place for tracing setup.

**Create/edit files:**

* `src/dci/observability/__init__.py`
* `src/dci/observability/tracing.py`
* `docs/observability.md`

**No concrete implementation details in docs yet.**

**Document should explain:**

* What spans are planned.
* What metadata is safe to record.
* What should not be recorded.
* How traces relate to artifacts.

**Acceptance criteria:**

* Observability has a dedicated module.
* Docs explain tracing intent.

---

### Commit 3.2: Add run-level spans

**Purpose:** Trace the lifecycle of one run.

**Create/edit files:**

* runner entrypoint file
* `src/dci/observability/tracing.py`
* `docs/observability.md`

**Spans to add:**

* `dci.run`
* `dci.runner.prepare`
* `dci.subprocess.start`
* `dci.subprocess.wait`
* `dci.artifacts.collect`
* `dci.run.finish`

**Suggested span attributes:**

* `run_id`
* `output_dir`
* `provider`
* `model`
* `corpus_dir`
* `tools`
* `max_turns`
* `context_management_level`
* `exit_code`
* `success`

**Acceptance criteria:**

* Running one smoke test creates trace spans.
* Agent behavior is unchanged.
* Failure paths are traced.

---

### Commit 3.3: Add artifact-level span events

**Purpose:** Make artifact generation visible in traces.

**Create/edit files:**

* artifact handling module
* `src/dci/observability/tracing.py`
* `docs/observability.md`

**Events to record:**

* `artifact.final_written`
* `artifact.stderr_written`
* `artifact.events_written`
* `artifact.conversation_written`
* `artifact.latest_context_written`

**Attributes to record carefully:**

* file path
* file size
* whether file exists
* character count for `final.txt`

**Do not record:**

* full final answer text
* full conversation content
* API keys
* secrets
* full corpus passages

**Acceptance criteria:**

* Trace confirms which artifacts were produced.
* No sensitive content is exported to Jaeger.

---

## Milestone 4: Docker Observability Stack

### Goal

Run local tracing with Docker Compose.

---

### Commit 4.1: Add OpenTelemetry Collector config

**Purpose:** Configure the collector as the telemetry gateway.

**Create/edit files:**

* `configs/otel-collector.yaml`
* `docs/observability.md`

**Config should support:**

* receiving OTLP traces
* exporting traces to Jaeger
* local development only

**Acceptance criteria:**

* Config is documented.
* No production claims.

---

### Commit 4.2: Add Docker Compose for Jaeger + OTel Collector

**Purpose:** Give developers a one-command local observability stack.

**Create/edit files:**

* `docker/docker-compose.observability.yml`
* `docs/observability.md`

**Services:**

* `otel-collector`
* `jaeger`

**Do not add yet:**

* Grafana
* Tempo
* Prometheus
* Loki
* Postgres
* Redis

**Acceptance criteria:**

* Compose stack starts locally.
* Jaeger UI is reachable.
* One smoke test produces visible traces.

---

### Commit 4.3: Add observability smoke-test instructions

**Purpose:** Document how to verify traces.

**Create/edit files:**

* `docs/observability.md`

**Document should include:**

* how to start Docker Compose
* how to run the smoke test
* how to find the service in Jaeger
* what spans should appear
* what to check if traces do not appear

**Acceptance criteria:**

* A developer can verify tracing without reading source code.

---

## Milestone 5: Roadmap for Deferred Evaluation Work

### Goal

Keep eval ideas documented but not implemented.

Inspect AI should eventually be considered as an experiment harness. Inspect documentation describes an evaluation task as combining a dataset, a solver, and a scorer.

DeepEval and RAGAS should be considered later as metric plugins, not first-iteration foundations. DeepEval describes itself as an LLM evaluation framework similar to Pytest for LLM apps, while RAGAS emphasizes experiments and metrics for LLM applications.

---

### Commit 5.1: Add later-roadmap document

**Purpose:** Prevent scope creep while preserving ideas.

**Create/edit files:**

* `docs/roadmap_later.md`

**Sections to include:**

* Evaluation later
* MCP later
* Pydantic models later
* Pydantic AI sidecar later
* Tempo/Grafana later
* Database later
* CI later

**Acceptance criteria:**

* Future tools are listed as future work only.
* No user of the repo thinks these features exist yet.

---

### Commit 5.2: Add eval-later section

**Purpose:** Explain how Inspect AI, DeepEval, and RAGAS differ.

**Create/edit files:**

* `docs/roadmap_later.md`

**Recommended wording:**

* Inspect AI: future experiment runner and scorer host.
* DeepEval: future LLM-as-judge / semantic quality metrics.
* RAGAS: future retrieval-grounding metrics if retrieved context can be extracted reliably.
* Deterministic checks should come before LLM-judge metrics.

**Acceptance criteria:**

* Eval tools are clearly separated.
* No eval dependency is added in this commit.

---

## Milestone 6: Roadmap for MCP, FastMCP, and Pydantic Tools

### Goal

Clarify how MCP/FastMCP/Pydantic could support the project later without replacing the DCI core.

MCP tools let servers expose executable capabilities to language models, MCP resources expose data such as files or application-specific information, and MCP prompts expose reusable prompt templates.

FastMCP is useful later because it provides a Pythonic way to build MCP servers, clients, and apps.

Pydantic is useful earlier than Pydantic AI because it validates typed data structures. The official docs describe Pydantic as a Python data validation library that defines how data should be and validates it.

Pydantic AI can be considered later because it supports MCP and can connect agents to MCP servers through MCP toolsets.

---

### Commit 6.1: Add Pydantic artifact-schema plan

**Purpose:** Plan typed parsing of run artifacts without implementing it yet.

**Create/edit files:**

* `docs/roadmap_later.md`
* optionally `docs/artifact_schema_plan.md`

**Future files to create later:**

* `src/dci/artifacts/models.py`
* `src/dci/artifacts/parser.py`
* `src/dci/artifacts/summary.py`

**Future models to define later:**

* `RunConfig`
* `RunArtifact`
* `RunSummary`
* `RpcEvent`
* `ConversationMessage`
* `ToolCallEvent`
* `ModelTurnEvent`
* `ArtifactManifest`

**Advantage:**

Typed artifact parsing will make later evals safer. Instead of scripts guessing JSON structure, the repo can validate artifact files before scoring or comparing runs.

**Limitation:**

This does not improve agent quality directly. It only improves developer reliability.

---

### Commit 6.2: Add FastMCP artifact-inspector plan

**Purpose:** Define a future MCP server for developer use.

**Create/edit files:**

* `docs/roadmap_later.md`
* optionally `docs/mcp_later.md`

**Future files to create later:**

* `src/dci/mcp_server/__init__.py`
* `src/dci/mcp_server/artifact_tools.py`
* `src/dci/mcp_server/resources.py`
* `src/dci/mcp_server/prompts.py`

**Future MCP capabilities:**

Tools:

* `list_runs`
* `summarize_run`
* `compare_runs`
* `read_run_stderr`
* `read_run_final`
* `find_failed_runs`

Resources:

* `run://<run_id>/final`
* `run://<run_id>/events`
* `run://<run_id>/conversation`
* `run://<run_id>/latest_context`

Prompts:

* `summarize_failure`
* `compare_two_runs`
* `write_repro_steps`

**Advantage:**

This would let a developer inspect run artifacts through MCP-compatible clients without opening many JSON files manually.

**Limitation:**

This is a developer-assistance layer. It should not be used to change benchmark agent behavior unless explicitly running a separate experiment.

---

### Commit 6.3: Add corpus-explorer MCP plan

**Purpose:** Define a future read-only corpus explorer.

**Create/edit files:**

* `docs/mcp_later.md`

**Future capabilities:**

* list corpus subsets
* list domain folders
* search corpus text
* inspect document metadata
* read bounded document windows
* compute corpus statistics

**Advantage:**

Useful for humans and sidecar agents to understand corpus structure.

**Limitation:**

If exposed to the benchmark agent, it may change the baseline. For first research comparisons, keep the DCI direct-corpus interaction unchanged.

---

### Commit 6.4: Add Pydantic AI sidecar plan

**Purpose:** Define a future assistant that helps debug runs, not replace the core runner.

**Create/edit files:**

* `docs/roadmap_later.md`
* optionally `docs/sidecar_assistant_later.md`

**Future files to create later:**

* `src/dci/sidecar/__init__.py`
* `src/dci/sidecar/agent.py`
* `src/dci/sidecar/prompts.py`

**Future sidecar tasks:**

* explain why a run failed
* summarize stderr
* compare two run artifacts
* identify repeated tool failures
* suggest next experiment
* generate a human-readable run report

**Advantage:**

This uses agent tooling to help the developer, while preserving the benchmark agent as the tested subject.

**Limitation:**

Sidecar analysis should not be mixed into benchmark scores unless documented as part of the experiment.

---

## 7. Later Work List

This list is intentionally not part of the first implementation.

### Evaluation later

Future structure:

```text
DCI runner
  -> run artifacts
  -> artifact parser
  -> Inspect AI task wrapper
  -> deterministic scorer
  -> optional DeepEval scorer
  -> optional RAGAS scorer
  -> comparison report
```

Potential files later:

* `src/dci/eval/__init__.py`
* `src/dci/eval/inspect_task.py`
* `src/dci/eval/scorers_deterministic.py`
* `src/dci/eval/scorers_deepeval.py`
* `src/dci/eval/scorers_ragas.py`
* `docs/evaluation_later.md`

### Tempo / Grafana later

Future structure:

```text
app -> OTel Collector -> Tempo -> Grafana
```

Use this when Jaeger becomes too limited for larger runs, dashboards, or trace-log-metric correlation. Tempo is designed as a high-scale tracing backend and integrates with Grafana and other Grafana ecosystem tools.

Potential files later:

* `docker/docker-compose.observability.full.yml`
* `configs/tempo.yaml`
* `configs/grafana/`
* `docs/observability_full_stack.md`

### Database later

Only add a database when filesystem artifacts become hard to query.

Possible uses:

* run metadata index
* experiment comparison table
* model/config registry
* failure labels
* score history

Do not add Postgres in iteration one.

### Redis later

Only add Redis if we need:

* queue-backed parallel runs
* caching
* distributed workers
* rate limiting

Do not add Redis in iteration one.

---

## 8. First Iteration Done Definition

The first iteration is complete when:

* The DCI base is imported cleanly.
* One smoke-test run works.
* Run artifacts are written under `outputs/runs/<timestamp>/`.
* Architecture and running docs exist.
* OpenTelemetry spans are emitted.
* OTel Collector and Jaeger run locally through Docker Compose.
* A developer can see a trace for one run in Jaeger.
* Deferred tools are documented but not implemented.

The first iteration is **not** complete if:

* eval libraries are half-wired
* MCP server is half-built
* Pydantic AI replaces the baseline runner
* Docker Compose contains unused services
* docs claim features that do not exist
* generated run artifacts are committed

---

## 9. Advantages of the Discussed Tools

### OpenTelemetry

Advantage:

* Lets us see run lifecycle, subprocess duration, artifact creation, and errors.
* Keeps backend flexible through the Collector.
* Useful immediately.

Limitation:

* Does not judge answer quality.
* Does not explain private model reasoning.
* Can leak sensitive data if span attributes are careless.

### Jaeger

Advantage:

* Simple local trace UI.
* Good first backend for debugging traces.
* Smaller operational load than a full Grafana stack.

Limitation:

* Best for local/debug tracing, not necessarily long-term experiment analytics.

### Tempo

Advantage later:

* Better fit for high-volume tracing and Grafana integration.
* Can link traces with logs and metrics in the Grafana ecosystem.

Limitation:

* Too much for first iteration.

### Inspect AI

Advantage later:

* Can become the experiment harness.
* Has a clear task model: dataset, solver, scorer.

Limitation:

* Not needed before the base runner is stable.
* Could confuse the architecture if added too early.

### DeepEval

Advantage later:

* Useful for semantic checks and LLM-as-judge metrics.
* Similar in spirit to Pytest for LLM apps.

Limitation:

* May introduce judge-model noise.
* Should not replace deterministic checks.

### RAGAS

Advantage later:

* Useful for retrieval-grounding metrics when context can be cleanly extracted.
* Supports metrics and experiment-style workflows for LLM applications.

Limitation:

* Less useful until we have structured retrieved context.
* DCI direct-corpus interaction may not map neatly to standard RAG input fields.

### MCP / FastMCP

Advantage later:

* Good for developer tools around artifacts and corpus exploration.
* FastMCP can help expose Python functions as MCP capabilities.

Limitation:

* Should not replace DCI baseline tools in the first iteration.
* Tool descriptions and tool surface area can create model-selection overhead.

### Pydantic

Advantage later:

* Strong fit for validating run configs and artifact structures.
* Helps prevent silent parsing errors.

Limitation:

* Does not solve agent behavior or retrieval quality by itself.

### Pydantic AI

Advantage later:

* Useful for a sidecar debugging assistant.
* Can connect to MCP servers through MCPToolset.

Limitation:

* Should not replace the DCI/Pi runner unless we intentionally start a separate experiment branch.

---

## 10. Recommended Commit Order Summary

```text
0.1  Import DCI base
0.2  Add project README note
0.3  Add development milestones document

1.1  Add local running guide
1.2  Add smoke-test question file
1.3  Add outputs placeholder and gitignore rules

2.1  Add architecture document
2.2  Add limitations section/document

3.1  Add observability module skeleton
3.2  Add run-level OpenTelemetry spans
3.3  Add artifact-level span events

4.1  Add OTel Collector config
4.2  Add Docker Compose for OTel Collector + Jaeger
4.3  Add observability smoke-test instructions

5.1  Add later-roadmap document
5.2  Add eval-later section

6.1  Add Pydantic artifact-schema plan
6.2  Add FastMCP artifact-inspector plan
6.3  Add corpus-explorer MCP plan
6.4  Add Pydantic AI sidecar plan
```

---

## 11. Final First-Iteration Position

The repo should not try to be everything immediately.

The correct first shape is:

```text
DCI base
  + clean docs
  + reproducible smoke run
  + artifact-first workflow
  + OpenTelemetry tracing
  + OTel Collector
  + Jaeger
```

The correct later shape is:

```text
DCI base
  + typed artifact parsing
  + MCP developer tools
  + sidecar debugging assistant
  + Inspect AI experiment wrapper
  + DeepEval/RAGAS scoring adapters
  + richer observability backend if needed
```

This path keeps the project grounded in a real research baseline while still leaving room for strong engineering later.

