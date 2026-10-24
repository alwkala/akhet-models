# Akhet-Ra1 Roadmap

This document outlines the milestones, planned development phases, and validation criteria for the **Akhet-Ra1** language model within the **AkhetRa** ecosystem.

---

## Current Status: Phase 1 — Specification & Local Artifacts (v0.1.0)

- [x] Define Model Card and ecosystem boundaries (Ra = Intelligence, Akhet = Runtime/Governance).
- [x] Package local GGUF 4B checkpoint (`Ra-1-4B-Q4_K_M.gguf`).
- [x] Implement local PowerShell execution scripts (`run-Ra-tui.ps1` and `run-Ra-0.ps1`).
- [x] Document hardware offload profiles (6GB VRAM, 32K context, Flash Attention, `q4_0` KV cache).
- [x] Author and package production System Prompt templates (`system_prompt.txt` & `SYSTEM_PROMPT.md`).
- [x] Establish bilingual documentation (`README.md` and `MODEL_CARD_AR.md`).

---

## Phase 2: Evaluation & Benchmark Execution (In-Progress)

- [/] Author bilingual evaluation harness ([eval_akhet_ra1.py](eval_akhet_ra1.py)) supporting latency, tokens/sec, and semantic keyword verification based on `huggingface-community-evals` patterns.
- [ ] Execute standardized Arabic evaluation suite (`ArabicMMLU`).
- [ ] Benchmark dialect comprehension on Egyptian Arabic conversational sets.
- [ ] Measure instruction following score using `IFEval`.
- [ ] Evaluate mathematical and logical reasoning using `GSM8K` and `ARC-Challenge`.
- [ ] Verify structured output compliance (JSON Schema validity).
- [ ] Run Berkeley Function Calling Leaderboard (BFCL) compatibility tests.
- [ ] Audit for dataset decontamination across all test sets.

---

## Phase 3: Runtime & Akhet Governance Integration (Planned)

- [ ] Connect Akhet-Ra1 to the Akhet runtime sandboxing protocol.
- [ ] Implement strict schema verification for all tool calls before dispatch.
- [ ] Integrate session memory and context budgeting controllers.
- [ ] Configure human-in-the-loop validation triggers for sensitive system actions.
- [ ] Implement tamper-evident execution audit logging.

---

## Phase 4: Distribution & Model Checkpoints (Active / In-Progress)

- [x] Publish official model repository on Hugging Face under Alwkala Digital Labs ([alwkala/Akhet-Ra1](https://huggingface.co/alwkala/Akhet-Ra1)).
- [x] Integrate Hugging Face Agent Skills suite (`.agents/skills`) from `huggingface/skills` for repository management, memory estimation, and evaluation.
- [x] Provide GGUF primary quantization: `Q4_K_M` (`Ra-1-4B-Q4_K_M.gguf`, 2.52 GB).
- [x] Provide automated LM Studio and Ollama model manifests / Modelfiles and direct Hub execution one-liners (`llama-cli -hf`, `llama-server --hf-repo`, `ollama run hf.co`).
- [/] Scaffold interactive Hugging Face Spaces Gradio demo ([space/app.py](space/app.py)).
- [ ] Provide additional GGUF quantizations: `Q5_K_M`, `Q8_0`.
- [ ] Release unquantized `BF16` safetensors for fine-tuning and reference inference.
