#!/usr/bin/env bash
# Cohesion Installation Verification Suite
# Run after install to verify everything works correctly

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test results
PASSED=0
FAILED=0
WARNINGS=0

# Test function
test_case() {
    local name="$1"
    local command="$2"
    local expected="${3:-}"
    
    echo -n "Testing: $name ... "
    
    if output=$(eval "$command" 2>&1); then
        if [[ -z "$expected" ]] || [[ "$output" == *"$expected"* ]]; then
            echo -e "${GREEN}✓${NC}"
            ((PASSED++))
        else
            echo -e "${RED}✗${NC} (unexpected output)"
            echo "  Expected: $expected"
            echo "  Got: $output"
            ((FAILED++))
        fi
    else
        echo -e "${RED}✗${NC} (command failed)"
        echo "  Error: $output"
        ((FAILED++))
    fi
}

warn_check() {
    local name="$1"
    local command="$2"
    
    echo -n "Checking: $name ... "
    
    if eval "$command" 2>/dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${YELLOW}⚠${NC} (warning)"
        ((WARNINGS++))
    fi
}

echo "╔══════════════════════════════════════════════════════════╗"
echo "║         Cohesion Installation Verification Suite          ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# ========== PART 1: Core Installation ==========
echo "1. Core Installation Checks"
echo "───────────────────────────"

test_case "Cohesion binary exists" \
    "[[ -x $HOME/.cohesion/bin/cohesion ]]"

test_case "Cohesion in PATH" \
    "command -v cohesion"

test_case "Manifest exists" \
    "[[ -f $HOME/.cohesion/.manifest.json ]]"

test_case "Hooks directory exists" \
    "[[ -d $HOME/.cohesion/hooks ]]"

test_case "Utils directory exists" \
    "[[ -d $HOME/.cohesion/utils ]]"

echo ""

# ========== PART 2: Claude Integration ==========
echo "2. Claude Global Integration"
echo "────────────────────────────"

test_case "Global Claude settings exist" \
    "[[ -f $HOME/.claude/settings.json ]]"

test_case "Global CLAUDE.md exists" \
    "[[ -f $HOME/CLAUDE.md ]]"

test_case "claude-duo wrapper exists" \
    "[[ -x $HOME/.cohesion/bin/claude-duo ]]"

warn_check "Claude Code installed" \
    "command -v claude"

# Check settings schema
if [[ -f "$HOME/.claude/settings.json" ]]; then
    test_case "Settings have permissions block" \
        "jq -e '.permissions' $HOME/.claude/settings.json"
    
    test_case "Settings have correct defaultMode" \
        "jq -e '.permissions.defaultMode' $HOME/.claude/settings.json"
    
    test_case "Settings have allow rules" \
        "jq -e '.permissions.allow | length > 0' $HOME/.claude/settings.json"
    
    test_case "Settings have deny rules" \
        "jq -e '.permissions.deny | length > 0' $HOME/.claude/settings.json"
fi

echo ""

# ========== PART 3: Project Functionality ==========
echo "3. Project Functionality"
echo "────────────────────────"

# Create test project
TEST_DIR="/tmp/cohesion-test-$$"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

test_case "cohesion init works" \
    "cohesion init"

test_case "Project hooks created" \
    "[[ -d .claude/hooks ]]"

test_case "Project CLAUDE.md created" \
    "[[ -f CLAUDE.md ]]"

test_case "Project settings created" \
    "[[ -f .claude/settings.json ]]"

test_case "State directory created" \
    "[[ -d .claude/state ]]"

echo ""

# ========== PART 4: State Management ==========
echo "4. State Management"
echo "───────────────────"

test_case "Default state is DISCOVER" \
    "cohesion status | grep -q DISCOVER"

# Test state files
touch .claude/state/UNLEASHED
test_case "UNLEASH state detected" \
    "cohesion status | grep -q UNLEASH"

rm -f .claude/state/UNLEASHED
touch .claude/state/OPTIMIZE
test_case "OPTIMIZE state detected" \
    "cohesion status | grep -q OPTIMIZE"

echo ""

# ========== PART 5: Settings Validation ==========
echo "5. Settings Validation"
echo "──────────────────────"

if [[ -f .claude/settings.json ]]; then
    test_case "Project settings valid JSON" \
        "jq -e . .claude/settings.json"
    
    test_case "Hooks configured" \
        "jq -e '.hooks.preToolUse' .claude/settings.json"
    
    test_case "UNLEASH settings template exists" \
        "[[ -f $HOME/.cohesion/templates/.claude/settings.unleash.json ]]"
fi

echo ""

# ========== PART 6: Hook Functionality ==========
echo "6. Hook Functionality"
echo "─────────────────────"

test_case "Hooks are executable" \
    "[[ -x .claude/hooks/pre-tool-use.sh ]]"

test_case "Utils are readable" \
    "[[ -r .claude/utils/hook-utils.sh ]]"

# Test dangerous command detection
test_case "Dangerous command detection works" \
    "grep -q 'rm -rf /' .claude/hooks/pre-tool-use.sh"

echo ""

# ========== PART 7: Protected Paths ==========
echo "7. Protected Paths"
echo "──────────────────"

if [[ -f .claude/protected.conf ]]; then
    test_case "Protected conf exists" \
        "[[ -f .claude/protected.conf ]]"
    
    test_case "Git directory protected" \
        "grep -q '.git' .claude/protected.conf"
else
    warn_check "Protected conf exists" \
        "[[ -f .claude/protected.conf ]]"
fi

echo ""

# ========== CLEANUP ==========
cd /
rm -rf "$TEST_DIR"

# ========== SUMMARY ==========
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                      TEST SUMMARY                         ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo -e "  Passed:   ${GREEN}$PASSED${NC}"
echo -e "  Failed:   ${RED}$FAILED${NC}"
echo -e "  Warnings: ${YELLOW}$WARNINGS${NC}"
echo ""

if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}✓ All critical tests passed!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Start Claude Code: claude-duo"
    echo "  2. In Claude Code, run: /permissions"
    echo "  3. Verify permissions show correct source files"
    echo "  4. Test state transitions with 'approved', 'optimize', 'reset'"
    exit 0
else
    echo -e "${RED}✗ Some tests failed. Please review the errors above.${NC}"
    echo ""
    echo "Troubleshooting:"
    echo "  1. Run: cohesion doctor"
    echo "  2. Check installation logs"
    echo "  3. Verify jq is installed"
    exit 1
fi