# 𓂀 Akhet Models (`akhet-models`)

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Hugging Face Ra-1](https://img.shields.io/badge/%F0%9F%A4%97%20Hugging%20Face-alwkala%2FAkhet--Ra1-yellow)](https://huggingface.co/alwkala/Akhet-Ra1)
[![Hugging Face Aton](https://img.shields.io/badge/%F0%9F%A4%97%20Hugging%20Face-alwkala%2FAton-blue)](https://huggingface.co/alwkala/Aton)
[![Architecture: Hybrid SSM+Attention](https://img.shields.io/badge/Architecture-Hybrid%20SSM%2BAttention-indigo)](#)
[![Deployment: Local--First](https://img.shields.io/badge/Deployment-Local--First-green)](#)
[![Organization: Alwkala Digital Labs](https://img.shields.io/badge/Org-Alwkala%20Digital%20Labs-orange)](https://alwkala.com)

**Central Model Monorepo & AI Hub for local-first language and multimodal vision models, agentic runtimes, evaluation harnesses, and hardware-adaptive launchers by [Alwkala Digital Labs](https://alwkala.com).**

---

## 🏛️ 1. Multi-Model Architecture & Ecosystem

The **Akhet** ecosystem decouples cognitive reasoning, edge automation, and execution governance into specialized layers:

```
                           ┌──────────────────────────────────────────────┐
                           │                    AKHET                     │
                           │           Central Model Monorepo             │
                           └──────────────────────┬───────────────────────┘
                                                  │
                  ┌───────────────────────────────┼───────────────────────────────┐
                  │                               │                               │
                  ▼                               ▼                               ▼
    ┌───────────────────────────┐   ┌───────────────────────────┐   ┌───────────────────────────┐
    │         RA SERIES         │   │        ATON SERIES        │   │        AKHET LAYER        │
    │     Deep Reasoning (4B)   │   │   Multimodal Vision (2B)  │   │    Runtime & Governance   │
    ├───────────────────────────┤   ├───────────────────────────┤   ├───────────────────────────┤
    │ • Hybrid SSM + Attention  │   │ • 1.9B SSM/Attn + 331M VLM│   │ • Policy Enforcement Gate │
    │ • Deep Structured Thought │   │ • CLIP ViT-L/14 Vision    │   │ • 3-Ring Context Firewall │
    │ • Bilingual Arabic & EN   │   │ • Arabic Document & OCR   │   │ • SQLite FTS5 WAL Memory  │
    │ • Long-Context Synthesis  │   │ • Edge System Automation  │   │ • Local Stdio MCP Server  │
    └───────────────────────────┘   └───────────────────────────┘   └───────────────────────────┘
```

* **Ra Series (رع — Deep Reasoning & Cognition):** General-purpose generative and reasoning models engineered for complex analytical thinking, mathematical problem solving, long-context document understanding, and cultural fluency in Modern Standard Arabic and Egyptian dialect.
* **Aton Series (آتون — Edge Agent & Multimodal Vision):** Lightweight, sub-second latency multimodal models coupling a 1.9B hybrid text decoder with a 331M CLIP ViT-L/14 vision projector. Calibrated for local desktop assistance, triage classification, schema-strict JSON extraction, IoT/automation function calling, and Arabic document OCR.
* **Akhet Layer (آخت — Governance & Memory Runtime):** Deterministic execution runtime providing a 3-Ring Context Firewall, persistent SQLite FTS5 WAL memory, and standard Model Context Protocol (MCP) tooling.

---

## 📚 2. Unified Model Catalog

All model weights and quantizations are hosted directly on the **[Alwkala Hugging Face Hub](https://huggingface.co/alwkala)**:

| Model | Parameters | Modality | Architecture | Context (Native / SFT) | Formats | Hugging Face Hub | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **[Akhet-Ra1](models/Ra-1)** | 4.2B | Text + Code | Hybrid SSM + Attention (Qwen3.5) | 256K / 32K | GGUF (`Q4_K_M`) | [alwkala/Akhet-Ra1](https://huggingface.co/alwkala/Akhet-Ra1) | 🟢 Released |
| **[Akhet-Aton-2B](models/Aton-2B)** | 2.23B | Vision + Text | Hybrid SSM + Attention + CLIP ViT-L/14 | 256K / 2K | GGUF (`Q4_K_M`, `mmproj`) | [alwkala/Aton](https://huggingface.co/alwkala/Aton) | 🟢 Released |
| **Akhet-Ra2** | *TBD* | Multimodal | Next-Gen Mixture / Vision | 512K / 64K | GGUF / SafeTensors | *Coming Soon* | 🟡 Planned |

---

## ⚡ 3. Quick-Start Execution

Weights are fetched directly from the Hugging Face Hub without requiring full-repository binary clones:

### Akhet-Ra1 (4.2B Reasoning)

```bash
# Option A: Local OpenAI-compatible server (llama-server)
llama-server \
  --hf-repo alwkala/Akhet-Ra1 \
  --hf-file Ra-1-4B-Q4_K_M.gguf \
  --alias "Akhet-Ra-1" \
  -c 32768 -ngl 99 --port 8080

# Option B: One-click Ollama CLI
ollama run hf.co/alwkala/Akhet-Ra1:Ra-1-4B-Q4_K_M.gguf

# Option C: Direct streaming terminal session
llama-cli -hf alwkala/Akhet-Ra1:Ra-1-4B-Q4_K_M.gguf -p "أنت مساعد ذكي محلي خاضع لمنظومة آخت-رع." -cnv
```

### Akhet-Aton-2B (2.23B Multimodal Vision & Edge Agent)

```bash
# Option A: llama-server with coupled Vision Projector
llama-server \
  -m Aton-2B-Q4_K_M.gguf \
  --mmproj Aton-2B-F16-mmproj.gguf \
  --alias "Akhet-Aton-2B" \
  -c 8192 -ngl 99 --port 8080

# Option B: VRAM-Adaptive Launcher (PowerShell)
.\models\Aton-2B\run-Aton-Adaptive.ps1

# Option C: VRAM-Adaptive Launcher with Local Agent Tools
.\models\Aton-2B\run-Aton-Adaptive-tools.ps1
```

---

## 📊 4. Memory & Hardware Scaling Profiles

### Akhet-Ra1 (4.2B Parameters, `Q4_K_M` ~2.52 GB Weights)

| Context Window | Model Weights VRAM | KV Cache (`q4_0`) | Total VRAM (`q4_0`) | Target Hardware |
| :--- | :--- | :--- | :--- | :--- |
| **4,096 (4K)** | 2.52 GB | ~0.35 GB | **~2.87 GB** | 4GB GPUs (GTX 1650, RTX 3050) / Apple M-Series |
| **8,192 (8K)** | 2.52 GB | ~0.70 GB | **~3.22 GB** | 4GB – 6GB GPUs |
| **16,384 (16K)** | 2.52 GB | ~1.40 GB | **~3.92 GB** | 6GB VRAM GPUs |
| **32,768 (32K)** | 2.52 GB | ~2.80 GB | **~5.32 GB** | 6GB – 8GB VRAM GPUs (`-ctk q4_0 -ctv q4_0`) |

### Akhet-Aton-2B (2.23B Parameters, `Q4_K_M` 1.31 GB + `mmproj` 0.67 GB)

| Context Window | Weights + Vision VRAM | KV Cache (`q4_0`) | Total VRAM (`q4_0`) | Target Hardware |
| :--- | :--- | :--- | :--- | :--- |
| **2,048 (2K)** | 1.98 GB | ~0.18 GB | **~2.16 GB** | Budget 4GB Laptops / Integrated Graphics / CPU |
| **4,096 (4K)** | 1.98 GB | ~0.35 GB | **~2.33 GB** | 4GB GPUs / Apple Silicon |
| **8,192 (8K)** | 1.98 GB | ~0.70 GB | **~2.68 GB** | Standard desktop OCR & multi-page invoices |
| **16,384 (16K)** | 1.98 GB | ~1.40 GB | **~3.38 GB** | 4GB – 6GB GPUs |

---

## 🧪 5. Evaluation & Quality Harness

The [`evals/`](evals/) directory hosts automated quality tests across reasoning and multimodal domains:

```bash
# Evaluate Akhet-Ra1 on reasoning, Arabic culture, and tool execution
python evals/eval_akhet_ra1.py --endpoint http://localhost:8080/v1 --limit 5

# Evaluate Akhet-Aton-2B on Arabic OCR, schema validation, and edge latency
python evals/eval_aton_2b.py --endpoint http://localhost:8080/v1
```

Evaluation dimensions covered:
* **Arabic Cultural Nuance & Egyptian Dialect Comprehension**
* **Multimodal Arabic Document & Table OCR**
* **Schema-Strict JSON Extraction & Tool Dispatch**
* **Chain-of-Thought Reasoning (`<think>...</think>`)**
* **Safety Guardrails & Prompt Injection Refusals**

---

## 🌐 6. Hugging Face Spaces & Interactive Demonstrations

* **[Akhet-Chat Space](https://huggingface.co/spaces/alwkala/Akhet-Chat)**: Native RTL Arabic chat interface featuring streaming inference and model tuning controls.
* **[Local Studio Launcher](https://github.com/alwkala/akhet-models)**: Native WPF hardware dashboard and unified model launcher (`Alwkala-Studio.ps1`).

---

## 📁 7. Repository Organization

```text
akhet-models/
├── .github/                      # Issue templates, PR guidelines, and workflows
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.yml        # Structured bug report form
│   │   ├── feature_request.yml   # Structured feature proposal form
│   │   └── config.yml            # Community links configuration
│   └── PULL_REQUEST_TEMPLATE.md  # Standardized pull request template
├── models/
│   ├── Ra-1/                     # Akhet-Ra1 (4.2B) model card, system prompt, runners
│   │   ├── MODEL_CARD.md
│   │   ├── README.md
│   │   ├── system_prompt_ra1.txt
│   │   └── run-Ra-tui.ps1
│   └── Aton-2B/                  # Akhet-Aton-2B (2.23B Multimodal) package
│       ├── MODEL_CARD.md
│       ├── MODEL_CARD_AR.md
│       ├── README.md
│       ├── CHANGELOG.md
│       ├── system_prompt_aton.txt
│       ├── run-Aton-Adaptive.ps1
│       ├── run-Aton-Adaptive-tools.ps1
│       └── eval_aton_2b.py
├── evals/                        # Benchmark harness and automated evaluation
│   ├── eval_akhet_ra1.py
│   ├── eval_aton_2b.py
│   └── README.md
├── spaces/
│   └── Ra-1-demo/                # Gradio web interface package
├── CODE_OF_CONDUCT.md            # Contributor Covenant standard
├── CONTRIBUTING.md               # Contribution and branch governance guidelines
├── SECURITY.md                   # Security vulnerability reporting policy
├── LICENSE                       # Apache-2.0 open-source license
├── CHANGELOG.md                  # SemVer-compliant release log
├── ROADMAP.md                    # Multi-phase project roadmap
└── README.md                     # Flagship repository documentation
```

---

## 🤝 Citation & Attribution

```bibtex
@misc{alwkala_akhet_models_2026,
  title        = {Akhet Models: Central Local-First Language Models and Governance Architecture},
  author       = {Alwkala Digital Labs},
  year         = {2026},
  publisher    = {GitHub},
  howpublished = {\url{https://github.com/alwkala/akhet-models}}
}
```

---

## 🏢 Organization

**Alwkala Digital Labs**  
Cairo, Egypt · [alwkala.com](https://alwkala.com)  
*Architecting local-first platforms, efficient model architectures, and governed agent runtimes across the MENA region.*
