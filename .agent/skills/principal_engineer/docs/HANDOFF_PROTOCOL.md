# Handoff Protocol

> **When to read this file**: Only when the Context Budget reaches 🟠 HANDOFF READY (70%+) or 🔴 CRITICAL (80%+), or when receiving a handoff from a previous session.

## Preparing a Handoff (Outbound)

When crossing the 🟠 HANDOFF READY threshold, prepare the following in the manifest:

1. **Archive all completed work** to `project_history.md`.
2. **Update the manifest** with:
   - `Session Health: HANDOFF_PENDING`
   - `Context Budget: ~XX% (HANDOFF READY)`
   - A new `## Handoff Payload` section containing:
     - **Completed This Session**: Summary of what was accomplished.
     - **In-Flight Work**: Any partially completed task with exact state (branch, file, line).
     - **Blockers / Dead Ends**: Carried forward from current manifest.
     - **Next Steps**: Ordered, actionable list for the successor thread.
     - **Critical Files**: List of files the next thread should read first.
     - **Strict Constraints**: Carried forward verbatim.
3. **Generate a Handoff Prompt** — a self-contained message the user can paste into a new conversation to resume seamlessly. Format:

```markdown
## 🔄 Handoff Prompt — Copy & Paste Into New Thread

> I'm continuing work from a previous session. Please read the project manifest
> at `.agent/project_manifest.md` in workspace `<WORKSPACE_PATH>` and resume
> from the `Handoff Payload` section.
>
> **Previous Session ID:** <SESSION_ID>
> **Primary Objective:** <OBJECTIVE>
> **Current State:** <1-2 sentence summary>
> **Immediate Next Step:** <first item from Next Steps>
>
> Start by reading the manifest and validating the project state.
```

4. **Alert the user** with a clear message:
   > ⚠️ **Context budget at ~XX%.** I've prepared a handoff payload in the project manifest. Copy the prompt below into a new thread to continue seamlessly.

## Receiving a Handoff (Inbound)

When a conversation **starts** with a handoff prompt (or the manifest contains `Session Health: HANDOFF_PENDING`):
1. Read the full manifest, focusing on the `Handoff Payload` section.
2. Read all files listed under `Critical Files`.
3. Run the `validation_command` to verify project state.
4. Update `Session ID` to the current conversation ID.
5. Set `Session Health` based on step 3's result:
   - **Validation passed** → set to `STABLE`.
   - **Validation failed** → set to `DEGRADED`. Do NOT mark `STABLE` before validation passes.
6. Remove or archive the `Handoff Payload` section.
7. Begin work from `Next Steps`.
