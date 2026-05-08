#!/usr/bin/env python3
"""
LLM Behavioral Test Runner for the principal-engineer skill.

Tests whether a weaker LLM correctly follows the protocol defined in SKILL.md
by running it through realistic scenario prompts, then grading the response.

Architecture:
  Subject model  : gemini-2.0-flash-lite  (simulates a less-capable LLM)
  Grader model   : gemini-2.0-flash       (evaluates correctness against rubric)

Usage:
  python3 tests/run_tests.py
  python3 tests/run_tests.py --scenario 01_turn_start
  python3 tests/run_tests.py --verbose

Requirements:
  pip install google-generativeai
  export GEMINI_API_KEY="your-key-from-aistudio.google.com"
"""

import argparse
import json
import os
import sys
import time
from pathlib import Path

# ---------------------------------------------------------------------------
# Dependency check — auto-relaunch via ~/.agent-venv if needed
# ---------------------------------------------------------------------------
try:
    import google.generativeai as genai
except ImportError:
    import subprocess, os, sys
    venv_python = os.path.expanduser("~/.agent-venv/bin/python3")
    if os.path.exists(venv_python) and sys.executable != venv_python:
        # Re-exec this script inside the agent venv transparently
        os.execv(venv_python, [venv_python] + sys.argv)
    # If we get here the venv also doesn't have it — show helpful error
    print("❌ Missing dependency: google-generativeai")
    print("")
    print("Run these commands to set up the agent venv:")
    print("  sudo apt-get install -y python3-pip python3-venv  # Ubuntu/Debian")
    print("  python3 -m venv ~/.agent-venv")
    print("  ~/.agent-venv/bin/pip install google-generativeai==0.8.6")
    print("")
    print("Then set your API key (free at https://aistudio.google.com/app/apikey):")
    print("  echo 'export GEMINI_API_KEY=\"your-key-here\"' >> ~/.bash_secrets")
    sys.exit(1)

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
SKILL_DIR = Path(__file__).parent.parent
SKILL_FILE = SKILL_DIR / "SKILL.md"
SCENARIOS_DIR = Path(__file__).parent / "scenarios"

SUBJECT_MODEL = "gemini-2.0-flash-lite"
GRADER_MODEL = "gemini-2.0-flash"

# Retry settings for transient API errors
MAX_RETRIES = 3
RETRY_DELAY_S = 5


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def load_api_key() -> str:
    """Load and validate the Gemini API key from the environment."""
    key = os.environ.get("GEMINI_API_KEY", "").strip()
    if not key:
        print("❌ GEMINI_API_KEY environment variable is not set.")
        print("")
        print("Get a free key at: https://aistudio.google.com/app/apikey")
        print("Then run:  export GEMINI_API_KEY='your-key-here'")
        sys.exit(1)
    return key


def load_skill_content() -> str:
    """Read the SKILL.md file that will be injected into subject prompts."""
    if not SKILL_FILE.exists():
        print(f"❌ SKILL.md not found at: {SKILL_FILE}")
        sys.exit(1)
    return SKILL_FILE.read_text(encoding="utf-8")


def load_scenarios(filter_id: str | None = None) -> list[dict]:
    """Load all scenario JSON files, optionally filtered by prefix/id."""
    if not SCENARIOS_DIR.exists():
        print(f"❌ Scenarios directory not found: {SCENARIOS_DIR}")
        sys.exit(1)

    files = sorted(SCENARIOS_DIR.glob("*.json"))
    if not files:
        print(f"❌ No scenario JSON files found in: {SCENARIOS_DIR}")
        sys.exit(1)

    scenarios = []
    for f in files:
        try:
            data = json.loads(f.read_text(encoding="utf-8"))
        except json.JSONDecodeError as e:
            print(f"⚠️  Skipping {f.name}: invalid JSON — {e}")
            continue

        if filter_id and filter_id not in data.get("id", "") and filter_id not in f.stem:
            continue
        scenarios.append(data)

    if not scenarios:
        print(f"❌ No scenarios matched filter: '{filter_id}'")
        sys.exit(1)

    return scenarios


def call_model(model_name: str, prompt: str, temperature: float = 0.2) -> str:
    """Call the Gemini API with retry logic for transient errors."""
    model = genai.GenerativeModel(model_name)
    config = genai.types.GenerationConfig(temperature=temperature)

    for attempt in range(1, MAX_RETRIES + 1):
        try:
            response = model.generate_content(prompt, generation_config=config)
            return response.text.strip()
        except Exception as e:
            err = str(e)
            if attempt < MAX_RETRIES and ("429" in err or "503" in err or "timeout" in err.lower()):
                print(f"   ⚠️  Transient API error (attempt {attempt}/{MAX_RETRIES}): {err[:80]}")
                time.sleep(RETRY_DELAY_S * attempt)
                continue
            raise


def extract_verdict(grader_response: str) -> str:
    """
    Parse PASS or FAIL from the first line of the grader's response.
    Returns 'PASS', 'FAIL', or 'UNKNOWN' if unparseable.
    """
    first_line = grader_response.strip().splitlines()[0].strip().upper()
    if first_line.startswith("PASS"):
        return "PASS"
    if first_line.startswith("FAIL"):
        return "FAIL"
    # Fallback: search anywhere in first two lines
    for line in grader_response.strip().splitlines()[:2]:
        if "PASS" in line.upper():
            return "PASS"
        if "FAIL" in line.upper():
            return "FAIL"
    return "UNKNOWN"


# ---------------------------------------------------------------------------
# Core test runner
# ---------------------------------------------------------------------------

def run_scenario(scenario: dict, skill_content: str, verbose: bool) -> dict:
    """Run a single scenario and return a result dict."""
    scenario_id = scenario["id"]
    description = scenario.get("description", "")
    subject_prompt_template = scenario["subject_prompt"]
    grader_rubric = scenario["grader_rubric"]
    expected = scenario.get("expected_result", "PASS").upper()

    print(f"\n{'─' * 60}")
    print(f"▶  {scenario_id}")
    print(f"   {description}")

    # Render subject prompt
    subject_prompt = subject_prompt_template.replace("{skill_content}", skill_content)

    # Step 1: Ask the subject (weak) model
    print(f"   Calling subject ({SUBJECT_MODEL})...", end=" ", flush=True)
    try:
        subject_response = call_model(SUBJECT_MODEL, subject_prompt, temperature=0.3)
        print("done")
    except Exception as e:
        print(f"ERROR\n   ❌ Subject model call failed: {e}")
        return {
            "id": scenario_id,
            "status": "ERROR",
            "expected": expected,
            "verdict": "ERROR",
            "match": False,
            "grader_reason": f"Subject call failed: {e}",
            "subject_response": "",
        }

    if verbose:
        print(f"\n   ── Subject Response ──\n{subject_response}\n")

    # Step 2: Grade the subject's response
    grader_prompt = (
        f"You are a strict protocol compliance evaluator.\n\n"
        f"RUBRIC:\n{grader_rubric}\n\n"
        f"SUBJECT RESPONSE TO EVALUATE:\n{subject_response}\n\n"
        f"Your verdict:"
    )

    print(f"   Calling grader  ({GRADER_MODEL})...", end=" ", flush=True)
    try:
        grader_response = call_model(GRADER_MODEL, grader_prompt, temperature=0.0)
        print("done")
    except Exception as e:
        print(f"ERROR\n   ❌ Grader model call failed: {e}")
        return {
            "id": scenario_id,
            "status": "ERROR",
            "expected": expected,
            "verdict": "ERROR",
            "match": False,
            "grader_reason": f"Grader call failed: {e}",
            "subject_response": subject_response,
        }

    verdict = extract_verdict(grader_response)
    grader_reason = "\n".join(grader_response.strip().splitlines()[1:]).strip()

    match = verdict == expected

    # Result symbol
    if match and verdict == "PASS":
        symbol = "✅ PASS"
    elif match and verdict == "FAIL":
        symbol = "⚠️  EXPECTED FAIL"
    elif verdict == "UNKNOWN":
        symbol = "❓ UNKNOWN"
    else:
        symbol = "❌ FAIL"

    print(f"   {symbol}  — {grader_reason}")

    if verbose:
        print(f"\n   ── Grader Full Response ──\n{grader_response}\n")

    return {
        "id": scenario_id,
        "status": symbol,
        "expected": expected,
        "verdict": verdict,
        "match": match,
        "grader_reason": grader_reason,
        "subject_response": subject_response,
    }


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="LLM behavioral test runner for the principal-engineer skill."
    )
    parser.add_argument(
        "--scenario",
        metavar="ID",
        help="Run only the scenario whose id or filename contains this string.",
    )
    parser.add_argument(
        "--verbose", "-v",
        action="store_true",
        help="Print full subject and grader responses for each scenario.",
    )
    args = parser.parse_args()

    api_key = load_api_key()
    genai.configure(api_key=api_key)

    skill_content = load_skill_content()
    scenarios = load_scenarios(filter_id=args.scenario)

    print(f"\n🧪 Principal Engineer Skill — LLM Behavioral Tests")
    print(f"   Subject model : {SUBJECT_MODEL}")
    print(f"   Grader model  : {GRADER_MODEL}")
    print(f"   Scenarios     : {len(scenarios)}")
    print(f"   SKILL.md      : v{extract_version(skill_content)}")

    results = []
    for scenario in scenarios:
        result = run_scenario(scenario, skill_content, verbose=args.verbose)
        results.append(result)

    # Summary table
    passed = sum(1 for r in results if r["match"] and r["verdict"] == "PASS")
    failed = sum(1 for r in results if not r["match"] or r["verdict"] in ("FAIL", "UNKNOWN", "ERROR"))
    total = len(results)

    print(f"\n{'═' * 60}")
    print(f"Results: {passed}/{total} passed")
    print(f"{'═' * 60}")

    for r in results:
        mark = "✅" if r["match"] and r["verdict"] == "PASS" else "❌"
        print(f"  {mark}  {r['id']:<35}  verdict={r['verdict']}  expected={r['expected']}")

    if failed > 0:
        print(f"\n❌ {failed} test(s) failed.")
        sys.exit(1)
    else:
        print(f"\n✅ All {total} tests passed.")
        sys.exit(0)


def extract_version(skill_content: str) -> str:
    """Extract version from YAML frontmatter."""
    for line in skill_content.splitlines():
        if line.startswith("version:"):
            return line.split(":", 1)[1].strip()
    return "unknown"


if __name__ == "__main__":
    main()
