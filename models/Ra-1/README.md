---
license: apache-2.0
base_model: Qwen/Qwen3.5-4B
base_model_relation: finetune
language:
  - ar
  - en
pipeline_tag: text-generation
library_name: transformers
quantized_by: alwkala
tags:
  - gguf
  - llama-cpp
  - arabic
  - local-first
  - tool-use
  - agents
  - akhetra
  - conversational
  - qwen3_5
model-index:
  - name: Akhet-Ra1
    results: []
---

# Akhet-Ra1 — Model Card & Documentation
## A Local-First, Arabic-Aware Language Model by Alwkala Digital Labs
### Part of the AkhetRa Ecosystem (Ra: Intelligence · Akhet: Governance)

**Status:** Release v0.1.0 · **Date:** 2026-10-23  
**Base Model:** [Qwen/Qwen3.5-4B](https://huggingface.co/Qwen/Qwen3.5-4B)  
**Fine-tuned & Quantized by:** [Alwkala Digital Labs](https://alwkala.com)  
**Model Type:** Large Language Model (LLM) · Decoder-only causal  
**Deployment Focus:** Local inference, Private infrastructure, and Self-Hosted AI  
**Active Distribution:** `Ra-1-4B-Q4_K_M.gguf` (2.52 GB)  
**Hugging Face Repository:** [alwkala/Akhet-Ra1](https://huggingface.co/alwkala/Akhet-Ra1)  


---

## ملخص تنفيذي بالعربية (Executive Summary in Arabic)

**«آخت-رع 1» (Akhet-Ra1)** هو نموذج ذكاء اصطناعي محلي مُحسَّن بالضبط الدقيق (Fine-tuned) استناداً إلى نموذج **Qwen3.5 Base**، طورته **Alwkala Digital Labs** ليكون طبقة الذكاء (**رع / Ra**) داخل منظومة **آخت-رع (AkhetRa)**. يركز النموذج على الاستدلال المحلي والسيادة على البيانات، والتعامل الذكي مع اللغتين العربية والإنجليزية، ودعم سيناريوهات الوكلاء الذكيين (Agents) والأدوات الخاضعة للحوكمة الصارمة عبر بيئة التشغيل (**آخت / Akhet**).

*تنبيه توثيقي: هذه البطاقة تمثل المواصفات المرجعية ومعايير التقييم للنموذج. تخضع حقول الأداء والقياسات الحسابية لنتائج الاختبارات المعيارية.*

---

## 1. Overview & Identity

### 1.1 Overview
**Akhet-Ra1** serves as the primary local intelligence layer within the **AkhetRa** architecture:
- Bringing AI capabilities directly to the edge and local hardware.
- Enforcing full organizational control over infrastructure and confidential data.
- Providing an integration-ready foundation for tool-calling and autonomous agents governed by the Akhet platform.

### 1.2 Model Identity Specification

| Field | Value / Specification |
| :--- | :--- |
| **Model Name** | Akhet-Ra1 (GGUF Identifier: `Akhet-Ra1-4B` / Alias: `Akhet-Ra-1`) |
| **Model Family** | Akhet-Ra |
| **Organization / Developer** | Alwkala Digital Labs ([alwkala.com](https://alwkala.com)) |
| **Base Model** | Qwen3.5 4B (`Qwen/Qwen3.5-4B`) |
| **Model Type** | Hybrid SSM + Self-Attention Causal Language Model (Qwen3.5 Architecture) |
| **Parameter Count** | 4,205,751,296 (~ 4.2 Billion Parameters) |
| **Vocabulary Size** | 248,320 tokens |
| **Embedding Dimension** | 2,560 |
| **Hidden Layers / Blocks** | 32 Blocks (Hybrid SSM Mamba-style layers + Full Attention every 4 layers) |
| **Native Trained Context** | 262,144 tokens (256K native training context) |
| **Active Runtime Context** | 32,768 tokens (32K allocated in local server) |
| **Reasoning Mode** | Native Chain-of-Thought (`<think>...</think>` / `reasoning_content`) |
| **Tool Calling Format** | Native XML/JSON Tool Calling (`<tool_call>`, `<tool_response>`) |
| **Base License** | Apache-2.0 (`general.license: apache-2.0`) |
| **Quantization Format** | GGUF Q4_K_M (File: `Ra-1-4B-Q4_K_M.gguf`, Size: 2.52 GB) |

---

## 2. Design Philosophy

1. **Local-First:** Compute resides on user hardware close to private data.
2. **Arabic-Aware:** Deep comprehension of Modern Standard Arabic, dialectal nuances (including Egyptian), technical terms, and code-switching.
3. **Integration-Ready:** Seamless coupling with runtime hooks, development tools, and agent loops.
4. **Governance-Compatible:** Designed to operate inside sandboxed runtimes enforcing strict tool access policies.
5. **Model Agnostic Architecture:** Operates independently while remaining interchangeable with external models under AkhetRa policies.

---

## 3. The AkhetRa Ecosystem Architecture

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
   │    The Intelligence Layer │                   │ The Runtime & Governance  │
   ├───────────────────────────┤                   ├───────────────────────────┤
   │ • Akhet-Ra1 LLM (Local)   │                   │ • Context & Memory Budget │
   │ • Reasoning & Generation  │◄─────────────────►│ • Tool Permissions       │
   │ • Arabic & English Logic  │  Strict Contract  │ • Sandboxing & Approvals  │
   │ • Tool Argument Synthesis │                   │ • Audit Trail & Logs      │
   └───────────────────────────┘                   └───────────────────────────┘
```

> **The Golden Principle:** *Ra thinks, Akhet governs.*  
> The model produces proposals, reasoning, and tool call invocations; the Akhet runtime enforces security boundaries, schema validation, human approval, and telemetry.

---

## 4. Intended & Out-of-Scope Use Cases

### 4.1 Intended Use Cases (Subject to Evaluation)
- Local enterprise and personal conversational assistants.
- Retrieval-Augmented Generation (RAG) over private local documents.
- Software development assistance, code reasoning, and debugging.
- Structured data extraction, JSON formatting, and schema-compliant outputs.
- Tool-assisted workflows and multi-step agent tasks.

### 4.2 Out-of-Scope & Prohibited Uses
- Automated decision-making in medical, legal, or life-critical contexts without certified human supervision.
- Autonomous execution of destructive shell or database actions without explicit runtime approval.
- Bypassing base model licenses or local regulatory requirements.
- Treating unverified probabilistic outputs as definitive ground truth.

---

## 5. Deployment & Quick Start

### 5.1 Local Execution via llama.cpp (Bundled PowerShell Scripts)

The repository includes pre-configured launch scripts optimized for NVIDIA GPUs (6GB+ VRAM):

#### Interactive Terminal Dashboard (TUI)
```powershell
# Starts the interactive live dashboard with GPU metrics, logs, and hotkeys
.\run-Ra-tui.ps1 -Port 8080 -ContextSize 32768
```

#### Headless Service Runner
```powershell
# Launches llama-server as a background/daemon service
.\run-Ra-0.ps1
```

#### Raw llama-server Command
```bash
llama-server.exe \
  -m "A:\.lmstudio\Akhet\Ra-1\Ra-1-4B-Q4_K_M.gguf" \
  --alias "Akhet-Ra-1" \
  -ngl 99 \
  -c 32768 \
  -t 8 \
  --jinja \
  --flash-attn on \
  -ctk q4_0 \
  -ctv q4_0 \
  --batch-size 1024 \
  --ubatch-size 512 \
  --host 0.0.0.0 \
  --port 8080
```

### 5.2 Direct Execution via Hugging Face Hub

Thanks to Hugging Face Hub integration and the GGUF distribution, you can run or serve **Akhet-Ra1** directly without manual file downloads:

#### Direct CLI Execution (`llama-cli`)
```bash
# Streams inference directly using weights hosted on Hugging Face
llama-cli -hf alwkala/Akhet-Ra1:Ra-1-4B-Q4_K_M.gguf -p "أنت مساعد ذكي محلي خاضع لمنظومة آخت-رع." -cnv
```

#### Direct Server Execution (`llama-server`)
```bash
# Launches an OpenAI-compatible server on port 8080 directly from the Hub
llama-server \
  --hf-repo alwkala/Akhet-Ra1 \
  --hf-file Ra-1-4B-Q4_K_M.gguf \
  --alias "Akhet-Ra-1" \
  -c 32768 \
  -ngl 99 \
  --host 0.0.0.0 \
  --port 8080
```

#### Direct Execution via Ollama
```bash
# Pull and run directly from Hugging Face Hub via Ollama
ollama run hf.co/alwkala/Akhet-Ra1:Ra-1-4B-Q4_K_M.gguf
```

#### Custom Ollama `Modelfile`
```dockerfile
FROM ./Ra-1-4B-Q4_K_M.gguf
TEMPLATE """{{ if .System }}<|im_start|>system
{{ .System }}<|im_end|>
{{ end }}{{ if .Prompt }}<|im_start|>user
{{ .Prompt }}<|im_end|>
{{ end }}<|im_start|>assistant
{{ .Response }}<|im_end|>"""
PARAMETER stop "<|im_start|>"
PARAMETER stop "<|im_end|>"
PARAMETER temperature 0.7
PARAMETER top_p 0.9
PARAMETER num_ctx 32768
```

### 5.3 Downloading the GGUF Distribution Locally

You can download `Ra-1-4B-Q4_K_M.gguf` (2.52 GB) for offline local deployment:

#### Using Hugging Face CLI (`hf`):
```bash
hf download alwkala/Akhet-Ra1 Ra-1-4B-Q4_K_M.gguf --local-dir .
```

#### Using Python (`huggingface_hub`):
```python
from huggingface_hub import hf_hub_download

model_path = hf_hub_download(
    repo_id="alwkala/Akhet-Ra1",
    filename="Ra-1-4B-Q4_K_M.gguf",
    local_dir="."
)
print(f"Downloaded to: {model_path}")
```

#### Using LM Studio:
1. Open **LM Studio**.
2. Search for `alwkala/Akhet-Ra1` in the model search bar.
3. Select `Ra-1-4B-Q4_K_M.gguf` and click **Download**.
4. In the System Prompt configuration, paste the system prompt from [`system_prompt.txt`](system_prompt.txt).
5. Load with GPU acceleration enabled (`GPU Offload: Max`).

### 5.4 Python Inference (Hugging Face Transformers / GGUF)
```python
from transformers import AutoModelForCausalLM, AutoTokenizer
import torch

model_id = "alwkala/Akhet-Ra1"  # Or local path
tokenizer = AutoTokenizer.from_pretrained(model_id)
model = AutoModelForCausalLM.from_pretrained(
    model_id,
    torch_dtype=torch.bfloat16,
    device_map="auto"
)

messages = [
    {"role": "system", "content": "أنت مساعد ذكي محلي خاضع لمنظومة آخت-رع."},
    {"role": "user", "content": "اشرح لي مبدأ الحوكمة الصارمة لنماذج الذكاء الاصطناعي."}
]

prompt = tokenizer.apply_chat_template(messages, tokenize=False, add_generation_prompt=True)
inputs = tokenizer(prompt, return_tensors="pt").to(model.device)

outputs = model.generate(**inputs, max_new_tokens=512, temperature=0.7, top_p=0.9)
print(tokenizer.decode(outputs[0], skip_special_tokens=True))
```

### 5.5 OpenAI-Compatible Local Endpoint
Once running on `http://localhost:8080`, query via standard OpenAI clients:
```python
from openai import OpenAI

client = OpenAI(base_url="http://localhost:8080/v1", api_key="sk-no-key-required")

response = client.chat.completions.create(
    model="Akhet-Ra-1",
    messages=[
        {"role": "user", "content": "ما هي مميزات معمارية AkhetRa؟"}
    ]
)
print(response.choices[0].message.content)
```

---

## 6. Recommended Sampling Parameters

| Parameter | Recommended Value | Description |
| :--- | :--- | :--- |
| **Temperature** | `0.6` – `0.7` | Balanced creativity and deterministic precision |
| **Top-P** | `0.90` | Nucleus sampling cutoff |
| **Top-K** | `40` | Limits token candidate pool |
| **Repetition Penalty** | `1.10` | Prevents cyclic repetitions in long context chains |
| **Context Size** | `32,768` (32K) | Maximum trained / tested context window |
| **KV Cache Quantization** | `q4_0` (`-ctk q4_0 -ctv q4_0`) | Halves KV cache VRAM footprint enabling 32K context on 6GB VRAM |

---

## 7. Hardware & Resource Footprint

### 7.1 Distribution Footprint Overview
| Distribution Format | File Size | Minimum VRAM / RAM | Tested Hardware | Full GPU Offload | Context Tested |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **GGUF Q4_K_M** | 2.52 GB | 6 GB VRAM | NVIDIA RTX 3060 / Laptop 6GB | Yes (99 layers) | 32K tokens |
| **GGUF Q8_0** | ~4.3 GB *(TBD)* | 8 GB VRAM | NVIDIA RTX 3070 / 4060 Ti | Yes | 32K tokens |
| **BF16 SafeTensors** | ~8.0 GB *(TBD)* | 12 GB VRAM / 16 GB RAM | NVIDIA RTX 3060 12GB / A10G | Yes | 32K tokens |

### 7.2 VRAM & KV Cache Scaling Profile (`Ra-1-4B-Q4_K_M.gguf`)
*Calculated using Hugging Face `hf-mem` memory estimation formulas for 4.2B parameters with Q4_K_M weights (2.52 GB):*

| Context Length | Weights VRAM | KV Cache (`q4_0`) | KV Cache (`f16`) | Total VRAM (`q4_0`) | Target Hardware |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **4,096 (4K)** | 2.52 GB | ~0.35 GB | ~0.70 GB | **~2.87 GB** | 4GB GPUs / Integrated (Apple M-series) |
| **8,192 (8K)** | 2.52 GB | ~0.70 GB | ~1.40 GB | **~3.22 GB** | 4GB – 6GB GPUs |
| **16,384 (16K)** | 2.52 GB | ~1.40 GB | ~2.80 GB | **~3.92 GB** | 6GB VRAM GPUs |
| **32,768 (32K)** | 2.52 GB | ~2.80 GB | ~5.60 GB | **~5.32 GB** | 6GB VRAM GPUs (with `-ctk q4_0 -ctv q4_0`) |

---

## 8. Evaluation Framework & Methodology

All benchmark claims must be validated through uniform protocols against the upstream base checkpoint (`Qwen3.5 Base`):

| Evaluation Dimension | Benchmark / Harness | Target Metric | Base | Akhet-Ra1 | Δ |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Arabic Knowledge** | ArabicMMLU | Accuracy (%) | *[Pending]* | *[Pending]* | *[TBD]* |
| **Egyptian & Regional Dialects** | Internal Egyptian Dialect Suite | Comprehension & Fluency | *[Pending]* | *[Pending]* | *[TBD]* |
| **Instruction Following** | IFEval | Strict Prompt Adherence | *[Pending]* | *[Pending]* | *[TBD]* |
| **Reasoning & Logic** | GSM8K / ARC-C | Accuracy (%) | *[Pending]* | *[Pending]* | *[TBD]* |
| **Code Generation** | HumanEval / MBPP | Pass@1 (%) | *[Pending]* | *[Pending]* | *[TBD]* |
| **Tool Calling & Schema** | BFCL / JSON-Schema Benchmark | Schema Validity Rate | *[Pending]* | *[Pending]* | *[TBD]* |
| **Context Needle** | RULER / Needle In A Haystack | Retrieval Accuracy | *[Pending]* | *[Pending]* | *[TBD]* |
| **Safety & Jailbreak** | Refusal & Prompt Injection Suite | Robustness Score | *[Pending]* | *[Pending]* | *[TBD]* |

---

## 9. Safety, Governance & Alignment

1. **Defense in Depth:** The model's safety refusals are backed by the **Akhet** runtime firewall.
2. **Untrusted Data Isolation:** All web content, external RAG chunks, and tool outputs are treated as untrusted strings and never directly interpreted as system prompts.
3. **Execution Guardrails:** Any write, network, or process spawning action requires explicit user permission or pre-authorized policy tokens.

---

## 10. Citation & Attribution

```bibtex
@misc{alwkala_akhetra1_2026,
  title        = {Akhet-Ra1: A Local-First, Arabic-Aware Fine-Tuned Language Model},
  author       = {Alwkala Digital Labs},
  year         = {2026},
  publisher    = {Alwkala},
  howpublished = {\url{https://alwkala.com}}
}
```

---

## 11. Organization

**Alwkala Digital Labs**  
Website: [alwkala.com](https://alwkala.com)  
*Advancing practical AI systems, local intelligence, and governed agent frameworks across the MENA region.*
