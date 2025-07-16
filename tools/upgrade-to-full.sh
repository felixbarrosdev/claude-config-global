#!/bin/bash

# Upgrade to Full Script
# Script para actualizar una instalación Lite de Claude Config Global a Full

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CLAUDE_DIR=".claude"
CONFIG_FILE="$CLAUDE_DIR/config.yaml"
VERSION_FILE="$CLAUDE_DIR/VERSION"
TEMPLATES_DIR="$CLAUDE_DIR/templates"

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                     Claude Config Global - Upgrade to Full                   ║"
    echo "║                  Converting Lite Installation to Full                        ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "This script must be run in a git repository"
        exit 1
    fi
    
    # Check if .claude directory exists
    if [ ! -d "$CLAUDE_DIR" ]; then
        log_error ".claude directory not found. Please run setup-project.sh first"
        exit 1
    fi
    
    # Check if config.yaml exists
    if [ ! -f "$CONFIG_FILE" ]; then
        log_error "config.yaml not found in .claude directory"
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

detect_current_installation() {
    log_info "Detecting current installation type..."
    
    # Check if this looks like a Full installation already
    if [ -f "$CLAUDE_DIR/project-context.md" ] && [ -f "$CLAUDE_DIR/team-standards.md" ] && [ -f "$CLAUDE_DIR/custom-config.yaml" ]; then
        log_warning "This appears to be a Full installation already"
        echo ""
        echo -e "${YELLOW}The following Full installation files were found:${NC}"
        echo "- project-context.md"
        echo "- team-standards.md" 
        echo "- custom-config.yaml"
        echo ""
        read -p "Do you want to continue and potentially overwrite these files? [y/N]: " confirm
        case $confirm in
            [Yy]*)
                log_info "Continuing with upgrade..."
                ;;
            *)
                log_info "Upgrade cancelled by user"
                exit 0
                ;;
        esac
    else
        log_success "Detected Lite installation - ready to upgrade"
    fi
}

get_project_info() {
    log_info "Gathering project information..."
    
    # Get project name from directory or package.json
    if [ -f "package.json" ] && command -v jq > /dev/null 2>&1; then
        PROJECT_NAME=$(jq -r '.name' package.json 2>/dev/null || basename "$(pwd)")
    elif [ -f "Cargo.toml" ]; then
        PROJECT_NAME=$(grep "^name" Cargo.toml | head -1 | sed 's/name = "\(.*\)"/\1/' || basename "$(pwd)")
    elif [ -f "go.mod" ]; then
        PROJECT_NAME=$(grep "^module" go.mod | head -1 | awk '{print $2}' | sed 's/.*\///' || basename "$(pwd)")
    else
        PROJECT_NAME=$(basename "$(pwd)")
    fi
    
    # Detect project type
    if [ -f "package.json" ]; then
        PROJECT_TYPE="nodejs"
    elif [ -f "Cargo.toml" ]; then
        PROJECT_TYPE="rust"
    elif [ -f "go.mod" ]; then
        PROJECT_TYPE="go"
    elif [ -f "requirements.txt" ] || [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
        PROJECT_TYPE="python"
    elif [ -f "pom.xml" ]; then
        PROJECT_TYPE="java"
    elif [ -f "composer.json" ]; then
        PROJECT_TYPE="php"
    elif [ -f "Gemfile" ]; then
        PROJECT_TYPE="ruby"
    elif [ -f "pubspec.yaml" ]; then
        PROJECT_TYPE="dart"
    else
        PROJECT_TYPE="generic"
    fi
    
    # Get git information
    GIT_REMOTE=$(git remote get-url origin 2>/dev/null || echo "unknown")
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
    AUTHOR_NAME=$(git config user.name 2>/dev/null || echo "Unknown")
    AUTHOR_EMAIL=$(git config user.email 2>/dev/null || echo "unknown@example.com")
    
    export PROJECT_NAME PROJECT_TYPE GIT_REMOTE CURRENT_BRANCH AUTHOR_NAME AUTHOR_EMAIL
    
    log_success "Project info gathered: $PROJECT_NAME ($PROJECT_TYPE)"
}

backup_existing_files() {
    log_info "Backing up existing files..."
    
    # Create backup directory
    BACKUP_DIR=".claude-upgrade-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # Backup any existing files that will be overwritten
    for file in "project-context.md" "team-standards.md" "custom-config.yaml"; do
        if [ -f "$CLAUDE_DIR/$file" ]; then
            cp "$CLAUDE_DIR/$file" "$BACKUP_DIR/"
            log_success "Backed up existing $file"
        fi
    done
    
    # Also backup .claude.md if it exists
    if [ -f ".claude.md" ]; then
        cp ".claude.md" "$BACKUP_DIR/"
        log_success "Backed up existing .claude.md"
    fi
    
    log_success "Backup completed in $BACKUP_DIR"
}

setup_project_context() {
    log_info "Setting up project-specific context..."
    
    # Create project context from template
    if [ -f "$TEMPLATES_DIR/project-context.md" ]; then
        cp "$TEMPLATES_DIR/project-context.md" "$CLAUDE_DIR/project-context.md"
        
        # Replace placeholders
        sed -i.bak "s#\[\[PROJECT_NAME\]\]#$PROJECT_NAME#g" "$CLAUDE_DIR/project-context.md"
        sed -i.bak "s#\[\[PROJECT_TYPE\]\]#$PROJECT_TYPE#g" "$CLAUDE_DIR/project-context.md"
        sed -i.bak "s#\[\[AUTHOR_NAME\]\]#$AUTHOR_NAME#g" "$CLAUDE_DIR/project-context.md"
        sed -i.bak "s#\[\[AUTHOR_EMAIL\]\]#$AUTHOR_EMAIL#g" "$CLAUDE_DIR/project-context.md"
        sed -i.bak "s#\[\[GIT_REMOTE\]\]#$GIT_REMOTE#g" "$CLAUDE_DIR/project-context.md"
        sed -i.bak "s#\[\[CURRENT_BRANCH\]\]#$CURRENT_BRANCH#g" "$CLAUDE_DIR/project-context.md"
        
        # Clean up backup files
        rm -f "$CLAUDE_DIR/project-context.md.bak"
        
        log_success "Project context file created"
    else
        log_warning "Project context template not found"
    fi
}

setup_team_standards() {
    log_info "Setting up team standards..."
    
    # Create team standards from template
    if [ -f "$TEMPLATES_DIR/team-standards.md" ]; then
        cp "$TEMPLATES_DIR/team-standards.md" "$CLAUDE_DIR/team-standards.md"
        
        # Replace placeholders
        sed -i.bak "s#\[\[PROJECT_NAME\]\]#$PROJECT_NAME#g" "$CLAUDE_DIR/team-standards.md"
        sed -i.bak "s#\[\[PROJECT_TYPE\]\]#$PROJECT_TYPE#g" "$CLAUDE_DIR/team-standards.md"
        
        # Clean up backup files
        rm -f "$CLAUDE_DIR/team-standards.md.bak"
        
        log_success "Team standards file created"
    else
        log_warning "Team standards template not found"
    fi
}

setup_custom_config() {
    log_info "Setting up custom configuration..."
    
    # Create custom config from template
    if [ -f "$TEMPLATES_DIR/custom-config.yaml" ]; then
        cp "$TEMPLATES_DIR/custom-config.yaml" "$CLAUDE_DIR/custom-config.yaml"
        
        # Update custom config with project-specific values
        sed -i.bak "s#\[\[PROJECT_NAME\]\]#$PROJECT_NAME#g" "$CLAUDE_DIR/custom-config.yaml"
        sed -i.bak "s#\[\[PROJECT_TYPE\]\]#$PROJECT_TYPE#g" "$CLAUDE_DIR/custom-config.yaml"
        sed -i.bak "s#\[\[AUTHOR_NAME\]\]#$AUTHOR_NAME#g" "$CLAUDE_DIR/custom-config.yaml"
        
        # Clean up backup files
        rm -f "$CLAUDE_DIR/custom-config.yaml.bak"
        
        log_success "Custom configuration file created"
    else
        log_warning "Custom config template not found"
    fi
}

update_claude_md() {
    log_info "Updating .claude.md file..."
    
    cat > ".claude.md" << EOF
# Claude Configuration for $PROJECT_NAME

This project uses Claude Config Global for standardized development practices.

## Project Information
- **Name**: $PROJECT_NAME
- **Type**: $PROJECT_TYPE
- **Author**: $AUTHOR_NAME
- **Repository**: $GIT_REMOTE
- **Installation Mode**: full

## Configuration
- **Main Config**: .claude/config.yaml
- **Project Context**: .claude/project-context.md
- **Team Standards**: .claude/team-standards.md
- **Custom Config**: .claude/custom-config.yaml

## Available Commands
- **Setup**: \`./claude/tools/setup-project.sh\`
- **Update**: \`./claude/tools/update-config.sh\`
- **Detect**: \`./claude/tools/detect-project.sh\`
- **Upgrade to Full**: \`./claude/tools/upgrade-to-full.sh\`

## Usage
Claude Code will automatically load configurations from the .claude directory.
For project-specific customizations, edit the files in .claude/templates/.

## Version
Claude Config Global version: $(cat "$VERSION_FILE" 2>/dev/null || echo "Unknown")

Generated on: $(date)
EOF
    
    log_success ".claude.md file updated to Full installation"
}

verify_upgrade() {
    log_info "Verifying upgrade..."
    
    # Check that all required Full installation files exist
    local errors=0
    
    if [ ! -f "$CONFIG_FILE" ]; then
        log_error "config.yaml not found"
        errors=$((errors + 1))
    fi
    
    if [ ! -f "$CLAUDE_DIR/project-context.md" ]; then
        log_error "project-context.md not found"
        errors=$((errors + 1))
    fi
    
    if [ ! -f "$CLAUDE_DIR/team-standards.md" ]; then
        log_error "team-standards.md not found"
        errors=$((errors + 1))
    fi
    
    if [ ! -f "$CLAUDE_DIR/custom-config.yaml" ]; then
        log_error "custom-config.yaml not found"
        errors=$((errors + 1))
    fi
    
    if [ ! -f ".claude.md" ]; then
        log_error ".claude.md not found"
        errors=$((errors + 1))
    fi
    
    if [ $errors -eq 0 ]; then
        log_success "Upgrade verification passed"
        return 0
    else
        log_error "Upgrade verification failed with $errors errors"
        return 1
    fi
}

show_completion_message() {
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                            Upgrade Complete!                                 ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${BLUE}Upgrade Summary:${NC}"
    echo "✅ Project context configuration created"
    echo "✅ Team standards file created" 
    echo "✅ Custom configuration file created"
    echo "✅ .claude.md updated to Full installation"
    echo ""
    echo -e "${BLUE}Next Steps:${NC}"
    echo "1. Review and customize .claude/project-context.md"
    echo "2. Update .claude/team-standards.md with your team's standards"
    echo "3. Modify .claude/custom-config.yaml for project-specific settings"
    echo "4. Commit the updated Claude configuration to your repository"
    echo ""
    echo -e "${BLUE}Available Commands:${NC}"
    echo "- Update config: ${YELLOW}./.claude/tools/update-config.sh${NC}"
    echo "- Detect project: ${YELLOW}./.claude/tools/detect-project.sh${NC}"
    echo "- View help: ${YELLOW}cat .claude/README.md${NC}"
    echo ""
    echo -e "${GREEN}You now have the complete Claude Config Global experience! 🚀${NC}"
}

# Main execution
main() {
    print_header
    
    # Run upgrade steps
    check_prerequisites
    detect_current_installation
    get_project_info
    backup_existing_files
    setup_project_context
    setup_team_standards
    setup_custom_config
    update_claude_md
    
    # Verify and show results
    if verify_upgrade; then
        show_completion_message
    else
        log_error "Upgrade failed. Please check the errors above."
        exit 1
    fi
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Claude Config Global - Upgrade to Full Script"
        echo ""
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  -h, --help     Show this help message"
        echo "  --dry-run      Show what would be done without making changes"
        echo "  --force        Force upgrade even if Full installation is detected"
        echo ""
        echo "This script upgrades a Lite installation to a Full installation."
        echo "Run it from your project root where .claude directory exists."
        exit 0
        ;;
    --dry-run)
        log_info "Dry run mode - no changes will be made"
        DRY_RUN=true
        export DRY_RUN
        main
        ;;
    --force)
        log_info "Force mode - will overwrite existing Full installation files"
        FORCE=true
        export FORCE
        main
        ;;
    "")
        # No arguments, run normally
        main
        ;;
    *)
        log_error "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac