You are doing reverse engineering only (no product changes).

Project:
- PROJECT_NAME: <PI_intake or PI_insurance_verification>
- PROJECT_PATH: </absolute/path/to/repo>

Goal:
Create and maintain a documentation pack under `PROJECT_PATH/Docs/` so engineers can quickly navigate the codebase.

Constraints:
1) Do not modify existing source code or infra files; only add/update docs in `Docs/`.
2) Prefer non-mutating exploration (read/search/run safe inspection commands).
3) If tools like `rg` are unavailable, fall back to `find`/`grep`.
4) Use absolute file paths in references.
5) Add concrete evidence pointers (file + line) for major claims.
6) Keep an “assumptions / unknowns” section; do not guess silently.

Deliverables (create/update these files):
1) `Docs/reverse_engineering_report.md`
- Executive summary
- Main modules and responsibilities
- Runtime architecture (services, protocols, external systems)
- Data model overview (schemas/tables/entities and relationships)
- Main workflows / sequence flows (input -> processing -> persistence -> outputs)
- Entry points (APIs, jobs, scripts, CLIs)
- Configuration and environment dependencies
- Top findings (bugs/risks/tech debt), severity-ranked, with evidence
- Suggested next deep-dive areas

2) `Docs/app_or_main_flow.md`
- Deep dive on primary entrypoints (`app.py`, `main.py`, workers, schedulers, etc.)
- Request/response/data loading lifecycle
- Linkages between modules
- Error handling and transaction boundaries

3) `Docs/integration_catalog.md`
- External APIs/systems (Auth, DBs, cloud storage, third-party services)
- For each: where called, key methods/endpoints, required env vars, failure modes

4) `Docs/navigation_index.md`
- “If you need to change X, start in Y” map
- Key files by concern
- Glossary of project-specific terms

Process:
- Start with a repo map.
- Read high-signal files first (README, entrypoints, configs, deployments, tests).
- Build docs incrementally and keep “Last updated” date in each file.
- After each major discovery, update the relevant doc immediately.

Output style:
- Be concise, factual, and evidence-based.
- Include explicit file references like `/abs/path/file.py:123`.
