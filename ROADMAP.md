# Akhet Models Roadmap

This document outlines the development phases, milestones, and releases for the **Akhet Models** family ([alwkala/akhet-models](https://github.com/alwkala/akhet-models)) by **Alwkala Digital Labs**.

---

## Phase 1: Specification & Local Artifacts (v0.1.0) — Completed

- [x] Define multi-layer architectural boundary (Intelligence Layer vs Governance Runtime).
- [x] Package local GGUF 4B checkpoint (`Ra-1-4B-Q4_K_M.gguf`).
- [x] Implement local PowerShell execution scripts (`run-Ra-tui.ps1` and `run-Ra-0.ps1`).
- [x] Document hardware offload profiles (6GB VRAM, 32K context, Flash Attention, `q4_0` KV cache).
- [x] Author and package production System Prompt templates (`system_prompt.txt` & `SYSTEM_PROMPT.md`).
- [x] Establish bilingual documentation (`README.md` and `MODEL_CARD_AR.md`).

---

## Phase 2: Evaluation & Benchmark Execution (v0.2.0) — Completed

- [x] Author bilingual evaluation harness ([evals/eval_akhet_ra1.py](evals/eval_akhet_ra1.py)) supporting latency, tokens/sec, and semantic verification based on `huggingface-community-evals` patterns.
- [x] Author multimodal evaluation harness ([evals/eval_aton_2b.py](evals/eval_aton_2b.py)) for Arabic OCR, schema validation, and edge latency.
- [x] Add Granular Hardware & KV Cache Profiling (4K to 32K context windows) calibrated with `hf-mem` formulas.
- [/] Execute standardized Arabic evaluation suite (`ArabicMMLU`).
- [/] Benchmark dialect comprehension on Egyptian Arabic conversational sets.
- [ ] Measure instruction following score using `IFEval`.
- [ ] Evaluate mathematical and logical reasoning using `GSM8K` and `ARC-Challenge`.
- [ ] Run Berkeley Function Calling Leaderboard (BFCL) compatibility tests.

---

## Phase 3: Runtime & Akhet Governance Integration — In Progress

- [/] 3-Ring Context Firewall integration (Ring 0: Identity, Ring 1: Sandboxing, Ring 2: Memory).
- [/] SQLite FTS5 WAL local persistent memory engine with BM25 hybrid retrieval.
- [/] Local Stdio Model Context Protocol (MCP) server integration.
- [ ] Strict schema verification for all tool calls before dispatch.
- [ ] Human-in-the-loop validation triggers for sensitive system actions.
- [ ] Tamper-evident execution audit logging.

---

## Phase 4: Model Distribution & Hub Ecosystem (v0.2.0) — Completed

- [x] Publish official model repository on Hugging Face under Alwkala Digital Labs ([alwkala/Akhet-Ra1](https://huggingface.co/alwkala/Akhet-Ra1)).
- [x] Publish official multimodal model on Hugging Face ([alwkala/Aton](https://huggingface.co/alwkala/Aton)).
- [x] Provide primary GGUF quantizations (`Ra-1-4B-Q4_K_M.gguf`, `Aton-2B-Q4_K_M.gguf`, `Aton-2B-F16-mmproj.gguf`).
- [x] Provide automated LM Studio and Ollama manifests and direct Hub execution one-liners (`llama-cli -hf`, `llama-server --hf-repo`, `ollama run hf.co`).
- [x] Deploy interactive Hugging Face Spaces Gradio demo ([Akhet-Chat](https://huggingface.co/spaces/alwkala/Akhet-Chat)).
- [ ] Provide additional GGUF quantizations: `Q5_K_M`, `Q8_0`.
- [ ] Release unquantized `BF16` safetensors for fine-tuning and reference inference.

---

## Phase 5: Multi-Model Monorepo & Edge Agent Swarms (v0.3.0) — Active

- [x] Restructure `akhet-models` repository into Central Model Monorepo & AI Hub.
- [x] Integrate **Akhet-Aton-2B** (2.23B parameter Multimodal Edge Agent) into `models/Aton-2B/`.
- [x] Author VRAM-adaptive PowerShell runners (`run-Aton-Adaptive.ps1`, `run-Aton-Adaptive-tools.ps1`).
- [x] Author Arabic and English model cards for Aton-2B (`MODEL_CARD.md`, `MODEL_CARD_AR.md`).
- [x] Add open-source community governance standards (`.github/`, `CONTRIBUTING.md`, `SECURITY.md`, `CODE_OF_CONDUCT.md`).
- [ ] Implement collaborative agent swarms (Aton Edge Triage Agent -> Ra Reasoning Core -> Akhet Governance Gate).
- [ ] WebGPU in-browser inference runtime for offline web applications.
