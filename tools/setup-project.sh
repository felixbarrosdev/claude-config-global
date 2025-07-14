#!/bin/bash

# Setup Project Script
# Script para configurar Claude Code en un proyecto después de clonar claude-config-global

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
TOOLS_DIR="$CLAUDE_DIR/tools"

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
    echo "║                        Claude Config Global Setup                            ║"
    echo "║                   Universal Configuration for Claude Code                    ║"
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
        log_error ".claude directory not found. Please clone claude-config-global to .claude first"
        exit 1
    fi
    
    # Check if config.yaml exists
    if [ ! -f "$CONFIG_FILE" ]; then
        log_error "config.yaml not found in .claude directory"
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

detect_project_type() {
    log_info "Detecting project type..."
    
    # Check for various project types
    if [ -f "package.json" ]; then
        PROJECT_TYPE="nodejs"
        log_success "Detected Node.js project"
    elif [ -f "Cargo.toml" ]; then
        PROJECT_TYPE="rust"
        log_success "Detected Rust project"
    elif [ -f "go.mod" ]; then
        PROJECT_TYPE="go"
        log_success "Detected Go project"
    elif [ -f "requirements.txt" ] || [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
        PROJECT_TYPE="python"
        log_success "Detected Python project"
    elif [ -f "pom.xml" ]; then
        PROJECT_TYPE="java"
        log_success "Detected Java project"
    elif [ -f "composer.json" ]; then
        PROJECT_TYPE="php"
        log_success "Detected PHP project"
    elif [ -f "Gemfile" ]; then
        PROJECT_TYPE="ruby"
        log_success "Detected Ruby project"
    elif [ -f "pubspec.yaml" ]; then
        PROJECT_TYPE="dart"
        log_success "Detected Dart/Flutter project"
    else
        PROJECT_TYPE="generic"
        log_warning "Could not detect specific project type, using generic configuration"
    fi
    
    export PROJECT_TYPE
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
    
    # Get git remote URL
    GIT_REMOTE=$(git remote get-url origin 2>/dev/null || echo "unknown")
    
    # Get current branch
    CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
    
    # Get author info
    AUTHOR_NAME=$(git config user.name 2>/dev/null || echo "Unknown")
    AUTHOR_EMAIL=$(git config user.email 2>/dev/null || echo "unknown@example.com")
    
    export PROJECT_NAME GIT_REMOTE CURRENT_BRANCH AUTHOR_NAME AUTHOR_EMAIL
    
    log_success "Project info gathered: $PROJECT_NAME"
}

backup_existing_config() {
    log_info "Backing up existing configuration..."
    
    # Create backup directory
    BACKUP_DIR=".claude-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # Backup existing Claude configuration if it exists
    if [ -f ".claude.md" ]; then
        cp ".claude.md" "$BACKUP_DIR/"
        log_success "Backed up existing .claude.md"
    fi
    
    # Backup any existing Claude configuration files
    if [ -d ".claude-old" ]; then
        cp -r ".claude-old" "$BACKUP_DIR/"
        log_success "Backed up existing .claude-old directory"
    fi
    
    log_success "Backup completed in $BACKUP_DIR"
}

setup_project_context() {
    log_info "Setting up project-specific context..."
    
    # Create project context from template
    if [ -f "$TEMPLATES_DIR/project-context.md" ]; then
        cp "$TEMPLATES_DIR/project-context.md" "$CLAUDE_DIR/project-context.md"
        
        # Replace placeholders
        sed -i.bak "s/\[\[PROJECT_NAME\]\]/$PROJECT_NAME/g" "$CLAUDE_DIR/project-context.md"
        sed -i.bak "s/\[\[PROJECT_TYPE\]\]/$PROJECT_TYPE/g" "$CLAUDE_DIR/project-context.md"
        sed -i.bak "s/\[\[AUTHOR_NAME\]\]/$AUTHOR_NAME/g" "$CLAUDE_DIR/project-context.md"
        sed -i.bak "s/\[\[AUTHOR_EMAIL\]\]/$AUTHOR_EMAIL/g" "$CLAUDE_DIR/project-context.md"
        sed -i.bak "s/\[\[GIT_REMOTE\]\]/$GIT_REMOTE/g" "$CLAUDE_DIR/project-context.md"
        sed -i.bak "s/\[\[CURRENT_BRANCH\]\]/$CURRENT_BRANCH/g" "$CLAUDE_DIR/project-context.md"
        
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
        sed -i.bak "s/\[\[PROJECT_NAME\]\]/$PROJECT_NAME/g" "$CLAUDE_DIR/team-standards.md"
        sed -i.bak "s/\[\[PROJECT_TYPE\]\]/$PROJECT_TYPE/g" "$CLAUDE_DIR/team-standards.md"
        
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
        sed -i.bak "s/\[\[PROJECT_NAME\]\]/$PROJECT_NAME/g" "$CLAUDE_DIR/custom-config.yaml"
        sed -i.bak "s/\[\[PROJECT_TYPE\]\]/$PROJECT_TYPE/g" "$CLAUDE_DIR/custom-config.yaml"
        sed -i.bak "s/\[\[AUTHOR_NAME\]\]/$AUTHOR_NAME/g" "$CLAUDE_DIR/custom-config.yaml"
        
        # Clean up backup files
        rm -f "$CLAUDE_DIR/custom-config.yaml.bak"
        
        log_success "Custom configuration file created"
    else
        log_warning "Custom config template not found"
    fi
}

create_claude_md() {
    log_info "Creating .claude.md file..."
    
    cat > ".claude.md" << EOF
# Claude Configuration for $PROJECT_NAME

This project uses Claude Config Global for standardized development practices.

## Project Information
- **Name**: $PROJECT_NAME
- **Type**: $PROJECT_TYPE
- **Author**: $AUTHOR_NAME
- **Repository**: $GIT_REMOTE

## Configuration
- **Main Config**: .claude/config.yaml
- **Project Context**: .claude/project-context.md
- **Team Standards**: .claude/team-standards.md
- **Custom Config**: .claude/custom-config.yaml

## Available Commands
- **Setup**: \`./claude/tools/setup-project.sh\`
- **Update**: \`./claude/tools/update-config.sh\`
- **Detect**: \`./claude/tools/detect-project.sh\`

## Usage
Claude Code will automatically load configurations from the .claude directory.
For project-specific customizations, edit the files in .claude/templates/.

## Version
Claude Config Global version: $(cat "$VERSION_FILE" 2>/dev/null || echo "Unknown")

Generated on: $(date)
EOF
    
    log_success ".claude.md file created"
}

setup_gitignore() {
    log_info "Setting up .gitignore for Claude configuration..."
    
    # Add Claude-specific ignores to .gitignore
    if [ -f ".gitignore" ]; then
        # Check if Claude ignores already exist
        if ! grep -q "# Claude Config" .gitignore; then
            echo "" >> .gitignore
            echo "# Claude Config Global" >> .gitignore
            echo ".claude/*.log" >> .gitignore
            echo ".claude/*.tmp" >> .gitignore
            echo ".claude/local-*" >> .gitignore
            echo ".claude-backup-*/" >> .gitignore
            
            log_success "Updated .gitignore with Claude-specific rules"
        else
            log_info ".gitignore already contains Claude rules"
        fi
    else
        # Create new .gitignore
        cat > ".gitignore" << EOF
# Claude Config Global
.claude/*.log
.claude/*.tmp
.claude/local-*
.claude-backup-*/

# Common ignores
node_modules/
.env
.env.local
*.log
*.tmp
.DS_Store
Thumbs.db
EOF
        log_success "Created .gitignore with Claude rules"
    fi
}

setup_project_specific_tools() {
    log_info "Setting up project-specific tools..."
    
    case $PROJECT_TYPE in
        "nodejs")
            setup_nodejs_tools
            ;;
        "python")
            setup_python_tools
            ;;
        "rust")
            setup_rust_tools
            ;;
        "go")
            setup_go_tools
            ;;
        "java")
            setup_java_tools
            ;;
        *)
            log_info "No specific tools for $PROJECT_TYPE"
            ;;
    esac
}

setup_nodejs_tools() {
    log_info "Setting up Node.js specific tools..."
    
    # Add npm scripts for Claude if package.json exists
    if [ -f "package.json" ] && command -v jq > /dev/null 2>&1; then
        # Create a temporary package.json with Claude scripts
        jq '.scripts.claude = "echo \"Claude Config Global v$(cat .claude/VERSION)\""' package.json > package.json.tmp
        jq '.scripts["claude:update"] = "./.claude/tools/update-config.sh"' package.json.tmp > package.json.tmp2
        jq '.scripts["claude:detect"] = "./.claude/tools/detect-project.sh"' package.json.tmp2 > package.json.tmp3
        
        mv package.json.tmp3 package.json
        rm -f package.json.tmp package.json.tmp2
        
        log_success "Added Claude scripts to package.json"
    fi
}

setup_python_tools() {
    log_info "Setting up Python specific tools..."
    
    # Add Claude tools to Makefile if it exists
    if [ -f "Makefile" ]; then
        if ! grep -q "claude:" Makefile; then
            echo "" >> Makefile
            echo "# Claude Config Global" >> Makefile
            echo "claude:" >> Makefile
            echo -e "\t@echo \"Claude Config Global v\$\$(cat .claude/VERSION)\"" >> Makefile
            echo "claude-update:" >> Makefile
            echo -e "\t@./.claude/tools/update-config.sh" >> Makefile
            
            log_success "Added Claude targets to Makefile"
        fi
    fi
}

setup_rust_tools() {
    log_info "Setting up Rust specific tools..."
    
    # Could add Cargo.toml metadata or other Rust-specific setup
    log_info "Rust-specific setup completed"
}

setup_go_tools() {
    log_info "Setting up Go specific tools..."
    
    # Could add Go-specific tools or Makefile targets
    log_info "Go-specific setup completed"
}

setup_java_tools() {
    log_info "Setting up Java specific tools..."
    
    # Could add Maven or Gradle tasks
    log_info "Java-specific setup completed"
}

verify_installation() {
    log_info "Verifying installation..."
    
    # Check that all required files exist
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
    
    if [ ! -f ".claude.md" ]; then
        log_error ".claude.md not found"
        errors=$((errors + 1))
    fi
    
    if [ $errors -eq 0 ]; then
        log_success "Installation verification passed"
        return 0
    else
        log_error "Installation verification failed with $errors errors"
        return 1
    fi
}

show_next_steps() {
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                              Setup Complete!                                 ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${BLUE}Next Steps:${NC}"
    echo "1. Review and customize .claude/project-context.md"
    echo "2. Update .claude/team-standards.md with your team's standards"
    echo "3. Modify .claude/custom-config.yaml for project-specific settings"
    echo "4. Commit the Claude configuration to your repository"
    echo "5. Share the setup with your team"
    echo ""
    echo -e "${BLUE}Available Commands:${NC}"
    echo "- Update config: ${YELLOW}./.claude/tools/update-config.sh${NC}"
    echo "- Detect project: ${YELLOW}./.claude/tools/detect-project.sh${NC}"
    echo "- View help: ${YELLOW}cat .claude/README.md${NC}"
    echo ""
    echo -e "${BLUE}Claude Code Integration:${NC}"
    echo "Claude Code will automatically load configurations from .claude/"
    echo "No additional setup required - just start coding!"
    echo ""
    echo -e "${GREEN}Happy coding with Claude Config Global! 🚀${NC}"
}

# Main execution
main() {
    print_header
    
    # Run setup steps
    check_prerequisites
    detect_project_type
    get_project_info
    backup_existing_config
    setup_project_context
    setup_team_standards
    setup_custom_config
    create_claude_md
    setup_gitignore
    setup_project_specific_tools
    
    # Verify and show results
    if verify_installation; then
        show_next_steps
    else
        log_error "Setup failed. Please check the errors above."
        exit 1
    fi
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Claude Config Global Setup Script"
        echo ""
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  -h, --help     Show this help message"
        echo "  --dry-run      Show what would be done without making changes"
        echo "  --force        Force setup even if configuration exists"
        echo "  --quiet        Suppress non-error output"
        echo ""
        echo "This script sets up Claude Config Global in your project."
        echo "Run it from your project root after cloning claude-config-global to .claude/"
        exit 0
        ;;
    --dry-run)
        log_info "Dry run mode - no changes will be made"
        # Set dry run flag and run main with modifications
        DRY_RUN=true
        export DRY_RUN
        main
        ;;
    --force)
        log_info "Force mode - will overwrite existing configuration"
        FORCE=true
        export FORCE
        main
        ;;
    --quiet)
        # Redirect output to suppress info messages
        exec 1>/dev/null
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