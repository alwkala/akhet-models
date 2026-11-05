# Contributing to Akhet Models

Thank you for your interest in contributing to **Akhet Models**! We welcome community contributions in model evaluation, hardware launchers, documentation, and agent integration.

## Code of Conduct

All contributors are expected to uphold the [Code of Conduct](CODE_OF_CONDUCT.md).

## Getting Started

1. Fork the repository on GitHub: `https://github.com/alwkala/akhet-models`.
2. Clone your fork locally:
   ```bash
   git clone https://github.com/<your-username>/akhet-models.git
   cd akhet-models
   ```
3. Create a feature branch with a descriptive name:
   ```bash
   git checkout -b feat/eval-metric-update
   ```

## Development Guidelines

### 1. Zero Binary Weights Policy
* **Never commit binary weights** (`*.gguf`, `*.bin`, `*.safetensors`, `*.mmproj`) directly to the Git repository.
* All model weights must be published and hosted on the **[Alwkala Hugging Face Hub](https://huggingface.co/alwkala)**.
* Git repository commits are strictly limited to documentation, model cards, launchers, system prompts, and evaluation harnesses.

### 2. Semantic Versioning & Changelog Integrity
* This repository strictly adheres to **Semantic Versioning (SemVer)**: `MAJOR.MINOR.PATCH`.
* Any meaningful change affecting model interfaces, evaluation metrics, or supported runtimes must include an update to `CHANGELOG.md` under the appropriate version section.

### 3. Identity & Naming Standards
* The official brand identity is **Alwkala Digital Labs** (`alwkala.com`).
* Use simple, concise, decisive titles.
* Prohibited term: Do not use the word *Sovereign* anywhere in documentation, titles, or code comments.

## Submitting a Pull Request

1. Ensure Python scripts pass syntax validation:
   ```bash
   python -m py_compile evals/eval_akhet_ra1.py
   python -m py_compile evals/eval_aton_2b.py
   ```
2. Commit your changes using conventional commit messages:
   ```bash
   git commit -m "feat(evals): add latency benchmark to eval_aton_2b"
   ```
3. Push to your fork and submit a Pull Request against the `main` branch.
