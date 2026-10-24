# Changelog

All notable changes to the **Akhet-Ra1** model repository and documentation will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-10-24

- **Hugging Face Skills Integration (`huggingface/skills`)**: Imported and registered the official 25-skill suite into `.agents/skills` (including `hf-cli`, `hf-mem`, `huggingface-local-models`, `huggingface-spaces`, `huggingface-community-evals`, `huggingface-datasets`, etc.) for agentic Hub governance and automated operations.
- **Hugging Face Direct Execution Standards**: Enhanced [README.md](README.md) and [MODEL_CARD_AR.md](MODEL_CARD_AR.md) with direct Hub one-liner execution syntax (`llama-cli -hf`, `llama-server --hf-repo`, and `ollama run hf.co`) without requiring manual downloads.
- **Ollama Modelfile Manifest**: Documented standard Ollama `Modelfile` configuration with ChatML/Qwen template, stop tokens, and parameters for local containerized deployment.
- **Granular Hardware & KV Cache Profiling**: Added detailed memory estimation scaling table (4K to 32K context windows) calibrated using `hf-mem` formulas for 4.2B parameters and Q4_K_M quant (`-ctk q4_0 -ctv q4_0`).
- **Benchmark Evaluation Harness**: Authored [eval_akhet_ra1.py](eval_akhet_ra1.py) based on `huggingface-community-evals` patterns, enabling bilingual testing across Arabic reasoning, Egyptian dialect, tool calling, GSM8K math, and safety refusals.
- **Hugging Face Spaces Interactive Demo**: Created deployment bundle in `space/` ([space/app.py](space/app.py), [space/README.md](space/README.md), [space/requirements.txt](space/requirements.txt)) configured for Gradio ZeroGPU deployment.
- **Publisher Script Security**: Updated [upload_to_hf.py](upload_to_hf.py) to add `eval_akhet_ra1.py` to documentation sync and exclude `.agents/**` and temporary agent artifacts from public upload.

## [0.1.0] - 2026-10-23

- **Hugging Face Hub Distribution & Automation**: Configured repository tracking for [alwkala/Akhet-Ra1](https://huggingface.co/alwkala/Akhet-Ra1). Added [.gitattributes](.gitattributes) with explicit `*.gguf` LFS tracking, authoring [.gitignore](.gitignore) to shield local caches (`hub/`, `xet/`) and logs, and implemented upload automation via [upload_to_hf.py](upload_to_hf.py) and [upload-to-hf.ps1](upload-to-hf.ps1).
- **Hugging Face Model Card Alignment**: Updated [README.md](README.md) YAML frontmatter (`license: apache-2.0`, `base_model: Qwen/Qwen3.5-4B`, tags: `gguf`, `llama-cpp`, `conversational`, `qwen3_5`), added direct GGUF CLI and Python download instructions, and integrated LM Studio quick-start steps.
- **Comprehensive GGUF Metadata Enhancement**: Successfully injected full GGUF standard metadata into `Ra-1-4B-Q4_K_M.gguf`: `general.author: "Alwkala Digital Labs"`, `general.organization: "Alwkala Digital Labs"`, `general.finetune: "Akhet-Ra1"`, `general.languages: ['ar', 'en']`, `general.tags: ['text-generation', 'arabic', 'agents', 'tool-use', 'akhetra']`, `general.url: "https://alwkala.com"`, `general.version: "0.1.0"`, `general.basename: "Akhet-Ra1"`, and `general.name: "Akhet-Ra1-4B"`.
- **Launcher Argument Cleanup**: Cleaned up [run-Ra-0.ps1](file:///a:/.lmstudio/Akhet/Ra-1/run-Ra-0.ps1) and [run-Ra-tui.ps1](file:///a:/.lmstudio/Akhet/Ra-1/run-Ra-tui.ps1) by removing unsupported `--system-prompt-file` server CLI flag, ensuring clean boot on port 8080.
- **System Prompt Specification**: Documented usage for [`system_prompt.txt`](file:///a:/.lmstudio/Akhet/Ra-1/system_prompt.txt) and [`SYSTEM_PROMPT.md`](file:///a:/.lmstudio/Akhet/Ra-1/SYSTEM_PROMPT.md) for client API requests and LM Studio UI system prompt settings.
- **System Prompt Templates & Specification**: Created [`system_prompt.txt`](system_prompt.txt) and [`SYSTEM_PROMPT.md`](SYSTEM_PROMPT.md) defining the foundational alignment, bilingual personality, tool calling, and governance-aware boundaries for Akhet-Ra1.
- **Verified GGUF Metadata Extraction**: Extracted exact internal model parameters directly from `Ra-1-4B-Q4_K_M.gguf`: 4,205,751,296 parameters (4.2B), 256K native training context (`n_ctx_train: 262144`), Qwen3.5 hybrid SSM + Attention architecture (`qwen35.ssm`), 248,320 vocabulary size, and Apache-2.0 license.
- **Empirical Behavioral Verification**: Probed running llama-server endpoint; confirmed active Chain-of-Thought reasoning support (`reasoning_content` / `<think>`), native function calling (`<tool_call>`), and Arabic/Egyptian dialect comprehension.
- **Hugging Face Model Card (`README.md`)**: Full YAML metadata frontmatter, model summary, design philosophy, intended use cases, and ecosystem architecture.
- **Arabic Model Card (`MODEL_CARD_AR.md`)**: Complete native Arabic specification, architecture details, and governance guidelines.
- **Quick-Start & Inference Guides**: Documented usage for `run-Ra-tui.ps1` (live TUI dashboard), `run-Ra-0.ps1` (headless runner), and direct `llama-server.exe` flags.
- **Hardware Footprint Matrix**: Documented memory requirements for `Ra-1-4B-Q4_K_M.gguf` (2.52 GB) running with 100% GPU offload (99 layers) and 32K context on 6GB VRAM GPUs with KV cache quantization (`q4_0`).
- **Evaluation & Benchmarking Protocol**: Formal test suite outline covering ArabicMMLU, dialect robustness, IFEval, GSM8K, and BFCL tool calling.
- **Ecosystem Architecture Documentation**: Defined the architectural boundary between **Ra** (Intelligence layer) and **Akhet** (Runtime & Governance layer).
- **Roadmap (`ROADMAP.md`)**: Established development milestones from draft specification to benchmarked production release.
