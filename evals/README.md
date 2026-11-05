# Evaluation & Quality Harness (`evals/`)

This directory hosts benchmark harnesses, evaluation datasets, and test runners for the **Akhet** model family by **Alwkala Digital Labs**.

## Available Runners

### 1. `eval_akhet_ra1.py` — Ra-1 (4.2B Reasoning & Culture)
Automated smoke test and benchmark runner evaluating:
* Arabic Cultural & Reasoning Nuances
* Egyptian Dialect Comprehension & Generation
* Tool Calling & Structured JSON Validation
* Chain-of-Thought Reasoning (`<think>...</think>`)
* Safety & Security Guardrails Refusal

```bash
# Evaluate against local llama-server on port 8080
python evals/eval_akhet_ra1.py --endpoint http://localhost:8080/v1

# Output results as JSON for CI/CD integration
python evals/eval_akhet_ra1.py --json > benchmark_ra1_results.json
```

---

### 2. `eval_aton_2b.py` — Aton-2B (2.23B Multimodal & Edge Automation)
Automated evaluation harness for edge agents and vision-language capabilities:
* Arabic OCR & Visual Document Parsing
* Schema-Strict Structured JSON Extraction
* Function Calling & IoT / System Automation
* Bilingual Triage & Request Classification
* Sub-second Token Latency Benchmarks

```bash
# Run against local Aton llama-server or runner
python evals/eval_aton_2b.py --endpoint http://localhost:8080/v1

# Run with test image sample
python evals/eval_aton_2b.py --endpoint http://localhost:8080/v1 --image path/to/sample_invoice.jpg
```
