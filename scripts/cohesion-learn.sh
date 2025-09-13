#!/usr/bin/env bash
# Cohesion Script Header (standardized)
# Requires: bash >= 3.2 or zsh >= 5 (zsh-compatible via cohesion-utils)
set -euo pipefail

_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd -P)"
_utils_candidates=(
  "$_script_dir/../.claude/utils/cohesion-utils.sh"
  "$_script_dir/../../.claude/utils/cohesion-utils.sh"
  "$_script_dir/../utils/cohesion-utils.sh"
  "$HOME/.cohesion/utils/cohesion-utils.sh"
  "$PWD/.claude/utils/cohesion-utils.sh"
)
for _u in "${_utils_candidates[@]}"; do
  # shellcheck disable=SC1090
  if [ -f "$_u" ]; then . "$_u"; _found_utils=1; break; fi
done
: "${_found_utils:=0}"
if [ "$_found_utils" -eq 0 ]; then
  printf 'cohesion: missing cohesion-utils.sh\n' >&2; exit 1
fi
unset _script_dir _u _utils_candidates _found_utils

# Define colors if not already defined
: "${BOLD:=\033[1m}"
: "${RESET:=\033[0m}"
: "${CYAN:=\033[0;36m}"
: "${BLUE:=\033[0;34m}"
: "${GREEN:=\033[0;32m}"
: "${YELLOW:=\033[1;33m}"
: "${RED:=\033[0;31m}"
: "${MAGENTA:=\033[0;35m}"

# Check if --first-run flag was passed
first_run=false
if [[ "${1:-}" == "--first-run" ]]; then
    first_run=true
fi

if $first_run; then
    # Skip interactive parts in CI/non-interactive mode
    if [[ -n "${CI:-}" || -n "${NON_INTERACTIVE:-}" || ! -t 0 ]]; then
        echo ""
        echo "🤝 Welcome to Cohesion!"
        echo ""
        echo "Run 'cohesion learn' anytime to explore the Core Principles interactively."
        exit 0
    fi
    
    echo ""
    echo -e "${BOLD}🤝 Welcome to Cohesion!${RESET}"
    echo ""
    echo "Cohesion uses 6 core principles that make development with Claude Code"
    echo "10x more efficient by preventing problems before they happen."
    echo ""
    echo -e "${CYAN}These principles are enforced automatically by the system.${RESET}"
    echo -e "${CYAN}Your AI assistant has been trained on them.${RESET}"
    echo -e "${CYAN}The hooks guide you toward success.${RESET}"
    echo ""
    echo "──────────────────────────────────────────────────────────"
    echo ""
    echo -e "${BOLD}The 6 Core Principles:${RESET}"
    echo ""
    echo -e "  ${BLUE}1.${RESET} 🧠 ${BOLD}Think-First${RESET}"
    echo "     10 minutes of planning saves hours of debugging"
    echo ""
    echo -e "  ${BLUE}2.${RESET} ✅ ${BOLD}Always-Works${RESET}"
    echo "     If it only works on your machine, it doesn't work"
    echo ""
    echo -e "  ${BLUE}3.${RESET} 🕵️ ${BOLD}Reality-Check${RESET}"
    echo "     When expected ≠ actual, investigate why"
    echo ""
    echo -e "  ${BLUE}4.${RESET} 📋 ${BOLD}Approval-Criteria${RESET}"
    echo "     Know what needs permission vs what doesn't"
    echo ""
    echo -e "  ${BLUE}5.${RESET} 📝 ${BOLD}Clear-Naming${RESET}"
    echo "     Good names eliminate confusion and bugs"
    echo ""
    echo -e "  ${BLUE}6.${RESET} 🔄 ${BOLD}Close-the-Loop${RESET}"
    echo "     Major changes require systematic impact analysis"
    echo ""
    echo "──────────────────────────────────────────────────────────"
    echo ""
    echo -e "${GREEN}Ready to learn more? Press ENTER to continue...${RESET}"
    read -r
    clear
fi

# Interactive menu
show_menu() {
    # Ensure colors are defined
    : "${BOLD:=\033[1m}"
    : "${RESET:=\033[0m}"
    : "${BLUE:=\033[0;34m}"
    : "${YELLOW:=\033[1;33m}"
    
    echo ""
    echo -e "${BOLD}📚 Cohesion Learn - Choose Your Path${RESET}"
    echo ""
    echo "──────────────────────────────────────────────────────────"
    echo ""
    echo -e "  ${BLUE}1${RESET}) 🧠 Think Before You Build ${YELLOW}(2 min)${RESET}"
    echo "     Why planning prevents debugging"
    echo ""
    echo -e "  ${BLUE}2${RESET}) ✅ The 'Works Everywhere' Test ${YELLOW}(3 min)${RESET}"
    echo "     How to avoid 'but it worked for me'"
    echo ""
    echo -e "  ${BLUE}3${RESET}) 🕵️ Reality-Check Protocol ${YELLOW}(2 min)${RESET}"
    echo "     Why mismatches are learning opportunities"
    echo ""
    echo -e "  ${BLUE}4${RESET}) 📋 Smart Approval Boundaries ${YELLOW}(3 min)${RESET}"
    echo "     Maximum speed with maximum safety"
    echo ""
    echo -e "  ${BLUE}5${RESET}) 📝 Naming That Works ${YELLOW}(2 min)${RESET}"
    echo "     How clear names prevent bugs"
    echo ""
    echo -e "  ${BLUE}6${RESET}) 🔄 Close-the-Loop ${YELLOW}(3 min)${RESET}"
    echo "     Impact analysis for major system changes"
    echo ""
    echo -e "  ${BLUE}7${RESET}) 🎯 Full Philosophy Tour ${YELLOW}(12 min)${RESET}"
    echo "     Deep dive into all principles"
    echo ""
    echo -e "  ${BLUE}8${RESET}) 🚀 Quick Start Guide ${YELLOW}(1 min)${RESET}"
    echo "     Essential commands and workflow"
    echo ""
    echo -e "  ${BLUE}0${RESET}) Exit"
    echo ""
    echo "──────────────────────────────────────────────────────────"
    echo ""
    echo -n "Enter your choice [0-8]: "
}

show_think_first() {
    clear
    echo ""
    echo -e "${BOLD}🧠 Think Before You Build${RESET}"
    echo ""
    echo "──────────────────────────────────────────────────────────"
    echo ""
    echo -e "${YELLOW}The Problem:${RESET}"
    echo "• Jump into code → 4-6 hours debugging"
    echo "• Friday 'quick fix' → Monday still broken"
    echo "• Assumptions wrong → Complete rewrite"
    echo ""
    echo -e "${GREEN}The Solution:${RESET}"
    echo "• 10 minutes thinking → 45 minutes total"
    echo "• Understand WHAT before HOW"
    echo "• Test assumptions with minimal code first"
    echo ""
    echo -e "${CYAN}How Cohesion Enforces This:${RESET}"
    echo "• DISCOVER mode = Can't write code"
    echo "• Forces analysis and planning"
    echo "• Your AI won't let you skip thinking"
    echo ""
    echo -e "${BOLD}Try This Now:${RESET}"
    echo "Next task: Set a 5-minute timer"
    echo "DON'T CODE - just think:"
    echo "  • What could go wrong?"
    echo "  • What am I assuming?"
    echo "  • What's the simplest approach?"
    echo ""
    echo -e "${MAGENTA}Remember: Thinking IS building!${RESET}"
    echo ""
    echo -e "${GREEN}Press ENTER to continue...${RESET}"
    read -r
}

show_always_works() {
    clear
    echo ""
    echo -e "${BOLD}✅ The 'Works Everywhere' Test${RESET}"
    echo ""
    echo "──────────────────────────────────────────────────────────"
    echo ""
    echo -e "${YELLOW}The Embarrassment Test:${RESET}"
    echo "Before claiming 'it works', ask:"
    echo "\"Would I be embarrassed if someone ran this right now?\""
    echo ""
    echo -e "${GREEN}Three Pillars of 'Works':${RESET}"
    echo "1. Works Locally - No errors on your machine"
    echo "2. Works Fresh - From clean state/install"
    echo "3. Works for Others - No special knowledge needed"
    echo ""
    echo -e "${CYAN}How Cohesion Enforces This:${RESET}"
    echo "• AI tests before claiming success"
    echo "• Forces edge case verification"
    echo "• Requires fresh state testing"
    echo ""
    echo -e "${BOLD}Quick Verification:${RESET}"
    echo "Before saying 'it works':"
    echo "  git stash && git clean -fd"
    echo "  npm install && npm test"
    echo "  # If it STILL works, now you can claim success"
    echo ""
    echo -e "${MAGENTA}Remember: Untested code is broken code!${RESET}"
    echo ""
    echo -e "${GREEN}Press ENTER to continue...${RESET}"
    read -r
}

show_reality_check() {
    clear
    echo ""
    echo -e "${BOLD}🕵️ Reality-Check Protocol${RESET}"
    echo ""
    echo "──────────────────────────────────────────────────────────"
    echo ""
    echo -e "${YELLOW}The Midnight Debugging Session:${RESET}"
    echo "11pm: \"Why is this undefined?\""
    echo "2am: Finally check what's actually returned"
    echo "2:01am: \"Oh, it's a string not a number\""
    echo "2:02am: Fixed."
    echo ""
    echo -e "${GREEN}The Protocol:${RESET}"
    echo "When expected ≠ actual:"
    echo "1. STOP - Don't add workarounds"
    echo "2. LOG - Expected vs actual"
    echo "3. INVESTIGATE - Why different?"
    echo "4. LEARN - Update mental model"
    echo "5. FIX - Address root cause"
    echo ""
    echo -e "${CYAN}Common Mismatches:${RESET}"
    echo "• Expected array → Got string"
    echo "• Expected instant → Takes 2 seconds"
    echo "• Expected user object → Got null"
    echo ""
    echo -e "${MAGENTA}Remember: Every mismatch teaches you something!${RESET}"
    echo ""
    echo -e "${GREEN}Press ENTER to continue...${RESET}"
    read -r
}

show_approval_criteria() {
    clear
    echo ""
    echo -e "${BOLD}📋 Smart Approval Boundaries${RESET}"
    echo ""
    echo "──────────────────────────────────────────────────────────"
    echo ""
    echo -e "${GREEN}✅ Always Autonomous:${RESET}"
    echo "• Bug fixes"
    echo "• Testing"
    echo "• Documentation"
    echo "• Refactoring"
    echo "• Approved tasks"
    echo ""
    echo -e "${YELLOW}⚠️ Needs Approval:${RESET}"
    echo "• New dependencies (npm packages)"
    echo "• Architecture changes"
    echo "• Scope changes (new features)"
    echo "• Breaking changes"
    echo "• External operations (publishing)"
    echo "• Anything that costs money"
    echo ""
    echo -e "${CYAN}The 5-Second Check:${RESET}"
    echo "Could this surprise or cost the user?"
    echo "  YES → Get approval"
    echo "  NO → Full speed ahead"
    echo ""
    echo -e "${MAGENTA}Remember: Clear boundaries = maximum speed!${RESET}"
    echo ""
    echo -e "${GREEN}Press ENTER to continue...${RESET}"
    read -r
}

show_naming() {
    clear
    echo ""
    echo -e "${BOLD}📝 Naming That Works${RESET}"
    echo ""
    echo "──────────────────────────────────────────────────────────"
    echo ""
    echo -e "${YELLOW}The Confusion Tax:${RESET}"
    echo "Bad: const d = new Date();"
    echo "Bad: const mgr = getUserMgr();"
    echo "Bad: function proc(data) {}"
    echo ""
    echo -e "${GREEN}Clear Names:${RESET}"
    echo "Good: const currentDate = new Date();"
    echo "Good: const userManager = getUserManager();"
    echo "Good: function processPayment(orderData) {}"
    echo ""
    echo -e "${CYAN}The 5-Second Test:${RESET}"
    echo "Can you understand what it does in 5 seconds?"
    echo "  NO → Bad name, refactor it"
    echo "  YES → Good name, keep it"
    echo ""
    echo -e "${BOLD}Naming Rules:${RESET}"
    echo "• Full words (not abbreviations)"
    echo "• Purpose-focused (what it does)"
    echo "• Consistent patterns"
    echo "• Self-documenting"
    echo ""
    echo -e "${MAGENTA}Remember: Good names eliminate confusion!${RESET}"
    echo ""
    echo -e "${GREEN}Press ENTER to continue...${RESET}"
    read -r
}

show_close_the_loop() {
    clear
    echo ""
    echo -e "${BOLD}🔄 Close-the-Loop${RESET}"
    echo ""
    echo "──────────────────────────────────────────────────────────"
    echo ""
    echo -e "${YELLOW}Core Insight:${RESET}"
    echo "\"When paradigms change, ensure all ripple effects are addressed\""
    echo ""
    echo -e "${BOLD}When This Matters:${RESET}"
    echo "• Major system refactoring"
    echo "• Architecture changes"
    echo "• New framework adoption"
    echo "• Database schema changes"
    echo "• Security model updates"
    echo ""
    echo -e "${BOLD}Impact Analysis Checklist:${RESET}"
    echo "✓ Documentation updates needed?"
    echo "✓ Tests affected by changes?"
    echo "✓ Configuration files impacted?"
    echo "✓ Dependencies need updating?"
    echo "✓ Other teams/systems affected?"
    echo ""
    echo -e "${BOLD}Cohesion Enforcement:${RESET}"
    echo "• OPTIMIZE: 90% enforcement - blocks until analysis done"
    echo "• DISCOVER: 30% enforcement - suggests impact review"
    echo "• UNLEASH: Internalized - trusted to handle systematically"
    echo ""
    echo -e "${YELLOW}Real Example:${RESET}"
    echo "Changing authentication from sessions to JWT tokens affects:"
    echo "- Frontend login components"
    echo "- API middleware"
    echo "- Database user tables"
    echo "- Testing strategies"
    echo "- Documentation"
    echo "- Deployment configs"
    echo ""
    echo -e "${MAGENTA}Remember: Major changes create ripple effects!${RESET}"
    echo ""
    echo -e "${GREEN}Press ENTER to continue...${RESET}"
    read -r
}

show_quick_start() {
    clear
    echo ""
    echo -e "${BOLD}🚀 Cohesion Quick Start${RESET}"
    echo ""
    echo "──────────────────────────────────────────────────────────"
    echo ""
    echo -e "${CYAN}Essential Commands:${RESET}"
    echo ""
    echo -e "${BOLD}State Control:${RESET}"
    echo "  'reset'     → DISCOVER mode (read-only)"
    echo "  'optimize'  → OPTIMIZE mode (collaborative)"
    echo "  'approved'  → UNLEASH mode (full autonomy)"
    echo ""
    echo -e "${BOLD}The Workflow:${RESET}"
    echo "1. Start in DISCOVER → Analyze and plan"
    echo "2. Get approval → Switch to UNLEASH"
    echo "3. Run /config reload → Apply permissions"
    echo "4. Execute efficiently"
    echo ""
    echo -e "${BOLD}When Blocked:${RESET}"
    echo "• It's protecting you from waste"
    echo "• Read the message - it explains why"
    echo "• Follow the suggestion to proceed"
    echo ""
    echo -e "${BOLD}Learn More:${RESET}"
    echo "  cohesion learn    - This menu"
    echo "  cohesion status   - Current state"
    echo "  cohesion help     - All commands"
    echo ""
    echo -e "${MAGENTA}The Bottom Line:${RESET}"
    echo "Think first, build once, ship confidently!"
    echo ""
    echo -e "${GREEN}Press ENTER to continue...${RESET}"
    read -r
}

show_full_tour() {
    show_think_first
    show_always_works
    show_reality_check
    show_approval_criteria
    show_naming
    show_close_the_loop
    clear
    echo ""
    echo -e "${BOLD}🎉 Full Tour Complete!${RESET}"
    echo ""
    echo "You now understand all 6 Core Principles."
    echo ""
    echo "Documentation available in:"
    echo "  • /docs/cohesion-methodologies/ (user guides)"
    echo "  • .claude/cohesion-canon/ (AI training)"
    echo ""
    echo -e "${GREEN}Press ENTER to return to menu...${RESET}"
    read -r
}

# Main loop
while true; do
    show_menu
    read -r choice
    
    case $choice in
        1) show_think_first ;;
        2) show_always_works ;;
        3) show_reality_check ;;
        4) show_approval_criteria ;;
        5) show_naming ;;
        6) show_close_the_loop ;;
        7) show_full_tour ;;
        8) show_quick_start ;;
        0) 
            echo ""
            echo "Thanks for learning with Cohesion! 🚀"
            echo ""
            exit 0 
            ;;
        *)
            echo ""
            echo -e "${RED}Invalid choice. Please try again.${RESET}"
            sleep 2
            ;;
    esac
done
