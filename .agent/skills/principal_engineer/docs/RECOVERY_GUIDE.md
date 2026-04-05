# Subagent & Failure Recovery Guide

> **Scope**: Read this guide when a subagent stalls, a validation command fails repeatedly, or a cyclic loop is detected.

## 1. Subagent Stall Recovery

A subagent is considered "stalled" if you poll its status and it remains `running` over multiple extended periods with zero new output, or if it asks infinite clarification questions without making progress.

**Action Steps:**
1. **Heartbeat Check (Silent Execution Detection)**: Before termination, attempt to verify if the subagent is executing without providing terminal feedback. Instruct the subagent to output its current status to a confirmed writable location within the workspace (e.g., `write_to_file` a timestamp to `.agent/subagent_status.txt`). Check this file via `view_file`. Make sure to not use suffix in .gitignore.
   - **If File Exists/Updated**: The subagent is alive but "blind" or non-reporting. Adjust your next instructions to mandate file-based status updates.
   - **If No File/No Update**: Proceed to termination.
2. **Terminate**: Halt the stalled subagent immediately to prevent token bloat.
3. **Diagnose**: Check the last known tool output. Was it waiting for user input? Did it encounter an interactive prompt (e.g., `Do you want to continue? [Y/n]`)?
4. **Relaunch with Constraints**: Start a new subagent with *highly targeted* instructions. Include specific commands to bypass interactive prompts (e.g., use `-y` or `yes |`).

## 2. The 3-Strike "Dead End" Rule

If you or a subagent attempt the exact same sub-goal 3 times and fail due to environment constraints, broken dependencies, or logic errors:
1. **Halt Execution immediately**.
2. **Log the Failure**: Add a detailed entry in the `Dead Ends` section of the `project_manifest.md` explaining the root cause (e.g., "Library X does not support Windows natively. Failed 3 times attempting to force install.").
3. **Pivot or Escalate**: Propose an alternative architectural approach to the USER, or yield control entirely to ask for manual intervention. **Do NOT attempt a 4th repair**.

## 3. Search Loop Escapes

If you find yourself repeatedly searching directories and failing to locate files:
1. Check the `project_manifest.md` for known good entry points.
2. Stop unbounded recursive searches (`**/*.js`). Restrict scopes to absolute paths you have confirmed exist via `list_dir`.
3. If a critical file is missing, verify if the repository needs to undergo an initial `.setup` or `npm install` phase before the file is generated.

## 4. State Rollback Protocol

When `fast_validation_command` indicates `DEGRADED` health after a feature addition:
1. **Do not write new feature code**.
2. Immediately restore the files modified in this specific Turn to their previous state via standard `git checkout` or by manually reverting via `replace_file_content`.
3. Re-run `fast_validation_command`. 
4. Once `STABLE` is restored, re-attempt the feature via an alternate route.

## 5. Validation Fatigue & Environmental Escapes

If the `fast_validation_command` fails but you are 100% certain the failure is unrelated to your current changes (e.g., a pre-existing lint error in a distant file or a missing system dependency):

1. **Baseline the Failure**: Run the validation command on a clean state (or via `git checkout`) to confirm it fails independently of your work.
2. **Document in Manifest**: Update `Session Health` to `DEGRADED` in the manifest and explicitly list the "Baseline Failure" in the `Best Known State` section.
3. **Avoid the Loop**: Do **NOT** attempt to fix pre-existing, out-of-scope errors unless they directly block your primary goal. Proceed with your task while monitoring that your changes do not introduce *new* failures.
4. **Alert the User**: Inform the user that you are operating in a `DEGRADED` environment and why.
