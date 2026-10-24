# 𓂀 Akhet Models (`akhet-models`)

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Hugging Face](https://img.shields.io/badge/%F0%9F%A4%97%20Hugging%20Face-alwkala%2FAkhet--Ra1-yellow)](https://huggingface.co/alwkala/Akhet-Ra1)
[![Architecture: Hybrid SSM+Attention](https://img.shields.io/badge/Architecture-Hybrid%20SSM%2BAttention-indigo)](#)
[![Deployment: Local--First](https://img.shields.io/badge/Deployment-Local--First-green)](#)
[![Organization: Alwkala Digital Labs](https://img.shields.io/badge/Org-Alwkala%20Digital%20Labs-orange)](https://alwkala.com)

**Sovereign, local-first language models, evaluation harnesses, and inference tools by [Alwkala Digital Labs](https://alwkala.com).**  
Home of the **AkhetRa** model family (*Ra: Intelligence · Akhet: Governance*).

---

## 🏛️ 1. The AkhetRa Dual-Architecture

The **AkhetRa** platform decouples generative cognition from execution safety:

```
                  ┌──────────────────────────────────────────────┐
                  │                   AKHETRA                    │
                  │            The Integrated Ecosystem         │
                  └──────────────────────┬───────────────────────┘
                                         │
                 ┌───────────────────────┴───────────────────────┐
                 │                                               │
                 ▼                                               ▼
   ┌───────────────────────────┐                   ┌───────────────────────────┐
   │            RA             │                   │           AKHET           │
   │    Intelligence Layer     │                   │    Runtime & Governance   │
   ├───────────────────────────┤                   ├───────────────────────────┤
   │ • Hybrid SSM + Attention  │                   │ • Policy Enforcement Gate │
   │ • Native Arabic & English │ ──RPC/Context───▶ │ • Sandboxed Tool Execution│
   │ • Chain-of-Thought (<think>)                  │ • Context & Memory Budget │
   │ • Structured Tool Output  │                   │ • Audit Trails & Refusals │
   └───────────────────────────┘                   └───────────────────────────┘
```

* **Ra (رع — The Sun / Intelligence):** The open generative model family optimized for local inference, bilingual fluency (MSA + Egyptian Dialect), and function calling.
* **Akhet (آخت — The Horizon / Governance):** The deterministic runtime enforcing access boundaries, sandboxed tool dispatch, and audit logging.

---

## 📚 2. Model Catalog

All model weights and quantizations are hosted directly on the **[Alwkala Hugging Face Organization](https://huggingface.co/alwkala)**:

| Model | Parameters | Architecture | Context (Native / Active) | Formats Available | Hugging Face Hub | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :---: |
| **[Akhet-Ra1](models/Ra-1)** | 4.2B | Hybrid SSM + Attention (Qwen3.5) | 256K / 32K | GGUF (`Q4_K_M`) | [alwkala/Akhet-Ra1](https://huggingface.co/alwkala/Akhet-Ra1) | 🟢 **Released (v0.2.0)** |
| **Akhet-Ra2** | *TBD* | Next-Gen Multi-Modal / Mixture | 512K / 64K | GGUF / SafeTensors | *Coming Soon* | 🟡 Planned |

---

## ⚡ 3. Quick-Start: Running Akhet-Ra1

You do not need to clone multi-gigabyte weight files into Git. Run `Akhet-Ra1` directly from the Hugging Face Hub:

### Option A: Direct Stream in Terminal (`llama-cli`)
```bash
llama-cli -hf alwkala/Akhet-Ra1:Ra-1-4B-Q4_K_M.gguf -p "أنت مساعد ذكي محلي خاضع لمنظومة آخت-رع." -cnv
```

### Option B: Local OpenAI-Compatible Server (`llama-server`)
```bash
llama-server \
  --hf-repo alwkala/Akhet-Ra1 \
  --hf-file Ra-1-4B-Q4_K_M.gguf \
  --alias "Akhet-Ra-1" \
  -c 32768 \
  -ngl 99 \
  --host 0.0.0.0 \
  --port 8080
```

### Option C: Instant Execution via Ollama
```bash
ollama run hf.co/alwkala/Akhet-Ra1:Ra-1-4B-Q4_K_M.gguf
```

### Option D: PowerShell Interactive TUI
Inside [`models/Ra-1`](models/Ra-1):
```powershell
.\run-Ra-tui.ps1 -Port 8080 -ContextSize 32768
```

---

## 📊 4. Memory & Hardware Scaling Profile

Calculated using Hugging Face `hf-mem` formulas for **Akhet-Ra1** (4.2B parameters, `Q4_K_M` 2.52 GB weights):

| Context Window | Model Weights VRAM | KV Cache (`q4_0`) | KV Cache (`f16`) | Total VRAM (`q4_0`) | Compatible Hardware |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **4,096 (4K)** | 2.52 GB | ~0.35 GB | ~0.70 GB | **~2.87 GB** | 4GB GPUs / Apple Silicon (M-series) |
| **8,192 (8K)** | 2.52 GB | ~0.70 GB | ~1.40 GB | **~3.22 GB** | 4GB – 6GB GPUs |
| **16,384 (16K)** | 2.52 GB | ~1.40 GB | ~2.80 GB | **~3.92 GB** | 6GB VRAM GPUs |
| **32,768 (32K)** | 2.52 GB | ~2.80 GB | ~5.60 GB | **~5.32 GB** | 6GB VRAM GPUs (with `-ctk q4_0 -ctv q4_0`) |

---

## 🧪 5. Evaluation & Benchmarking

The [`evals/`](evals/) directory contains standardized evaluation runners adapted from the official Hugging Face agent evaluation patterns:

```bash
# Run bilingual smoke evaluation against a running local server or endpoint
python evals/eval_akhet_ra1.py --endpoint http://localhost:8080/v1 --limit 5
```

Evaluation dimensions covered:
* **Arabic Cultural Nuance & Governance**
* **Egyptian Dialect Comprehension & Generation**
* **Tool & JSON Schema Extraction**
* **Mathematical Chain-of-Thought (`<think>`)**
* **Safety & Prompt Injection Refusal**

---

## 🌐 6. Hugging Face Spaces Demo

The [`spaces/Ra-1-demo`](spaces/Ra-1-demo) package contains an out-of-the-box Gradio interface configured for Hugging Face Spaces deployment:
* Native RTL Arabic Chat Interface.
* Real-time response streaming.
* Adjustable sampling parameters (Temperature, Max Tokens, System Prompt).

---

## 📁 7. Repository Organization

```text
akhet-models/
├── .github/              # Continuous integration & validation workflows
├── models/
│   └── Ra-1/             # Akhet-Ra1 model card, guides, system prompts, scripts
├── evals/                # Benchmark suites & quality harness
├── spaces/
│   └── Ra-1-demo/        # Hugging Face Spaces Gradio demo package
├── LICENSE               # Apache-2.0 open-source license
├── CHANGELOG.md          # SemVer-compliant release tracking
└── README.md             # Flagship repository documentation
```

---

## 🤝 Citation & Attribution

```bibtex
@misc{alwkala_akhet_models_2026,
  title        = {Akhet Models: Sovereign, Local-First Language Models and Governance Architecture},
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
*Architecting sovereign intelligence, local-first platforms, and governed agent runtimes across the MENA region.*
