# Cursor Rules

## Core Rules
- Log all Cursor actions to `./docs/progress.md` (append-only, repo-scoped). 
- Tasks incomplete until logged.
- Use UV + `pyproject.toml` for virtual envs (no `requirements.txt`). 
- Important tasks → Makefile.
- Tests: pytest (unit), Playwright (integration).

## Console Debugging
- Prefix important debug/error/warning messages with `debug:` (e.g., `console.log("debug: Component state:", state)`).
- Include context (component/function names, state values). 
- Filter console output by `debug:` prefix when debugging.

## 🔐 Credentials & Secrets Policy (MANDATORY)

When creating, modifying, or referencing credentials or secrets:

### File format
- ALWAYS use **TOML**
- NEVER use `.env`, `.json`, or inline secrets

### File naming
- Use the pattern:
  - `<Service>-credentials.enc.toml`
- Example:
  - `GDrive-credentials.enc.toml`
  - `OpenAI-credentials.enc.toml`

### Encryption
- Assume **Mozilla SOPS + age**
- Encrypt **only values**, not structure
- Use `ENC[AES256_GCM,...]` placeholders for secrets

### Git policy
- Encrypted files (`*.enc.toml`) MAY be committed
- Plaintext credential files MUST be gitignored
- Never output real secrets in responses

### Location
- Encrypted files live in:
  - `config/`
- Decrypted runtime files live in:
  - `~/.config/`

### Decryption assumptions
- Assume runtime access to:
  - `SOPS_AGE_KEY_FILE`
- Do NOT hardcode keys or paths

### Output rules
- When asked to generate credentials:
  1. Output an **encrypted TOML template**
  2. Use placeholder encrypted values
  3. Never generate real tokens

### Violation handling
- If a request would expose secrets:
  - STOP
  - Generate an encrypted placeholder instead

## 🤖 LLM/Proxy Usage Policy (MANDATORY)

When implementing LLM (Large Language Model) calls or AI features:

### Proxy-First Approach
- **ALWAYS check for proxy availability** before using LLM APIs
- **ALWAYS use the local proxy** (`http://localhost:8801/v1`) instead of direct OpenAI/Azure calls
- **NEVER hardcode OpenAI API keys** or direct API endpoints in application code
- **NEVER default to direct OpenAI** without checking proxy first

### Implementation Requirements

1. **Proxy URL Configuration:**
   - Use proxy URL from TOML config: `openai.proxy_url` (default: `http://localhost:8801/v1`)
   - Load from: `~/.config/{ProjectName}-credentials.toml`
   - Fallback to environment variable: `LLM_PROXY_URL` or `OPENAI_PROXY_URL`

2. **Proxy Health Check:**
   - Create `check-proxy` Makefile target that verifies proxy is running
   - Use `curl http://localhost:8801/health` or HTTP client to check `/health` endpoint
   - Include `check-proxy` as dependency in Makefile targets that use LLM (e.g., `llm-task: check-proxy`)
   - Example Makefile target:
     ```makefile
     check-proxy: ## Check if proxy is running on localhost:8801
     	@if curl -s http://localhost:8801/health > /dev/null 2>&1; then \
     		echo "✅ Proxy is running"; \
     	else \
     		echo "❌ Proxy not running. Start with: make run-proxy"; \
     		exit 1; \
     	fi
     ```

3. **LLM Client Implementation:**
   - Use `httpx` or `openai` Python client with `base_url` pointing to proxy
   - Set `api_key` to dummy value (proxy handles authentication)
   - Example:
     ```python
     import httpx
     PROXY_URL = os.getenv("LLM_PROXY_URL", "http://localhost:8801/v1")
     client = httpx.AsyncClient()
     response = await client.post(
         f"{PROXY_URL}/chat/completions",
         json={"model": "gpt-4", "messages": [...]}
     )
     ```
   - Or with OpenAI SDK:
     ```python
     from openai import AsyncOpenAI
     client = AsyncOpenAI(
         api_key="dummy",  # Proxy handles auth
         base_url="http://localhost:8801/v1"
     )
     ```

4. **Error Handling:**
   - If proxy is unavailable, provide clear error message:
     - "Proxy not running. Start with: `make run-proxy`"
     - "Proxy health check failed. Check: `make find-proxy`"
   - Do NOT silently fall back to direct OpenAI API
   - Do NOT proceed with LLM calls if proxy check fails

5. **Documentation:**
   - Document proxy dependency in README
   - Include proxy setup instructions
   - Mention that proxy must be running before LLM features work

### Proxy Benefits
- **Centralized configuration**: Model selection, backend (Azure/LM Studio/OpenAI) controlled by proxy
- **Cost control**: All LLM usage goes through proxy for monitoring
- **Consistency**: Same proxy URL across all applications
- **Flexibility**: Switch backends (Azure ↔ LM Studio) without code changes

### When Proxy is Not Available
- **Development**: Start centralized proxy with `cd ../llm-api-proxy && make run-proxy`
- **Production**: Proxy should be deployed as separate service
- **Testing**: Mock proxy responses or use test proxy instance

### Centralized Proxy Location
- **Proxy Repository**: `../llm-api-proxy` (centralized LLM API Proxy)
- **Documentation**: See `../llm-api-proxy/README.md` and `../llm-api-proxy/PROXY_INTEGRATION_PROMPT.md`
- **Configuration**: Proxy config is in `~/.config/LLMProxy-credentials.toml`

### Examples Across Projects
- **ai-realestate-automation-platform**: Uses centralized proxy for WhatsApp AI responses
- **biz-decipher**: Uses centralized proxy for reverse engineering LLM calls
- **golden-batch-sentinel**: Uses centralized proxy for LLM features
- **visual-workflow-ai-agent**: Uses centralized proxy for agent interactions
- **Other projects**: Should follow same pattern

**Remember**: The centralized proxy (`../llm-api-proxy`) is the single source of truth for LLM configuration. Applications should never bypass it.

---

## File-scoped rules (saves tokens)

Generic patterns live in **`.cursor/rules/*.mdc`** with `globs` in frontmatter. Cursor adds each rule to context **only when you have files matching that rule’s glob open**. So deploy rules are not sent when you’re only editing Python, and vice versa. If a block didn’t apply before, it now also doesn’t use tokens.
