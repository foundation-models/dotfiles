# Hossein MacBook — Machine Spec

Recorded from system overview. Use for stack choices, memory limits, and when to run local vs cloud.

## Hardware

| Item | Value |
|------|--------|
| **SoC** | Apple M3 Max |
| **Memory** | 36 GB unified |

- **M3 Max:** Top-tier Apple silicon (CPU + GPU + NPU on one SoC). Strong for heavy parallel workloads, local AI/ML inference, video/image pipelines, and compiling large codebases.
- **36 GB unified:** GPU, CPU, and Neural Engine share it. Good for multiple containers, local LLMs in the ~7B–13B range (quantized comfortably, some unquantized), and large datasets without constant swapping.

## Software

| Item | Value |
|------|--------|
| **OS** | macOS Tahoe 26.2 |

- Latest macOS: best Metal + MLX support, Core ML / Accelerate improvements, and Apple Silicon scheduling.
- Caveat: some Python / CUDA-era tooling may lag or need Apple-specific paths (MLX, Metal, Core ML instead of CUDA).

## Strong at

- **Local AI (non-CUDA):** MLX, PyTorch MPS backend, Core ML model conversion + inference.
- **Full-stack dev:** Docker (arm64-native), FastAPI/Flask/Django, Vue/React builds.
- **Agentic / RAG:** RAG pipelines, vector DBs (FAISS, Qdrant, Chroma).

## Not ideal for

- CUDA-only workflows (no NVIDIA GPU).
- Training very large foundation models from scratch (fine-tuning: yes; full pretraining: use cloud GPUs).

## Reference

- Use for: optimal ML stack for this machine, memory-safe model sizes, when to run local vs cloud.
- Doc added: 2025-02-10.
