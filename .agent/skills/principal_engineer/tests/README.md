# Principal Engineer Skill — LLM Behavioral Tests

These tests verify that a less-capable LLM correctly follows the protocol defined in `SKILL.md`
by simulating realistic scenarios and grading the model's response against a rubric.

## How It Works

```
Subject model  →  gemini-2.0-flash-lite   (smallest/weakest — the model under test)
Grader model   →  gemini-2.0-flash        (evaluates subject response against rubric)
```

Each test scenario:
1. Injects `SKILL.md` into a realistic situation prompt
2. Asks the subject model what it would do
3. The grader model reads the response and checks it against a strict rubric
4. Reports PASS or FAIL with a one-sentence reason

## Prerequisites

```bash
pip install google-generativeai
```

Get a free API key at **https://aistudio.google.com/app/apikey**

Required API access: **Gemini API** (`generativelanguage.googleapis.com`) only.
No Google Cloud project or billing required for the free tier.

## Running Tests

```bash
# Set your API key
export GEMINI_API_KEY="your-key-here"

# Run all 8 tests
python3 tests/run_tests.py

# Run a single scenario
python3 tests/run_tests.py --scenario 01_turn_start

# Verbose mode (shows full subject + grader responses)
python3 tests/run_tests.py --verbose
```

Expected output when all pass:
```
✅ All 8 tests passed.
```

Estimated cost: **~$0.01 per full run** (all 8 scenarios) at pay-as-you-go rates.
The free tier (rate-limited) is sufficient for development use.

## Scenarios

| File | What It Tests |
|------|---------------|
| `01_turn_start.json` | Model reads manifest before any code changes |
| `02_mutation_tier.json` | Correctly classifies turns using `multi_replace_file_content` or `run_command` as Mutation Tier |
| `03_manifest_creation.json` | Produces a complete manifest with all required fields |
| `04_context_budget.json` | Applies budget estimation heuristics correctly |
| `05_handoff_trigger.json` | Freezes new work and prepares handoff at 70%+ budget |
| `06_dead_end_halt.json` | Halts and escalates after 3 consecutive failures |
| `07_constraint_primacy.json` | Constraints override goals — asks user before destructive action |
| `08_rollback_safety.json` | Uses per-file `git checkout HEAD -- <files>` instead of `git checkout .` |

## Adding New Scenarios

Create a new JSON file in `tests/scenarios/` following this schema:

```jsonc
{
  "id": "09_your_scenario_name",
  "description": "One sentence describing what behavior this tests.",
  "subject_prompt": "...(include {skill_content} placeholder for SKILL.md injection)...",
  "grader_rubric": "...precise PASS/FAIL criteria. Tell the grader to respond with PASS or FAIL on the first line...",
  "expected_result": "PASS"
}
```

File names are sorted alphabetically, so prefix with a two-digit number to control order.
