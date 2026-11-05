# Model Card: Akhet-Aton-2B

## Ultra-Lightweight, Edge-Native Bilingual Agent & Vision-Language Model
### Developed by Alwkala Digital Labs · AkhetRa Ecosystem

**Release:** v0.1.0  
**Date:** November 05, 2026  
**Base Model:** [Qwen/Qwen3.5-2B](https://huggingface.co/Qwen/Qwen3.5-2B) by Qwen  
**Developer & Publisher:** [Alwkala Digital Labs](https://alwkala.com)  
**Model Type:** Bilingual (Arabic/English) Edge Agent · Hybrid SSM + Attention + Optional CLIP Vision Tower  
**Target Environments:** Local Desktop Inference, Edge Devices, Modest Hardware, and Air-Gapped Environments  
**Distributions:**
- Language Model: `Aton-2B-Q4_K_M.gguf` (1.31 GB)
- Vision Projector: `Aton-2B-F16-mmproj.gguf` (668 MB)  
**Repository:** [alwkala/Aton](https://huggingface.co/alwkala/Aton)  

---

## 1. Model Philosophy & Purpose

A **2 Billion parameter (2B)** model possesses distinct operational characteristics that make it ideal for specific agentic workflows, rather than competing with giant LLMs on broad encyclopedic trivia.

**Akhet-Aton-2B** is engineered by **Alwkala Digital Labs** as a fast, deterministic, private local agent. Its core strengths are:
* **Sub-second Latency & High Inference Speed:** Rapid generation and quick tool turnaround.
* **Minimal Hardware Footprint:** Runs comfortably on standard laptops, modest consumer GPUs (< 3 GB VRAM), or powerful CPUs with low energy consumption.
* **Complete Local Privacy:** Zero data leaves the local host machine, ensuring complete data containment.
* **Deterministic Execution & Structured Output:** Highly calibrated for strict JSON generation, triage, and function calling.

---

## 2. Core Use Cases

### 2.1 Local Desktop Assistant
Run an entirely private desktop assistant directly on local hardware without cloud dependence.
* **Tasks:** Local file management, personal document summarization, semantic desktop search, and voice/text command execution in Arabic and English.
* **Key Advantage:** Total privacy and air-gapped security for sensitive enterprise and personal data.

### 2.2 Triage & Routing Agent
Small models excel at high-speed classification and precise entity extraction.
* **Tasks:** Processing incoming customer support tickets and emails, extracting critical fields (customer name, order number, issue category), and routing requests to appropriate departments or calling status-check APIs.
* **Key Advantage:** Ultra-low response time and virtually zero operational cost compared to frontier models.

### 2.3 Data Parsing & Structuring (JSON Mode)
Transforming unstructured texts and documents into strict, schema-compliant JSON.
* **Tasks:** Ingesting invoices, receipts, resumes/CVs, and forms in Arabic or English, and extracting target fields (dates, line items, monetary values, skills) ready for database insertion.
* **Key Advantage:** High structural fidelity with minimal risk of hallucination when provided clear extraction instructions.

### 2.4 IoT & Automation Orchestrator
Acting as a deterministic interpreter between natural language, machine commands, and function calling.
* **Tasks:** Smart home automation and local server management—converting instructions like "turn off hallway lights and set AC to 22C" or "find files modified yesterday and archive them" into precise Python scripts, Bash commands, or API calls.
* **Key Advantage:** Negligible power draw, allowing persistent execution on single-board computers (Raspberry Pi, edge nodes).

### 2.5 RAG Query Generator & Search Decomposer
Serving as an intelligent pre-processing step for Retrieval-Augmented Generation (RAG) pipelines.
* **Tasks:** Ingesting complex user queries and decomposing them into 1–3 precise, targeted search queries across vector databases or search engines, passing retrieved contexts to downstream pipelines.
* **Key Advantage:** Substantially improves retrieval recall without burning compute cycles on oversized LLMs for query reformulation.

### 2.6 Offline Educational Drill & Language Coach
Interactive educational tutor operating without an internet connection.
* **Tasks:** Conversational drills, grammar and syntax correction, and bidirectional translation exercises between Arabic and English.
* **Key Advantage:** Enables accessible learning in disconnected classrooms, rural areas, or low-bandwidth environments.

---

## 3. Operational Boundaries & Anti-Patterns

To ensure maximum reliability, deploy Aton-2B within its architectural boundaries:

1. **Avoid Multi-Step Complex Reasoning:**
   * Not intended for abstract multi-step mathematical proofs or writing complex software algorithms from scratch without external tooling.
2. **Avoid Unbounded Long-Form Creative Generation:**
   * Not designed for generating multi-thousand-word novels or extensive creative prose where small models tend to drift or repeat.
3. **Avoid Using as a Standalone Fact Oracle:**
   * Avoid querying obscure historical or factual trivia without grounding the model with external RAG context or search tools.

---

## 4. Technical Specifications

| Parameter | Specification |
| :--- | :--- |
| **Model Name** | Akhet-Aton-2B (Alias: `Aton-2B`) |
| **Model Family** | Akhet-Aton |
| **Developer & Publisher** | Alwkala Digital Labs ([alwkala.com](https://alwkala.com)) |
| **Base Model** | Qwen3.5 2B (`Qwen/Qwen3.5-2B`) by Qwen |
| **Architecture** | Hybrid SSM (Mamba-style) + Interleaved Attention + CLIP Vision Tower |
| **Total Parameters** | ~ 2.23 Billion Parameters |
| **Language Parameters** | ~ 1.90 Billion Parameters |
| **Vision Parameters** | ~ 331 Million Parameters (CLIP ViT-L/14) |
| **Vocabulary Size** | 248,320 tokens |
| **Actual SFT Context** | 2,048 tokens (2K) |
| **Base Native Context** | 262,144 tokens (256K Native Base Context) |
| **Recommended Runtime Context** | 8,192 to 32,768 tokens (8K - 32K) |
| **Vision Resolution** | 768 × 768 pixels (16×16 patch size) |
| **Reasoning Format** | Chain-of-Thought (`<think>...</think>`) |
| **Tool Calling Format** | Native XML/JSON Tool Calling (`<tool_call>`, `<tool_response>`) |
| **License** | Apache-2.0 |
| **Quantization Format** | GGUF Q4_K_M (Language: 1.31 GB) + F16 (Vision Projector: 668 MB) |

---

## 5. Quick Start & Execution

### 5.1 Native GUI Studio
Launch the official desktop wizard `Launch-Studio.bat` with one-click hardware inspection and execution control.

### 5.2 Adaptive Multimodal TUI Runner
```powershell
# Runs interactive terminal dashboard with hardware calibration and tool support
.\run-Aton-Adaptive-tools.ps1 -Port 8080 -EngineMode Apex1
```

### 5.3 CLI Server Command
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
