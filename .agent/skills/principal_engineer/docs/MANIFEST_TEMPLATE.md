# 🧭 Project Manifest

> **Agent Instruction:** Use this template when creating a new `.agent/project_manifest.md`. Do not include this blockquote. Replace bracketed fields `[ ]` with actual data. **Update the `Last Updated` timestamp and `Context Budget` at every Turn-End.**

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
  - `[Document paths/libraries that failed 3+ times to avoid repeating agentic mistakes]`

## 📋 Action Plan

### Next Steps
- [ ] `[Immediate next atomic action]`
- [ ] `[Following action]`

### Progress Tracking
- [x] `[Completed task 1]`
- [x] `[Completed task 2]`
