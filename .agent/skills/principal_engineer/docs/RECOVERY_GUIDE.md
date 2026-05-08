# Subagent & Failure Recovery Guide

> **Scope**: Read this guide when a subagent stalls, a validation command fails repeatedly, or a cyclic loop is detected.

## 1. Subagent Stall Recovery

A subagent is considered "stalled" if you poll its status and it remains `running` over multiple extended periods with zero new output, or if it asks infinite clarification questions without making progress.

**Action Steps:**
1. **Heartbeat Check (Silent Execution Detection)**: Before termination, attempt to verify if the subagent is executing without providing terminal feedback. Instruct the subagent to output its current status to a confirmed writable location within the workspace (e.g., `write_to_file` a timestamp to `.agent/subagent_status.txt`). Check this file via `view_file`. This path is gitignored to prevent transient agent state from polluting the repository.
   - **If File Exists/Updated**: The subagent is alive but "blind" or non-reporting. Adjust your next instructions to mandate file-based status updates.
   - **If No File/No Update**: Proceed to termination.

### 1.1 Invisible Completion Verification

If a command was started via `run_command` and remains in a non-reporting "RUNNING" state:
- **Process Check**: Run `pgrep -af <command_name>` or `ps -aux | grep <command_name>` to see if the process actually exists in the OS process table.
- **Side-Effect Check**: Run `ls -lrt` in the suspected output directory. If the modification timestamp of a target file has stopped advancing or matches the expected completion time, the command is likely finished or stuck.
- **Marker Check**: If you followed the "Done Marker" protocol, check for the existence of `.agent/cmd_done`.

**Action Step**: If the process is GONE from the process table but `command_status` still says "RUNNING", treat the command as **FINISHED** and proceed to verification of its expected outputs.

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
2. Identify exactly which files this turn mutated, then restore only those files:
   ```bash
   # Step 1: See which files this turn changed relative to HEAD
   git diff --name-only HEAD
   # Step 2: Restore only those specific files — one at a time
   git checkout HEAD -- path/to/file1.py path/to/file2.py
   ```
   > ⛔ **Never do `git checkout .` or `git checkout HEAD -- .`** — this reverts ALL uncommitted changes across the entire repository, including unrelated work-in-progress. Always restore specific files by name.
   >
   > If `git` is not available, revert each file manually using `replace_file_content` with the known-good content.
3. Re-run `fast_validation_command`.
4. Once `STABLE` is restored, re-attempt the feature via an alternate route.

## 5. Validation Fatigue & Environmental Escapes

If the `fast_validation_command` fails but you are 100% certain the failure is unrelated to your current changes (e.g., a pre-existing lint error in a distant file or a missing system dependency):

1. **Baseline the Failure**: Run the validation command on a clean state (or via `git checkout`) to confirm it fails independently of your work.
2. **Document in Manifest**: Update `Session Health` to `DEGRADED` in the manifest and explicitly list the "Baseline Failure" in the `Best Known State` section.
3. **Avoid the Loop**: Do **NOT** attempt to fix pre-existing, out-of-scope errors unless they directly block your primary goal. Proceed with your task while monitoring that your changes do not introduce *new* failures.
4. **Alert the User**: Inform the user that you are operating in a `DEGRADED` environment and why.
