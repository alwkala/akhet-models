# Evaluation & Quality Harness (`evals/`)

This directory hosts benchmark harnesses, evaluation datasets, and test runners for the **Akhet** model family.

## Available Runners

* **`eval_akhet_ra1.py`**: Automated smoke test and benchmark runner evaluating:
  1. Arabic Cultural & Reasoning Nuances
  2. Egyptian Dialect Comprehension & Generation
  3. Tool Calling & Structured JSON Validation
  4. Chain-of-Thought Reasoning (`<think>...</think>`)
  5. Safety & Security Guardrails Refusal

## Usage

```bash
# Evaluate against local llama-server on port 8080
python eval_akhet_ra1.py --endpoint http://localhost:8080/v1

# Output results as JSON for CI/CD integration
python eval_akhet_ra1.py --json > benchmark_results.json
```
