---
license: apache-2.0
base_model: Qwen/Qwen3.5-2B
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
  - edge-ai
  - agents
  - tool-use
  - multimodal
  - vision
  - arabic
  - local-first
  - akhetra
  - aton
  - qwen3_5
model-index:
  - name: Akhet-Aton-2B
    results: []
---

# Akhet-Aton-2B — Model Card & Documentation
## Ultra-Lightweight Edge Agent & Multimodal Model by Alwkala Digital Labs
### Part of the AkhetRa Ecosystem (Aton: Operational Intelligence · Akhet: Governance)

**Status:** Release v0.1.0 · **Date:** 2026-11-05  
**Base Model:** [Qwen/Qwen3.5-2B](https://huggingface.co/Qwen/Qwen3.5-2B) by Qwen  
**Fine-tuned & Quantized by:** [Alwkala Digital Labs](https://alwkala.com)  
**Model Type:** Bilingual (Arabic/English) Edge Agent · Hybrid SSM + Attention + Optional CLIP Vision Tower  
**Deployment Focus:** Local Inference, Private Edge Computing, and Modest Hardware  
**Active Distributions:**
- Language Model: `Aton-2B-Q4_K_M.gguf` (1.31 GB)
- Vision Projector: `Aton-2B-F16-mmproj.gguf` (668 MB)  
**Hugging Face Repository:** [alwkala/Aton](https://huggingface.co/alwkala/Aton)  

---

## 1. Overview & Positioning

A **2 Billion parameter (2B)** model has unique architectural advantages that make it exceptional for specific real-world tasks, rather than attempting to serve as an all-purpose encyclopedic oracle.

**Akhet-Aton-2B** is developed by **Alwkala Digital Labs** as a fast, private, and deterministic bilingual agent. Its strength is rooted in:
* **Speed & Low Latency:** Rapid response generation ideal for real-time applications.
* **Low Hardware Footprint:** Runs comfortably on laptops, modest GPUs (< 3 GB VRAM), and standard CPUs.
* **Complete Privacy:** 100% local execution—zero telemetry or external data transfer.
* **High Task Determinism:** High fidelity in structured JSON extraction, routing, and tool calling.

---

## 2. Core Use Cases

| # | Use Case | Key Task | Advantage |
| :- | :--- | :--- | :--- |
| **1** | **Local Desktop Assistant** | Local file management, document summarization, voice/text desktop actions | Air-gapped privacy (data never leaves the machine) |
| **2** | **Triage & Routing Agent** | Ingesting support tickets/emails, extracting metadata, dispatching APIs | Ultra-fast classification at near-zero operating cost |
| **3** | **Data Parsing & Structuring** | Ingesting invoices, receipts, and CVs (AR/EN) into strict JSON | High structural compliance without hallucination |
| **4** | **IoT & Automation Orchestrator** | Translating natural language to bash, python, or function calls | Low energy draw; persistent run on Raspberry Pi / Edge nodes |
| **5** | **RAG Query Generator** | Decomposing complex queries into 1–3 precise vector search queries | Boosts RAG precision without wasting compute on large LLMs |
| **6** | **Offline Educational Drill** | Conversational practice, grammar correction, bilingual translation | 100% offline functionality for low-connectivity environments |

---

## 3. Operational Boundaries & Anti-Patterns

1. **Avoid Multi-Step Complex Reasoning:** Not built for solving abstract mathematical problems or writing complex algorithms from scratch without external tooling.
2. **Avoid Unbounded Long-Form Generation:** Not intended for generating multi-thousand-word novels or lengthy essays where small models tend to drift.
3. **Avoid Using as a Standalone Fact Oracle:** Ground all factual Q&A with local RAG documents or search retrieval.

---

## 4. Technical Specifications

| Field | Value / Specification |
| :--- | :--- |
| **Model Name** | Akhet-Aton-2B (Alias: `Aton-2B`) |
| **Model Family** | Akhet-Aton |
| **Organization / Developer** | Alwkala Digital Labs ([alwkala.com](https://alwkala.com)) |
| **Base Model** | Qwen3.5 2B (`Qwen/Qwen3.5-2B`) by Qwen |
| **Architecture** | Hybrid SSM (Mamba-style) + Interleaved Attention + CLIP Vision Tower |
| **Total Parameters** | ~ 2,231,000,000 (~ 2.23 Billion Parameters) |
| **Language Parameters** | ~ 1,900,000,000 (~ 1.9 Billion Parameters) |
| **Vision Parameters** | ~ 331,000,000 (~ 331 Million Parameters) |
| **Vocabulary Size** | 248,320 tokens |
| **SFT Trained Context** | 2,048 tokens (2K) |
| **Base Native Context** | 262,144 tokens (256K Native Base Context) |
| **Recommended Runtime Context** | 8,192 to 32,768 tokens (8K - 32K) |
| **Vision Resolution** | 768 × 768 pixels (16×16 patch size) |
| **Reasoning Mode** | Native Chain-of-Thought (`<think>...</think>`) |
| **Tool Calling Format** | Native XML/JSON Tool Calling (`<tool_call>`, `<tool_response>`) |
| **Base License** | Apache-2.0 |
| **Quantization Format** | GGUF Q4_K_M (Language: 1.31 GB) + F16 (Vision Projector: 668 MB) |

---

## 5. Quick Start & Execution

### 5.1 Native GUI Studio
Launch the official desktop wizard `Launch-Studio.bat` with one-click hardware inspection and execution control.

### 5.2 Adaptive Multimodal Runner (Live TUI Dashboard)
```powershell
# Launches the adaptive multimodal engine with live telemetry and tool support
.\run-Aton-Adaptive-tools.ps1 -Port 8080 -EngineMode Apex1
```

### 5.3 Raw llama-server Execution
```powershell
llama-server.exe `
  -m ./Aton-2B-Q4_K_M.gguf `
  --mmproj ./Aton-2B-F16-mmproj.gguf `
  --image-min-tokens 1024 `
  --alias "Akhet-Aton-2B" `
  -ngl 99 `
  -c 8192 `
  -t 8 `
  --jinja `
  --flash-attn on `
  --tools all `
  --host 0.0.0.0 `
  --port 8080
```
