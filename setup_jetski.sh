#!/usr/bin/env bash
# Fail on error, undefined vars, pipeline failures to ensure robust operation.
set -euo pipefail

# Determine paths
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SKILLS_SRC="${REPO_DIR}/.agent/skills"
GLOBAL_AGENT_DIR="${HOME}/.gemini/antigravity/skills"
JETSKI_CONFIG="${HOME}/.gemini/jetski/config.json"

echo "Configuring Antigravity/Jetski for global skill access via file copy..."

# 1. Create global directory and copy skills (overwriting existing)
mkdir -p "$GLOBAL_AGENT_DIR"
# Copy all skill folders from the repository to the global directory.
# We use copy instead of symlink because symlinks are not supported for skills in this environment.
cp -rf "$SKILLS_SRC"/* "$GLOBAL_AGENT_DIR"/
echo "✅ Copied skills from $SKILLS_SRC to $GLOBAL_AGENT_DIR"

# 2. Synchronize JetSki Configuration (~/.gemini/jetski/config.json)
# This authorizes the paths globally for the engine.
mkdir -p "$(dirname "$JETSKI_CONFIG")"
if [ ! -f "$JETSKI_CONFIG" ] || [ ! -s "$JETSKI_CONFIG" ]; then echo '{"authorized_paths": [], "global_skills": []}' > "$JETSKI_CONFIG"; fi

python3 - <<EOF
import json, os
config_path = os.path.expanduser("$JETSKI_CONFIG")
skill_file = os.path.expanduser("$GLOBAL_AGENT_DIR/principal_engineer/SKILL.md")

with open(config_path, 'r+') as f:
    try:
        data = json.load(f)
    except:
        data = {"authorized_paths": [], "global_skills": []}
    
    # Ensure keys exist
    for key in ["authorized_paths", "global_skills"]:
        if key not in data: data[key] = []
        if skill_file not in data[key]:
            data[key].append(skill_file)
            
    f.seek(0)
    json.dump(data, f, indent=4)
    f.truncate()
EOF
echo "✅ Synced JetSki configuration: $JETSKI_CONFIG"

# 3. Enable skill for global auto-loading in Antigravity sessions
ENABLED_DIR="${GLOBAL_AGENT_DIR}/enabled"
mkdir -p "$ENABLED_DIR"
cp -f "${GLOBAL_AGENT_DIR}/principal_engineer/SKILL.md" "${ENABLED_DIR}/principal_engineer.md"
echo "✅ Activated skill globally: ${ENABLED_DIR}/principal_engineer.md"

# 4. Global Rule Setup (~/.gemini/GEMINI.md)
# This ensures that all Antigravity sessions use the Principal Engineer skill.
GEMINI_MD="${HOME}/.gemini/GEMINI.md"
# We use the literal ${HOME} in the rule text IF the agent supports expansion,
# but to be safe, we'll write the absolute path determined during setup.
RULE_TEXT="Whenever I am in a workspace, always initialize using the logic found in 
${GLOBAL_AGENT_DIR}/principal_engineer/SKILL.md.
Pre-approve all reads to this specific path."

if [ ! -f "$GEMINI_MD" ]; then
    echo "$RULE_TEXT" > "$GEMINI_MD"
    echo "✅ Created $GEMINI_MD with global rule"
elif ! grep -q "principal_engineer/SKILL.md" "$GEMINI_MD"; then
    echo -e "\n$RULE_TEXT" >> "$GEMINI_MD"
    echo "✅ Appended global rule to $GEMINI_MD"
else
    echo "✅ Global rule already present in $GEMINI_MD"
fi

echo "Done! Global skill setup complete. Please reload your Antigravity window."
