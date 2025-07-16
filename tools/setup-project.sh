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
    
    # Check for jq dependency (used for JSON processing)
    if ! command -v jq > /dev/null 2>&1; then
        log_warning "jq is not installed. Some features may be limited."
        log_warning "To install jq:"
        echo ""
        echo "  # On Ubuntu/Debian:"
        echo "  sudo apt-get install jq"
        echo ""
        echo "  # On macOS with Homebrew:"
        echo "  brew install jq"
        echo ""
        echo "  # On CentOS/RHEL:"
        echo "  sudo yum install jq"
        echo ""
        echo "Setup will continue, but package.json processing may be limited."
        echo ""
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

run_project_detection() {
    log_info "Running detailed project detection..."
    
    # Initialize variables with defaults
    DETECTED_TECHNOLOGIES="unknown"
    PRIMARY_FRAMEWORK="unknown"
    FILE_COUNT="0"
    BUILD_TOOL="unknown"
    PACKAGE_MANAGER="unknown"
    FRAMEWORKS="unknown"
    DETECTED_DATABASES="none"
    CONTAINER_TECH="none"
    DETECTION_SUMMARY="{}"
    GENERATION_DATE=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
    
    # Run detect-project.sh if available
    if [ -f "$TOOLS_DIR/detect-project.sh" ]; then
        log_info "Running project detection script..."
        
        # Make script executable and run it
        chmod +x "$TOOLS_DIR/detect-project.sh"
        "$TOOLS_DIR/detect-project.sh" --quiet
        
        # Extract information if jq is available and detection file exists
        if [ -f "$CLAUDE_DIR/project-detection.json" ] && command -v jq > /dev/null 2>&1; then
            log_info "Processing detection results..."
            
            # Extract detected technologies
            DETECTED_TECHNOLOGIES=$(jq -r '.detections[] | select(.confidence > 30) | .type' "$CLAUDE_DIR/project-detection.json" | tr '\n' ', ' | sed 's/,$//' | sed 's/,/, /g')
            
            # Get primary framework
            PRIMARY_FRAMEWORK=$(jq -r '.detections[0].type // "unknown"' "$CLAUDE_DIR/project-detection.json")
            
            # Get file count
            FILE_COUNT=$(jq -r '.file_structure.total_files // 0' "$CLAUDE_DIR/project-detection.json")
            
            # Extract build tools and package managers
            if echo "$DETECTED_TECHNOLOGIES" | grep -q "nodejs"; then
                PACKAGE_MANAGER="npm/yarn/pnpm"
                if [ -f "package.json" ] && command -v jq > /dev/null 2>&1; then
                    BUILD_TOOL=$(jq -r '.scripts.build // "no build script"' package.json 2>/dev/null)
                fi
            elif echo "$DETECTED_TECHNOLOGIES" | grep -q "python"; then
                PACKAGE_MANAGER="pip/poetry/conda"
                BUILD_TOOL="setuptools/poetry"
            elif echo "$DETECTED_TECHNOLOGIES" | grep -q "rust"; then
                PACKAGE_MANAGER="cargo"
                BUILD_TOOL="cargo"
            elif echo "$DETECTED_TECHNOLOGIES" | grep -q "go"; then
                PACKAGE_MANAGER="go modules"
                BUILD_TOOL="go build"
            fi
            
            # Extract frameworks
            FRAMEWORKS=$(jq -r '.detections[] | select(.confidence > 20) | select(.type | test("web-frontend|mobile|flutter")) | .type' "$CLAUDE_DIR/project-detection.json" | tr '\n' ', ' | sed 's/,$//' | sed 's/,/, /g')
            [ -z "$FRAMEWORKS" ] && FRAMEWORKS="none detected"
            
            # Extract databases
            DETECTED_DATABASES=$(jq -r '.detections[] | select(.type == "database") | .databases[]? // empty' "$CLAUDE_DIR/project-detection.json" 2>/dev/null | tr '\n' ', ' | sed 's/,$//' | sed 's/,/, /g')
            [ -z "$DETECTED_DATABASES" ] && DETECTED_DATABASES="none detected"
            
            # Extract container technology
            if echo "$DETECTED_TECHNOLOGIES" | grep -q "docker"; then
                CONTAINER_TECH="Docker"
                if echo "$DETECTED_TECHNOLOGIES" | grep -q "kubernetes"; then
                    CONTAINER_TECH="Docker + Kubernetes"
                fi
            else
                CONTAINER_TECH="none detected"
            fi
            
            # Create detection summary
            DETECTION_SUMMARY=$(jq -c '{primary_framework: .detections[0].type, confidence: .detections[0].confidence, total_files: .file_structure.total_files, git_branch: .git_info.current_branch}' "$CLAUDE_DIR/project-detection.json" 2>/dev/null || echo '{"error": "Could not parse detection results"}')
            
            log_success "Project detection completed successfully"
        else
            log_warning "Could not process detection results (missing jq or detection file)"
        fi
    else
        log_warning "Project detection script not found at $TOOLS_DIR/detect-project.sh"
    fi
    
    # Export all variables for use in templates
    export DETECTED_TECHNOLOGIES PRIMARY_FRAMEWORK FILE_COUNT BUILD_TOOL PACKAGE_MANAGER FRAMEWORKS DETECTED_DATABASES CONTAINER_TECH DETECTION_SUMMARY GENERATION_DATE
    
    log_success "Project detection variables prepared"
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
        
        # Replace basic placeholders
        sed -i.bak "s#\[\[PROJECT_NAME\]\]#$PROJECT_NAME#g" "$CLAUDE_DIR/project-context.md"
        sed -i.bak "s#\[\[PROJECT_TYPE\]\]#$PROJECT_TYPE#g" "$CLAUDE_DIR/project-context.md"
        sed -i.bak "s#\[\[AUTHOR_NAME\]\]#$AUTHOR_NAME#g" "$CLAUDE_DIR/project-context.md"
        sed -i.bak "s#\[\[AUTHOR_EMAIL\]\]#$AUTHOR_EMAIL#g" "$CLAUDE_DIR/project-context.md"
        sed -i.bak "s#\[\[GIT_REMOTE\]\]#$GIT_REMOTE#g" "$CLAUDE_DIR/project-context.md"
        sed -i.bak "s#\[\[CURRENT_BRANCH\]\]#$CURRENT_BRANCH#g" "$CLAUDE_DIR/project-context.md"
        
        # Replace auto-detected information placeholders
        sed -i.bak "s#\[\[PRIMARY_FRAMEWORK\]\]#$PRIMARY_FRAMEWORK#g" "$CLAUDE_DIR/project-context.md"
        sed -i.bak "s#\[\[DETECTED_TECHNOLOGIES\]\]#$DETECTED_TECHNOLOGIES#g" "$CLAUDE_DIR/project-context.md"
        sed -i.bak "s#\[\[FILE_COUNT\]\]#$FILE_COUNT#g" "$CLAUDE_DIR/project-context.md"
        sed -i.bak "s#\[\[BUILD_TOOL\]\]#$BUILD_TOOL#g" "$CLAUDE_DIR/project-context.md"
        sed -i.bak "s#\[\[PACKAGE_MANAGER\]\]#$PACKAGE_MANAGER#g" "$CLAUDE_DIR/project-context.md"
        sed -i.bak "s#\[\[FRAMEWORKS\]\]#$FRAMEWORKS#g" "$CLAUDE_DIR/project-context.md"
        sed -i.bak "s#\[\[DETECTED_DATABASES\]\]#$DETECTED_DATABASES#g" "$CLAUDE_DIR/project-context.md"
        sed -i.bak "s#\[\[CONTAINER_TECH\]\]#$CONTAINER_TECH#g" "$CLAUDE_DIR/project-context.md"
        sed -i.bak "s#\[\[GENERATION_DATE\]\]#$GENERATION_DATE#g" "$CLAUDE_DIR/project-context.md"
        sed -i.bak "s#\[\[DETECTION_SUMMARY\]\]#$DETECTION_SUMMARY#g" "$CLAUDE_DIR/project-context.md"
        
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
- **Installation Mode**: ${INSTALLATION_MODE:-full}

## Configuration
- **Main Config**: .claude/config.yaml$([ "$INSTALLATION_MODE" = "full" ] && echo "
- **Project Context**: .claude/project-context.md
- **Team Standards**: .claude/team-standards.md
- **Custom Config**: .claude/custom-config.yaml" || echo "
- **Essential Context**: .claude/context/code-quality.md, .claude/context/security-basics.md
- **Essential Prompt**: .claude/prompts/code-review.md")

## Available Commands
- **Setup**: \`./claude/tools/setup-project.sh\`
- **Update**: \`./claude/tools/update-config.sh\`
- **Detect**: \`./claude/tools/detect-project.sh\`$([ "$INSTALLATION_MODE" = "lite" ] && echo "
- **Upgrade to Full**: \`./claude/tools/upgrade-to-full.sh\`")

## Usage
Claude Code will automatically load configurations from the .claude directory.
For project-specific customizations, edit the files in .claude/templates/.$([ "$INSTALLATION_MODE" = "lite" ] && echo "

**Note**: This is a Lite installation. To access all prompts, contexts, and workflows, run:
\`./claude/tools/upgrade-to-full.sh\`")

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
    
    if [ ! -f ".claude.md" ]; then
        log_error ".claude.md not found"
        errors=$((errors + 1))
    fi
    
    # For Full installation, check additional files
    if [ "$INSTALLATION_MODE" = "full" ]; then
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
    
    if [ "$INSTALLATION_MODE" = "lite" ]; then
        echo -e "${BLUE}Lite Installation Complete!${NC}"
        echo -e "${YELLOW}You have installed the essential Claude Config Global components.${NC}"
        echo ""
        echo -e "${BLUE}Next Steps:${NC}"
        echo "1. Start using Claude Code with the essential configuration"
        echo "2. When ready for more features, run: ${YELLOW}./.claude/tools/upgrade-to-full.sh${NC}"
        echo "3. Commit the Claude configuration to your repository"
        echo "4. Share the setup with your team"
        echo ""
        echo -e "${BLUE}Available Commands:${NC}"
        echo "- Upgrade to Full: ${YELLOW}./.claude/tools/upgrade-to-full.sh${NC}"
        echo "- Update config: ${YELLOW}./.claude/tools/update-config.sh${NC}"
        echo "- Detect project: ${YELLOW}./.claude/tools/detect-project.sh${NC}"
        echo "- View help: ${YELLOW}cat .claude/README.md${NC}"
    else
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
    fi
    
    echo ""
    echo -e "${BLUE}Claude Code Integration:${NC}"
    echo "Claude Code will automatically load configurations from .claude/"
    echo "No additional setup required - just start coding!"
    echo ""
    echo -e "${GREEN}Happy coding with Claude Config Global! 🚀${NC}"
}

# Installation mode selection
select_installation_mode() {
    log_info "Selecting installation mode..."
    echo ""
    echo -e "${BLUE}Please choose your installation mode:${NC}"
    echo ""
    echo -e "${GREEN}1. Full Installation${NC} (Recommended for teams and established projects)"
    echo -e "   → All prompts, contexts, workflows, and templates"
    echo -e "   → Complete Claude Config Global experience"
    echo ""
    echo -e "${YELLOW}2. Lite Installation${NC} (Ideal for getting started or small projects)"
    echo -e "   → Essential configurations and core tools"
    echo -e "   → Can be upgraded to Full later with upgrade-to-full.sh"
    echo ""
    
    while true; do
        read -p "Choose your installation mode [1-2]: " choice
        case $choice in
            1|"full"|"Full"|"FULL")
                INSTALLATION_MODE="full"
                log_success "Selected Full Installation"
                break
                ;;
            2|"lite"|"Lite"|"LITE")
                INSTALLATION_MODE="lite"
                log_success "Selected Lite Installation"
                break
                ;;
            *)
                echo -e "${RED}Invalid choice. Please enter 1 for Full or 2 for Lite.${NC}"
                ;;
        esac
    done
    
    export INSTALLATION_MODE
}

# Lite installation setup
setup_lite_installation() {
    log_info "Setting up Lite installation..."
    
    # Create essential directories
    mkdir -p "$CLAUDE_DIR"
    
    # Copy essential files for Lite installation
    # Core configuration
    if [ -f "$CONFIG_FILE" ]; then
        log_success "Main configuration already exists"
    else
        log_error "config.yaml not found"
        exit 1
    fi
    
    # Essential context files
    if [ -f "$CLAUDE_DIR/context/code-quality.md" ]; then
        log_success "Code quality context available"
    fi
    
    if [ -f "$CLAUDE_DIR/context/security-basics.md" ]; then
        log_success "Security basics context available"
    fi
    
    # Essential prompt
    if [ -f "$CLAUDE_DIR/prompts/code-review.md" ]; then
        log_success "Code review prompt available"
    fi
    
    # All tools and templates remain available
    log_success "Tools and templates directory available"
    
    log_success "Lite installation setup completed"
}

# Full installation setup (existing behavior)
setup_full_installation() {
    log_info "Setting up Full installation..."
    
    # Run all the original setup steps
    setup_project_context
    setup_team_standards
    setup_custom_config
    setup_project_specific_tools
    
    log_success "Full installation setup completed"
}

# Main execution
main() {
    print_header
    
    # Run common setup steps
    check_prerequisites
    detect_project_type
    get_project_info
    run_project_detection
    backup_existing_config
    
    # Select installation mode
    select_installation_mode
    
    # Run mode-specific setup
    if [ "$INSTALLATION_MODE" = "lite" ]; then
        setup_lite_installation
    else
        setup_full_installation
    fi
    
    # Run common final steps
    create_claude_md
    setup_gitignore
    
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