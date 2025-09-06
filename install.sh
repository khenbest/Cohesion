#!/bin/bash
# Cohesion - Dual-Mode Installation Script
# Supports both project-local and global installation

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# CRITICAL: Protected directories and files - NEVER modify these
COHESION_PROTECTED_DIRS=(".claude" ".git" "node_modules" ".next" "build" "dist")
COHESION_PROTECTED_FILES=(".env" ".env.local" ".env.production")

# Installation paths
GLOBAL_COHESION_DIR="$HOME/.cohesion"
GLOBAL_CLAUDE_DIR="$HOME/.claude"
LOCAL_CLAUDE_DIR="./.claude"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detection functions
has_local_install() {
    [ -d "$LOCAL_CLAUDE_DIR" ] && [ -f "$LOCAL_CLAUDE_DIR/settings.json" ]
}

has_global_install() {
    [ -d "$GLOBAL_COHESION_DIR" ] && [ -f "$GLOBAL_CLAUDE_DIR/settings.json" ]
}

is_claude_code_installed() {
    [ -d "$GLOBAL_CLAUDE_DIR" ] || [ -d "$LOCAL_CLAUDE_DIR" ]
}

# Safe path protection system
is_protected_path() {
    local path="$1"

    # Check against protected directories
    for protected in "${COHESION_PROTECTED_DIRS[@]}"; do
        if [[ "$path" == *"$protected"* ]]; then
            return 0  # Protected
        fi
    done

    # Check against protected files
    for protected in "${COHESION_PROTECTED_FILES[@]}"; do
        if [[ "$path" == *"$protected"* ]]; then
            return 0  # Protected
        fi
    done

    return 1  # Safe
}

# Safe file creation with protection checks
create_file_safely() {
    local file_path="$1"
    local content="$2"

    # Double-check this isn't a protected path
    if is_protected_path "$file_path"; then
        echo -e "${RED}❌ ERROR: Attempted to write to protected path: $file_path${NC}"
        echo -e "${YELLOW}   Cohesion internal protection prevented this operation${NC}"
        return 1
    fi

    # Check if file already exists
    if [ -f "$file_path" ]; then
        echo -e "${YELLOW}⚠️  File exists: $file_path${NC}"
        echo -e "${YELLOW}   Cohesion will not overwrite existing files${NC}"
        return 1
    fi

    # Create directory if needed
    local dir_path="$(dirname "$file_path")"
    if ! is_protected_path "$dir_path"; then
        mkdir -p "$dir_path"

        # Write file safely
        echo "$content" > "$file_path"
        echo -e "${GREEN}✓${NC} Created: $file_path"
        return 0
    else
        echo -e "${RED}❌ ERROR: Attempted to create directory in protected path: $dir_path${NC}"
        return 1
    fi
}

# Display functions
show_banner() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════╗"
    echo "║       Cohesion + DUO Protocol         ║"
    echo "║  Intelligent Process Augmentation     ║"
    echo "╚═══════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${BLUE}🛡️  Internal Protection: .claude directory secured${NC}"
}

show_mode_selection() {
    echo -e "${BLUE}How would you like to install Cohesion?${NC}\n"
    echo "1) Just this project ${YELLOW}(recommended for first-time users)${NC}"
    echo "   • Try it out safely in one project"
    echo "   • Easy to upgrade later"
    echo ""
    echo "2) Globally for all projects"
    echo "   • Works automatically everywhere"
    echo "   • No per-project setup needed"
    echo ""
    echo "3) Learn more about the differences"
    echo ""
}

show_differences() {
    echo -e "\n${BLUE}Installation Mode Comparison:${NC}\n"
    echo "┌─────────────────┬────────────────────┬────────────────────┐"
    echo "│                 │ Project-Local      │ Global             │"
    echo "├─────────────────┼────────────────────┼────────────────────┤"
    echo "│ Scope           │ This project only  │ All projects       │"
    echo "│ Installation    │ ./.claude/         │ ~/.cohesion/       │"
    echo "│ Setup needed    │ Per project        │ Once               │"
    echo "│ State storage   │ Local              │ Per-project global │"
    echo "│ Easy to try     │ ✓✓✓               │ ✓✓                │"
    echo "│ Easy to remove  │ ✓✓✓               │ ✓✓                │"
    echo "│ Upgrade path    │ To global anytime  │ -                  │"
    echo "└─────────────────┴────────────────────┴────────────────────┘"
}

# Installation functions
install_local() {
    echo -e "\n${GREEN}Installing Cohesion locally for this project...${NC}\n"
    
    # Create local directory structure
    mkdir -p "$LOCAL_CLAUDE_DIR"/{hooks,state,utils}
    
    # Copy files
    cp -r "$SCRIPT_DIR/.claude/hooks/"* "$LOCAL_CLAUDE_DIR/hooks/" 2>/dev/null || true
    cp "$SCRIPT_DIR/.claude/utils/state.sh" "$LOCAL_CLAUDE_DIR/utils/" 2>/dev/null || true
    cp "$SCRIPT_DIR/.claude/install.sh" "$LOCAL_CLAUDE_DIR/" 2>/dev/null || true
    
    # Copy documentation if available
    if [ -d "$SCRIPT_DIR/docs" ]; then
        mkdir -p "$LOCAL_CLAUDE_DIR/docs"
        cp -r "$SCRIPT_DIR/docs/"* "$LOCAL_CLAUDE_DIR/docs/" 2>/dev/null || true
        echo -e "${GREEN}✓${NC} Documentation installed"
    fi
    
    # Make hooks executable
    chmod +x "$LOCAL_CLAUDE_DIR/hooks/"*.sh 2>/dev/null || true
    chmod +x "$LOCAL_CLAUDE_DIR/utils/state.sh" 2>/dev/null || true
    
    # Create or update settings.json
    create_settings_json "$LOCAL_CLAUDE_DIR"
    
    # Initialize state
    echo '{"state": "DISCOVER", "timestamp": '$(date +%s)', "mode": "local"}' > "$LOCAL_CLAUDE_DIR/state/session.json"
    
    # Make cohesion script executable in project
    if [ ! -f "./cohesion" ]; then
        cp "$SCRIPT_DIR/cohesion" "./cohesion"
        chmod +x "./cohesion"
    fi
    
    echo -e "${GREEN}✓${NC} Local installation complete!"
    echo -e "${YELLOW}→${NC} Use ${CYAN}./cohesion status${NC} to check your state"
    echo -e "${YELLOW}→${NC} Use ${CYAN}./cohesion help${NC} to see all commands"
    echo ""
    echo -e "${BLUE}💡 Tip:${NC} If you like Cohesion, upgrade to global with:"
    echo -e "   ${CYAN}./cohesion upgrade --to-global${NC}"
}

install_global() {
    echo -e "\n${GREEN}Installing Cohesion globally for all projects...${NC}\n"
    
    # Create global directory structure
    mkdir -p "$GLOBAL_COHESION_DIR"/{bin,hooks,states,utils}
    mkdir -p "$GLOBAL_CLAUDE_DIR"
    
    # Copy cohesion executable to global bin
    cp "$SCRIPT_DIR/cohesion" "$GLOBAL_COHESION_DIR/bin/cohesion"
    chmod +x "$GLOBAL_COHESION_DIR/bin/cohesion"
    
    # Copy hooks and utilities
    cp -r "$SCRIPT_DIR/.claude/hooks/"* "$GLOBAL_COHESION_DIR/hooks/" 2>/dev/null || true
    cp "$SCRIPT_DIR/.claude/utils/state.sh" "$GLOBAL_COHESION_DIR/utils/" 2>/dev/null || true
    
    # Copy documentation if available
    if [ -d "$SCRIPT_DIR/docs" ]; then
        mkdir -p "$GLOBAL_COHESION_DIR/docs"
        cp -r "$SCRIPT_DIR/docs/"* "$GLOBAL_COHESION_DIR/docs/" 2>/dev/null || true
        echo -e "${GREEN}✓${NC} Documentation installed globally"
    fi
    
    # Make hooks executable
    chmod +x "$GLOBAL_COHESION_DIR/hooks/"*.sh 2>/dev/null || true
    chmod +x "$GLOBAL_COHESION_DIR/utils/state.sh" 2>/dev/null || true
    
    # Create or update Claude settings
    create_settings_json "$GLOBAL_CLAUDE_DIR"
    
    # Create project registry
    echo '{"projects": {}, "version": "2.0"}' > "$GLOBAL_COHESION_DIR/states/projects.json"
    
    # Add to PATH if not already there
    add_to_path
    
    echo -e "${GREEN}✓${NC} Global installation complete!"
    echo -e "${YELLOW}→${NC} Use ${CYAN}cohesion status${NC} from any project"
    echo -e "${YELLOW}→${NC} Use ${CYAN}cohesion help${NC} to see all commands"
}

create_settings_json() {
    local DIR="$1"
    local SETTINGS_FILE="$DIR/settings.json"
    
    if [ -f "$SETTINGS_FILE" ]; then
        # Backup existing settings
        cp "$SETTINGS_FILE" "$SETTINGS_FILE.backup.$(date +%s)"
    fi
    
    # Determine hook path - use variable that Claude Code can resolve
    local HOOK_PATH_VAR
    if [ "$DIR" = "$GLOBAL_CLAUDE_DIR" ]; then
        HOOK_PATH_VAR='$HOME/.cohesion/hooks'
    else
        HOOK_PATH_VAR='$CLAUDE_PROJECT_DIR/.claude/hooks'
    fi
    
    cat > "$SETTINGS_FILE" << EOF
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$HOOK_PATH_VAR/session-start.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$HOOK_PATH_VAR/pre-tool-use.sh",
            "timeout": 2
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "$HOOK_PATH_VAR/bash-validator.sh",
            "timeout": 2
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$HOOK_PATH_VAR/post-tool-use.sh",
            "timeout": 2
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$HOOK_PATH_VAR/detect-intent.sh",
            "timeout": 3
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$HOOK_PATH_VAR/save-progress.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$HOOK_PATH_VAR/pre-compact.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "SessionEnd": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$HOOK_PATH_VAR/session-end.sh",
            "timeout": 5
          }
        ]
      }
    ]
  },
  "cohesion": {
    "version": "2.0",
    "mode": "$([ "$DIR" = "$GLOBAL_CLAUDE_DIR" ] && echo "global" || echo "local")",
    "installed": "$(date -Iseconds)"
  }
}
EOF
}

add_to_path() {
    local ADDED_TO=""
    
    # Check if already in PATH
    if echo "$PATH" | grep -q "$GLOBAL_COHESION_DIR/bin"; then
        echo -e "${YELLOW}→${NC} Cohesion already in PATH"
        return 0
    fi
    
    # Detect current shell from $SHELL variable
    local CURRENT_SHELL=$(basename "$SHELL" 2>/dev/null || echo "unknown")
    
    case "$CURRENT_SHELL" in
        "zsh")
            if [ -f "$HOME/.zshrc" ]; then
                add_path_to_file "$HOME/.zshrc"
                ADDED_TO="$HOME/.zshrc"
            else
                add_path_to_file "$HOME/.profile"
                ADDED_TO="$HOME/.profile"
            fi
            ;;
        "bash")
            if [ -f "$HOME/.bashrc" ]; then
                add_path_to_file "$HOME/.bashrc"
                ADDED_TO="$HOME/.bashrc"
            elif [ -f "$HOME/.bash_profile" ]; then
                add_path_to_file "$HOME/.bash_profile"
                ADDED_TO="$HOME/.bash_profile"
            else
                add_path_to_file "$HOME/.profile"
                ADDED_TO="$HOME/.profile"
            fi
            ;;
        *)
            # Fallback: try common files in order
            if [ -f "$HOME/.zshrc" ] && command -v zsh >/dev/null; then
                add_path_to_file "$HOME/.zshrc"
                ADDED_TO="$HOME/.zshrc"
            elif [ -f "$HOME/.bashrc" ] && command -v bash >/dev/null; then
                add_path_to_file "$HOME/.bashrc"  
                ADDED_TO="$HOME/.bashrc"
            else
                add_path_to_file "$HOME/.profile"
                ADDED_TO="$HOME/.profile"
            fi
            ;;
    esac
    
    echo -e "${YELLOW}→${NC} Added Cohesion to PATH in $ADDED_TO"
    echo -e "${BLUE}💡 Tip:${NC} Run ${CYAN}source $ADDED_TO${NC} or restart your terminal"
}

add_path_to_file() {
    local FILE="$1"
    
    # Create file if it doesn't exist
    touch "$FILE"
    
    # Check if Cohesion is already in this file
    if ! grep -q "cohesion" "$FILE"; then
        echo "" >> "$FILE"
        echo "# Cohesion" >> "$FILE"  
        echo "export PATH=\"\$PATH:$GLOBAL_COHESION_DIR/bin\"" >> "$FILE"
    fi
}

upgrade_to_global() {
    echo -e "${CYAN}Upgrading from local to global installation...${NC}\n"
    
    if ! has_local_install; then
        echo -e "${RED}No local installation found!${NC}"
        exit 1
    fi
    
    # Install globally
    install_global
    
    # Offer to migrate state
    echo -e "\n${BLUE}Would you like to:${NC}"
    echo "1) Migrate this project's state to global storage"
    echo "2) Keep using local state for this project"
    echo "3) Remove local installation completely"
    echo ""
    read -p "Choice [1]: " migrate_choice
    migrate_choice=${migrate_choice:-1}
    
    case $migrate_choice in
        1)
            migrate_project_state
            ;;
        2)
            echo -e "${YELLOW}→${NC} Keeping local state. Project will use local installation."
            ;;
        3)
            rm -rf "$LOCAL_CLAUDE_DIR"
            rm -f "./cohesion"
            echo -e "${GREEN}✓${NC} Local installation removed"
            ;;
    esac
}

migrate_project_state() {
    local PROJECT_PATH=$(pwd)
    local PROJECT_HASH=$(echo "$PROJECT_PATH" | shasum -a 256 | cut -c1-16)
    local GLOBAL_STATE_DIR="$GLOBAL_COHESION_DIR/states/$PROJECT_HASH"
    
    echo -e "${CYAN}Migrating project state...${NC}"
    
    # Create global state directory for this project
    mkdir -p "$GLOBAL_STATE_DIR"
    
    # Copy state files
    if [ -f "$LOCAL_CLAUDE_DIR/state/session.json" ]; then
        cp "$LOCAL_CLAUDE_DIR/state/session.json" "$GLOBAL_STATE_DIR/"
    fi
    
    # Update project registry
    local PROJECTS_FILE="$GLOBAL_COHESION_DIR/states/projects.json"
    if [ -f "$PROJECTS_FILE" ]; then
        jq --arg path "$PROJECT_PATH" \
           --arg hash "$PROJECT_HASH" \
           --arg time "$(date -Iseconds)" \
           '.projects[$hash] = {"path": $path, "migrated": $time}' \
           "$PROJECTS_FILE" > "$PROJECTS_FILE.tmp" && \
        mv "$PROJECTS_FILE.tmp" "$PROJECTS_FILE"
    fi
    
    echo -e "${GREEN}✓${NC} State migrated successfully"
}

handle_existing_installations() {
    local has_local=$(has_local_install && echo "yes" || echo "no")
    local has_global=$(has_global_install && echo "yes" || echo "no")
    
    if [ "$has_global" = "yes" ] && [ "$has_local" = "no" ]; then
        echo -e "${GREEN}✓${NC} Global Cohesion detected!"
        echo "This project will automatically use your global installation."
        echo ""
        echo -e "Run ${CYAN}cohesion status${NC} to check the current state"
        exit 0
    fi
    
    if [ "$has_local" = "yes" ]; then
        echo -e "${YELLOW}⚠${NC}  Local Cohesion installation found in this project\n"
        echo "Options:"
        echo "1) Keep using local installation"
        echo "2) Upgrade to global ${GREEN}(recommended)${NC}"
        echo "3) Reinstall local (refresh)"
        echo ""
        read -p "Choice [1]: " existing_choice
        existing_choice=${existing_choice:-1}
        
        case $existing_choice in
            2)
                upgrade_to_global
                ;;
            3)
                rm -rf "$LOCAL_CLAUDE_DIR"
                install_local
                ;;
            *)
                echo -e "${GREEN}✓${NC} Keeping existing local installation"
                ;;
        esac
        exit 0
    fi
    
    if [ "$has_global" = "yes" ] && [ "$has_local" = "yes" ]; then
        echo -e "${YELLOW}⚠${NC}  Both local and global installations detected\n"
        echo "Currently using: local installation"
        echo ""
        echo "Options:"
        echo "1) Continue with local"
        echo "2) Switch to global"
        echo "3) Migrate local state to global"
        echo ""
        read -p "Choice [1]: " both_choice
        both_choice=${both_choice:-1}
        
        case $both_choice in
            2)
                rm -rf "$LOCAL_CLAUDE_DIR"
                rm -f "./cohesion"
                echo -e "${GREEN}✓${NC} Switched to global installation"
                ;;
            3)
                migrate_project_state
                rm -rf "$LOCAL_CLAUDE_DIR"
                rm -f "./cohesion"
                echo -e "${GREEN}✓${NC} Migrated to global installation"
                ;;
            *)
                echo -e "${GREEN}✓${NC} Keeping local installation"
                ;;
        esac
        exit 0
    fi
}

# Main installation flow
main() {
    show_banner
    
    # Check for existing installations
    handle_existing_installations
    
    # Fresh installation
    show_mode_selection
    
    read -p "Select installation mode [1]: " choice
    choice=${choice:-1}
    
    case $choice in
        2)
            install_global
            ;;
        3)
            show_differences
            echo ""
            main  # Restart selection
            ;;
        *)
            install_local
            ;;
    esac
    
    echo -e "\n${GREEN}🎉 Installation complete!${NC}"
    
    # Offer to initialize existing projects if global install
    if [ "$has_global" = "yes" ] || [ "${1:-}" = "--global" ]; then
        echo ""
        echo -e "${CYAN}Initialize Cohesion in existing projects?${NC}"
        echo "This creates a .claude folder so projects can use Cohesion."
        echo ""
        read -p "Search for projects to initialize? [y/N]: " init_projects
        if [[ "$init_projects" =~ ^[Yy]$ ]]; then
            echo ""
            echo "Searching for Git repositories..."
            
            # Find git repos without .claude folders
            REPOS_FOUND=0
            for search_dir in "$HOME/repos" "$HOME/projects" "$HOME/code" "$HOME/dev"; do
                if [ -d "$search_dir" ]; then
                    while IFS= read -r -d '' repo; do
                        repo_dir=$(dirname "$repo")
                        if [ ! -d "$repo_dir/.claude" ]; then
                            ((REPOS_FOUND++))
                            echo "  Found: $repo_dir"
                            read -p "    Initialize here? [y/N]: " init_this
                            if [[ "$init_this" =~ ^[Yy]$ ]]; then
                                (cd "$repo_dir" && "$GLOBAL_COHESION_DIR/bin/cohesion" init)
                            fi
                        fi
                    done < <(find "$search_dir" -maxdepth 3 -name ".git" -type d -print0 2>/dev/null)
                fi
            done
            
            if [ $REPOS_FOUND -eq 0 ]; then
                echo "  No projects found that need initialization."
            fi
        fi
    fi
    
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo "• Use 'cohesion init' in any project to enable Cohesion"
    echo "• Start Claude Code to activate Cohesion"  
    echo "• Use 'cohesion help' for all commands"
    echo ""
    echo -e "Start using Cohesion to manage your Claude Code workflow.\n"
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Cohesion Installation Script"
        echo ""
        echo "Usage: ./install.sh [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --local     Install Cohesion locally in current project"
        echo "  --global    Install Cohesion globally for all projects"
        echo "  --upgrade   Upgrade from local to global installation"
        echo "  --help, -h  Show this help message"
        echo ""
        echo "Without options, runs interactive installation."
        exit 0
        ;;
    --local)
        show_banner
        install_local
        ;;
    --global)
        show_banner
        install_global
        ;;
    --upgrade)
        show_banner
        upgrade_to_global
        ;;
    *)
        main
        ;;
esac