# Project Manifest

- **Last Updated:** 2026-05-08T22:42:10Z
- **Session ID:** 3ab1ed39-fb41-45d1-99a2-edf09e6b74e9
- **Session Health:** STABLE
- **Context Budget:** ~38% (Turn 5)
- **Primary Objective:** Harden the `principal-engineer` skill (v1.1.0 → v1.2.0) for reliable use with less-capable LLMs, and add an LLM behavioral test suite.
- **STRICT_CONSTRAINTS:**
  - Do not create Tech Debt; properly document changes.
  - Do not break existing setup script behavior.
- **fast_validation_command:** bash -n setup.sh setup_linux.sh setup_mac.sh setup_windows.sh && python3 -m json.tool versions.json > /dev/null && python3 -m json.tool .agent/skills/principal_engineer/docs/manifest_schema.json > /dev/null
- **full_validation_command:** export GEMINI_API_KEY="..." && python3 .agent/skills/principal_engineer/tests/run_tests.py
- **Best Known State:**
  - All 6 skill files updated. JSON schema and versions.json pass python3 -m json.tool. All 8 scenario files present. Setup scripts updated for Linux, Mac, Windows.
  - Verification Token: All files exist, both JSON files valid (Turn 4)
- **Dead Ends:** None

## Next Steps
- [ ] User sets GEMINI_API_KEY and runs: `python3 .agent/skills/principal_engineer/tests/run_tests.py`
- [ ] Run `./sync_skills.sh` to propagate updated skill to the global agent directory

## Progress Tracking
- [x] Read and audited all 5 skill files (SKILL.md, MANIFEST_TEMPLATE, HANDOFF_PROTOCOL, RECOVERY_GUIDE, manifest_schema.json)
- [x] Created implementation plan artifact (12 failure modes identified)
- [x] Rewrote SKILL.md v1.2.0 (emergency card, numbered checklists, fixed section numbering §3/§4, expanded Mutation Tier definition)
- [x] Rewrote MANIFEST_TEMPLATE.md (HTML comment, filled positive example, [/] task, Dead Ends example)
- [x] Updated RECOVERY_GUIDE.md §4 (safe per-file rollback, explicit anti-example for `git checkout .`)
- [x] Updated HANDOFF_PROTOCOL.md (validation-gated health status)
- [x] Updated manifest_schema.json (additionalProperties: false, added [/] status enum)
- [x] Created tests/ directory with 8 LLM behavioral scenarios + run_tests.py + README.md
- [x] Updated setup_linux.sh, setup_mac.sh, setup_windows.sh to install google-generativeai
- [x] Added `pip.google-generativeai: "0.8.6"` pin to versions.json
