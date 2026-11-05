# Changelog

All notable changes to the **Akhet Models** repository and model packages are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2026-11-05

### Added
- **Central Model Monorepo Evolution**: Restructured repository into a multi-model ecosystem hosting both the **Ra Series** (Deep Reasoning & Cognition) and the **Aton Series** (Multimodal Vision & Edge Agents).
- **Akhet-Aton-2B Model Integration (`models/Aton-2B`)**: Integrated full model package for the 2.23B parameter multimodal edge model:
  - Complete English Model Card ([MODEL_CARD.md](models/Aton-2B/MODEL_CARD.md)) and Arabic Model Card ([MODEL_CARD_AR.md](models/Aton-2B/MODEL_CARD_AR.md)).
  - Local system prompt specification ([system_prompt_aton.txt](models/Aton-2B/system_prompt_aton.txt)).
  - VRAM-adaptive launcher with automatic topology detection ([run-Aton-Adaptive.ps1](models/Aton-2B/run-Aton-Adaptive.ps1)).
  - Agent-tools-enabled launcher ([run-Aton-Adaptive-tools.ps1](models/Aton-2B/run-Aton-Adaptive-tools.ps1)).
- **Multimodal Benchmark Harness (`evals/eval_aton_2b.py`)**: Added automated evaluation runner for Arabic document OCR, strict schema JSON extraction, tool calling, and token generation latency.
- **TidyFactor GitHub Governance Framework**:
  - Structured issue template forms (`.github/ISSUE_TEMPLATE/bug_report.yml`, `.github/ISSUE_TEMPLATE/feature_request.yml`, `.github/ISSUE_TEMPLATE/config.yml`).
  - Standardized pull request template (`.github/PULL_REQUEST_TEMPLATE.md`).
  - Open source governance policies: [CONTRIBUTING.md](CONTRIBUTING.md), [SECURITY.md](SECURITY.md), and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
- **Flagship Multi-Model Documentation**: Rewrote root [README.md](README.md) featuring dual model badges, multi-layer architecture diagram, unified model catalog table, and hardware memory scaling matrices for both models.

### Changed
- Updated [evals/README.md](evals/README.md) with comprehensive instructions for running both Ra-1 and Aton-2B evaluation runners.
- Updated [.gitignore](.gitignore) to explicitly ignore multimodal vision projector weights (`*.mmproj`).
- Updated project roadmap in [ROADMAP.md](ROADMAP.md) reflecting Phase 4 completion and Phase 5 activation.

---

## [0.2.0] - 2026-10-24

- **Hugging Face Skills Integration (`huggingface/skills`)**: Imported and registered the official 25-skill suite into `.agents/skills` for agentic Hub governance and automated operations.
- **Hugging Face Direct Execution Standards**: Enhanced documentation with direct Hub one-liner execution syntax (`llama-cli -hf`, `llama-server --hf-repo`, and `ollama run hf.co`) without requiring manual downloads.
- **Ollama Modelfile Manifest**: Documented standard Ollama `Modelfile` configuration with ChatML/Qwen template, stop tokens, and parameters for local containerized deployment.
- **Granular Hardware & KV Cache Profiling**: Added detailed memory estimation scaling table (4K to 32K context windows) calibrated using `hf-mem` formulas for 4.2B parameters and Q4_K_M quant (`-ctk q4_0 -ctv q4_0`).
- **Benchmark Evaluation Harness**: Authored [eval_akhet_ra1.py](evals/eval_akhet_ra1.py) based on `huggingface-community-evals` patterns, enabling bilingual testing across Arabic reasoning, Egyptian dialect, tool calling, GSM8K math, and safety refusals.
- **Hugging Face Spaces Interactive Demo**: Created deployment bundle in `spaces/Ra-1-demo` configured for Gradio ZeroGPU deployment.
- **Publisher Script Security**: Updated upload scripts to sync evaluation scripts and exclude temporary agent artifacts.

---

## [0.1.0] - 2026-10-23

- **Hugging Face Hub Distribution & Automation**: Configured repository tracking for [alwkala/Akhet-Ra1](https://huggingface.co/alwkala/Akhet-Ra1). Added `.gitattributes` with explicit `*.gguf` LFS tracking, `.gitignore` to shield local caches, and automated upload scripts.
- **Hugging Face Model Card Alignment**: Updated metadata frontmatter, added direct GGUF CLI and Python download instructions, and integrated LM Studio quick-start steps.
- **Comprehensive GGUF Metadata Enhancement**: Successfully injected full GGUF standard metadata into `Ra-1-4B-Q4_K_M.gguf`.
- **System Prompt Templates & Specification**: Created foundational alignment, bilingual personality, tool calling, and governance-aware boundaries for Akhet-Ra1.
- **Verified GGUF Metadata Extraction**: Extracted exact internal model parameters directly from weights: 4.2B parameters, 256K native training context, Qwen3.5 hybrid SSM + Attention architecture, Apache-2.0 license.
- **Empirical Behavioral Verification**: Verified active Chain-of-Thought reasoning support (`reasoning_content` / `<think>`), native function calling, and Arabic/Egyptian dialect comprehension.
