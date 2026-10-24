#!/usr/bin/env python3
"""
Upload script for Akhet-Ra1 to Hugging Face Hub.
Repository: alwkala/Akhet-Ra1
"""

import os
import sys
import argparse
from pathlib import Path
from huggingface_hub import HfApi, login

REPO_ID = "alwkala/Akhet-Ra1"
REPO_TYPE = "model"

# List of files to exclude from upload
IGNORE_PATTERNS = [
    ".agents/**",
    ".agents-hf-skills/**",
    "akhet-models-repo/**",
    "space/**",
    "hub/**",
    "xet/**",
    "*.log",
    "*.tmp",
    "__pycache__/**",
    ".git/**",
    ".venv/**",
    "venv/**",
    ".env",
    "upload_to_hf.py",
]

def check_login(api: HfApi, token: str | None = None) -> str:
    """Verifies authentication and returns the logged-in username."""
    if token:
        login(token=token, add_to_git_credential=True)
    
    try:
        user_info = api.whoami()
        username = user_info.get("name")
        print(f"[*] Authenticated as Hugging Face user: {username}")
        return username
    except Exception:
        print("[!] Not authenticated with Hugging Face.")
        print("[*] Please run 'hf auth login' in your terminal,")
        print("[*] or provide your Hugging Face write token using --token <HF_TOKEN>")
        token_input = input("Enter Hugging Face Write Token (or press Enter to exit): ").strip()
        if not token_input:
            print("[x] Authentication aborted.")
            sys.exit(1)
        login(token=token_input, add_to_git_credential=True)
        user_info = api.whoami()
        username = user_info.get("name")
        print(f"[+] Successfully authenticated as: {username}")
        return username

def main():
    parser = argparse.ArgumentParser(description="Upload Akhet-Ra1 files to Hugging Face Hub.")
    parser.add_argument("--repo-id", default=REPO_ID, help=f"Target HF repo ID (default: {REPO_ID})")
    parser.add_argument("--token", default=None, help="Hugging Face access token (write permissions)")
    parser.add_argument("--folder", default=".", help="Local directory path (default: .)")
    parser.add_argument("--only-docs", action="store_true", help="Only upload documentation files (skip large GGUF)")
    parser.add_argument("--only-model", action="store_true", help="Only upload the GGUF model file")
    
    args = parser.parse_args()
    folder_path = Path(args.folder).resolve()
    
    print("=" * 60)
    print(" Akhet-Ra1 — Hugging Face Publisher")
    print(f" Target Repository: {args.repo_id}")
    print(f" Source Directory:  {folder_path}")
    print("=" * 60)
    
    api = HfApi()
    check_login(api, token=args.token)
    
    # Verify repository exists or create it
    try:
        repo_info = api.repo_info(repo_id=args.repo_id, repo_type=REPO_TYPE)
        print(f"[+] Target repository exists: https://huggingface.co/{args.repo_id}")
    except Exception as e:
        print(f"[*] Creating repository {args.repo_id}...")
        api.create_repo(repo_id=args.repo_id, repo_type=REPO_TYPE, private=False, exist_ok=True)
        print(f"[+] Created repository: https://huggingface.co/{args.repo_id}")

    if args.only_docs:
        print("[*] Uploading documentation files only...")
        doc_files = [
            ".gitattributes",
            "README.md",
            "MODEL_CARD_AR.md",
            "SYSTEM_PROMPT.md",
            "system_prompt.txt",
            "CHANGELOG.md",
            "ROADMAP.md",
            "run-Ra-0.ps1",
            "run-Ra-tui.ps1",
            "eval_akhet_ra1.py",
        ]
        for f in doc_files:
            file_path = folder_path / f
            if file_path.exists():
                print(f"  -> Uploading {f}...")
                api.upload_file(
                    path_or_fileobj=str(file_path),
                    path_in_repo=f,
                    repo_id=args.repo_id,
                    repo_type=REPO_TYPE,
                    commit_message=f"docs: update {f}",
                )
        print("\n[+] All documentation files uploaded successfully!")
        return

    if args.only_model:
        gguf_file = folder_path / "Ra-1-4B-Q4_K_M.gguf"
        if not gguf_file.exists():
            print(f"[!] Error: {gguf_file} not found!")
            sys.exit(1)
        print(f"[*] Uploading model file: {gguf_file.name} (~{gguf_file.stat().st_size / (1024**3):.2f} GB)...")
        api.upload_file(
            path_or_fileobj=str(gguf_file),
            path_in_repo=gguf_file.name,
            repo_id=args.repo_id,
            repo_type=REPO_TYPE,
            commit_message=f"feat(model): upload {gguf_file.name}",
        )
        print(f"\n[+] Model {gguf_file.name} uploaded successfully!")
        return

    # Full folder upload with exclusions
    print("[*] Uploading repository files (including GGUF weights)...")
    print(f"[*] Excluding: {', '.join(IGNORE_PATTERNS)}")
    
    api.upload_folder(
        folder_path=str(folder_path),
        repo_id=args.repo_id,
        repo_type=REPO_TYPE,
        ignore_patterns=IGNORE_PATTERNS,
        commit_message="feat: release Akhet-Ra1 v0.1.0 model weights & documentation",
    )
    
    print("\n" + "=" * 60)
    print(" [+] SUCCESS: Akhet-Ra1 is now live on Hugging Face!")
    print(f" [+] URL: https://huggingface.co/{args.repo_id}")
    print("=" * 60)

if __name__ == "__main__":
    main()
