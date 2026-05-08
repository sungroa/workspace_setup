<!-- AGENT: Use this template when creating a new `.agent/project_manifest.md`.
     Replace all bracketed fields [ ] with actual data.
     Update `Last Updated` and `Context Budget` at every Turn-End.
     The example section below the divider shows a correctly filled manifest. -->

# 🧭 Project Manifest

## 📊 Session Data
- **Last Updated:** `[YYYY-MM-DDTHH:MM:SS]`
- **Session ID:** `[Current Conversation ID]`
- **Session Health:** `[STABLE | DEGRADED | HANDOFF_PENDING]`
- **Context Budget:** `~[XX]% (Turn [N])`

## 🎯 Objectives & Constraints
- **Primary Objective:** `[1-2 sentences describing the ultimate goal]`
- **STRICT_CONSTRAINTS:**
  1. `[Constraint 1, e.g., "Must not break backward compatibility"]`
  2. `[Constraint 2, e.g., "Only use vanilla CSS"]`

## 🛠️ Validation & State
- **fast_validation_command:** `[e.g., npm run lint]`
- **full_validation_command:** `[e.g., npm run build && npm run test]`
- **Best Known State:**
  - `[Detail the last safely verified state. Include Verification Tokens: e.g., "Pass: 42 tests"]`
- **Dead Ends:**
  - `[Document paths/libraries that failed 3+ times to avoid repeating agentic mistakes. e.g., "pip install grpcio fails on arm64 without pre-built wheel — use grpcio-binary instead"]`

## 📋 Action Plan

### Next Steps
- [ ] `[Immediate next atomic action]`
- [ ] `[Following action]`

### Progress Tracking
- [x] `[Completed task 1]`
- [/] `[In-progress task — started but not yet done]`
- [ ] `[Pending task]`

---

## ✅ Filled Example (reference only — remove from real manifest)

# 🧭 Project Manifest

## 📊 Session Data
- **Last Updated:** `2026-05-08T22:00:00Z`
- **Session ID:** `3ab1ed39-fb41-45d1-99a2-edf09e6b74e9`
- **Session Health:** `STABLE`
- **Context Budget:** `~18% (Turn 3)`

## 🎯 Objectives & Constraints
- **Primary Objective:** `Add user authentication to the REST API using JWT tokens.`
- **STRICT_CONSTRAINTS:**
  1. `Must not break existing /api/v1 endpoints.`
  2. `No third-party auth libraries — use the in-house jwt_util module.`

## 🛠️ Validation & State
- **fast_validation_command:** `npm run lint && npm run test:unit`
- **full_validation_command:** `npm run build && npm run test`
- **Best Known State:**
  - `All 57 unit tests passing as of Turn 2. Auth middleware scaffolded but not yet wired to routes.`
  - `Verification Token: Pass: 57 tests (Turn 2)`
- **Dead Ends:**
  - `Attempted to use express-jwt v7 — incompatible with Node 18 ESM setup. Fails on import. Use manual jwt_util instead.`

## 📋 Action Plan

### Next Steps
- [ ] Wire auth middleware to `/api/v1/users` route.
- [ ] Add integration test for authenticated and unauthenticated requests.

### Progress Tracking
- [x] Scaffold JWT auth middleware in `src/middleware/auth.js`.
- [x] Add unit tests for token validation logic.
- [/] Wire middleware to routes (in progress).
