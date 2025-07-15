#!/bin/bash

# Update Config Script
# Script para actualizar la configuración de Claude Config Global

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
BACKUP_DIR=".claude-update-backup-$(date +%Y%m%d-%H%M%S)"

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
    echo "║                       Claude Config Global Update                            ║"
    echo "║                    Keep your configuration up to date                       ║"
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
    
    # Check if this is a Claude Config Global setup
    if [ ! -f "$VERSION_FILE" ]; then
        log_error "This doesn't appear to be a Claude Config Global setup"
        exit 1
    fi
    
    # Check for Python3 and PyYAML dependency
    if ! command -v python3 > /dev/null 2>&1; then
        log_error "python3 is required but not installed"
        log_error "Please install Python 3 and try again"
        exit 1
    fi
    
    # Explicit PyYAML verification
    if ! python3 -c "import yaml" 2>/dev/null; then
        log_error "PyYAML is required but not installed"
        log_error "Please install PyYAML using one of the following commands:"
        echo ""
        echo "  # Using pip:"
        echo "  pip install PyYAML"
        echo ""
        echo "  # Using pip3:"
        echo "  pip3 install PyYAML"
        echo ""
        echo "  # Using conda:"
        echo "  conda install pyyaml"
        echo ""
        echo "  # On Ubuntu/Debian:"
        echo "  sudo apt-get install python3-yaml"
        echo ""
        echo "  # On macOS with Homebrew:"
        echo "  brew install libyaml && pip3 install PyYAML"
        echo ""
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

get_current_version() {
    if [ -f "$VERSION_FILE" ]; then
        CURRENT_VERSION=$(cat "$VERSION_FILE")
        log_info "Current version: $CURRENT_VERSION"
    else
        CURRENT_VERSION="unknown"
        log_warning "Current version unknown"
    fi
}

check_for_updates() {
    log_info "Checking for updates..."
    
    # Check if we're in a git repository and .claude is a git repo
    if [ -d "$CLAUDE_DIR/.git" ]; then
        cd "$CLAUDE_DIR"
        
        # Fetch latest changes
        if git fetch origin main 2>/dev/null; then
            # Check if there are updates
            LOCAL_COMMIT=$(git rev-parse HEAD)
            REMOTE_COMMIT=$(git rev-parse origin/main)
            
            if [ "$LOCAL_COMMIT" != "$REMOTE_COMMIT" ]; then
                log_info "Updates available!"
                UPDATES_AVAILABLE=true
            else
                log_info "No updates available"
                UPDATES_AVAILABLE=false
            fi
        else
            log_warning "Could not check for updates (no internet or remote not accessible)"
            UPDATES_AVAILABLE=false
        fi
        
        cd - > /dev/null
    else
        log_warning ".claude directory is not a git repository"
        UPDATES_AVAILABLE=false
    fi
}

backup_current_config() {
    log_info "Creating backup of current configuration..."
    
    # Create backup directory
    mkdir -p "$BACKUP_DIR"
    
    # Backup current configuration
    cp -r "$CLAUDE_DIR" "$BACKUP_DIR/claude-backup"
    
    # Backup project-specific files
    if [ -f ".claude.md" ]; then
        cp ".claude.md" "$BACKUP_DIR/"
    fi
    
    log_success "Backup created at $BACKUP_DIR"
}

update_core_config() {
    log_info "Updating core configuration..."
    
    if [ "$UPDATES_AVAILABLE" = true ]; then
        cd "$CLAUDE_DIR"
        
        # Preserve custom files
        CUSTOM_FILES=()
        if [ -f "project-context.md" ]; then
            CUSTOM_FILES+=("project-context.md")
        fi
        if [ -f "team-standards.md" ]; then
            CUSTOM_FILES+=("team-standards.md")
        fi
        if [ -f "custom-config.yaml" ]; then
            CUSTOM_FILES+=("custom-config.yaml")
        fi
        
        # Move custom files to temporary location
        TEMP_DIR=$(mktemp -d)
        for file in "${CUSTOM_FILES[@]}"; do
            if [ -f "$file" ]; then
                cp "$file" "$TEMP_DIR/"
            fi
        done
        
        # Pull updates
        git pull origin main
        
        # Restore custom files
        for file in "${CUSTOM_FILES[@]}"; do
            if [ -f "$TEMP_DIR/$file" ]; then
                cp "$TEMP_DIR/$file" "$file"
            fi
        done
        
        # Clean up temp directory
        rm -rf "$TEMP_DIR"
        
        cd - > /dev/null
        
        log_success "Core configuration updated"
    else
        log_info "No updates to apply"
    fi
}

update_project_context() {
    log_info "Updating project context..."
    
    # Check if template has been updated
    if [ -f "$CLAUDE_DIR/templates/project-context.md" ] && [ -f "$CLAUDE_DIR/project-context.md" ]; then
        # Compare templates to see if there are new sections
        if ! diff -q "$CLAUDE_DIR/templates/project-context.md" "$CLAUDE_DIR/project-context.md" > /dev/null 2>&1; then
            log_info "Project context template has been updated"
            
            # Offer to merge updates
            echo "The project context template has been updated. Options:"
            echo "1. Keep current project context (default)"
            echo "2. Replace with new template (lose customizations)"
            echo "3. Create .new file for manual merge"
            
            read -p "Choose option (1-3): " -r choice
            case $choice in
                2)
                    # Replace with new template
                    cp "$CLAUDE_DIR/templates/project-context.md" "$CLAUDE_DIR/project-context.md"
                    log_success "Project context replaced with new template"
                    ;;
                3)
                    # Create .new file
                    cp "$CLAUDE_DIR/templates/project-context.md" "$CLAUDE_DIR/project-context.md.new"
                    log_success "New template saved as project-context.md.new"
                    ;;
                *)
                    log_info "Keeping current project context"
                    ;;
            esac
        else
            log_info "Project context is up to date"
        fi
    fi
}

update_team_standards() {
    log_info "Updating team standards..."
    
    # Similar logic for team standards
    if [ -f "$CLAUDE_DIR/templates/team-standards.md" ] && [ -f "$CLAUDE_DIR/team-standards.md" ]; then
        if ! diff -q "$CLAUDE_DIR/templates/team-standards.md" "$CLAUDE_DIR/team-standards.md" > /dev/null 2>&1; then
            log_info "Team standards template has been updated"
            
            echo "The team standards template has been updated. Options:"
            echo "1. Keep current team standards (default)"
            echo "2. Replace with new template (lose customizations)"
            echo "3. Create .new file for manual merge"
            
            read -p "Choose option (1-3): " -r choice
            case $choice in
                2)
                    cp "$CLAUDE_DIR/templates/team-standards.md" "$CLAUDE_DIR/team-standards.md"
                    log_success "Team standards replaced with new template"
                    ;;
                3)
                    cp "$CLAUDE_DIR/templates/team-standards.md" "$CLAUDE_DIR/team-standards.md.new"
                    log_success "New template saved as team-standards.md.new"
                    ;;
                *)
                    log_info "Keeping current team standards"
                    ;;
            esac
        else
            log_info "Team standards are up to date"
        fi
    fi
}

update_custom_config() {
    log_info "Updating custom configuration..."
    
    # Check for custom config updates
    if [ -f "$CLAUDE_DIR/templates/custom-config.yaml" ] && [ -f "$CLAUDE_DIR/custom-config.yaml" ]; then
        if ! diff -q "$CLAUDE_DIR/templates/custom-config.yaml" "$CLAUDE_DIR/custom-config.yaml" > /dev/null 2>&1; then
            log_info "Custom config template has been updated"
            
            echo "The custom config template has been updated. Options:"
            echo "1. Keep current custom config (default)"
            echo "2. Replace with new template (lose customizations)"
            echo "3. Create .new file for manual merge"
            
            read -p "Choose option (1-3): " -r choice
            case $choice in
                2)
                    cp "$CLAUDE_DIR/templates/custom-config.yaml" "$CLAUDE_DIR/custom-config.yaml"
                    log_success "Custom config replaced with new template"
                    ;;
                3)
                    cp "$CLAUDE_DIR/templates/custom-config.yaml" "$CLAUDE_DIR/custom-config.yaml.new"
                    log_success "New template saved as custom-config.yaml.new"
                    ;;
                *)
                    log_info "Keeping current custom config"
                    ;;
            esac
        else
            log_info "Custom config is up to date"
        fi
    fi
}

update_claude_md() {
    log_info "Updating .claude.md..."
    
    # Get current version
    NEW_VERSION=$(cat "$VERSION_FILE" 2>/dev/null || echo "Unknown")
    
    # Update .claude.md with new version
    if [ -f ".claude.md" ]; then
        # Update version line
        sed -i.bak "s/Claude Config Global version: .*/Claude Config Global version: $NEW_VERSION/" ".claude.md"
        # Update generation date
        sed -i.bak "s/Generated on: .*/Generated on: $(date)/" ".claude.md"
        # Add update note
        echo "" >> ".claude.md"
        echo "Last updated: $(date)" >> ".claude.md"
        
        # Clean up backup
        rm -f ".claude.md.bak"
        
        log_success ".claude.md updated"
    fi
}

validate_configuration() {
    log_info "Validating configuration..."
    
    local errors=0
    
    # Check main config file
    if [ ! -f "$CONFIG_FILE" ]; then
        log_error "Main config file missing: $CONFIG_FILE"
        errors=$((errors + 1))
    else
        # Check if config is valid YAML (PyYAML already verified in prerequisites)
        if ! python3 -c "import yaml; yaml.safe_load(open('$CONFIG_FILE'))" 2>/dev/null; then
            log_error "Invalid YAML syntax in $CONFIG_FILE"
            errors=$((errors + 1))
        fi
    fi
    
    # Check required directories
    for dir in "context" "prompts" "workflows" "tools" "templates"; do
        if [ ! -d "$CLAUDE_DIR/$dir" ]; then
            log_error "Required directory missing: $CLAUDE_DIR/$dir"
            errors=$((errors + 1))
        fi
    done
    
    if [ $errors -eq 0 ]; then
        log_success "Configuration validation passed"
        return 0
    else
        log_error "Configuration validation failed with $errors errors"
        return 1
    fi
}

detect_project_changes() {
    log_info "Detecting project changes..."
    
    # Re-run project detection to see if anything changed
    if [ -f "$CLAUDE_DIR/tools/detect-project.sh" ]; then
        bash "$CLAUDE_DIR/tools/detect-project.sh" --quiet
        
        # Check if project type changed
        if [ -f "$CLAUDE_DIR/project-context.md" ]; then
            CURRENT_PROJECT_TYPE=$(grep "Project Type:" "$CLAUDE_DIR/project-context.md" | sed 's/.*Project Type: //')
            log_info "Current project type: $CURRENT_PROJECT_TYPE"
        fi
    fi
}

cleanup_old_files() {
    log_info "Cleaning up old files..."
    
    # Remove old backup files
    find . -name ".claude-backup-*" -type d -mtime +30 -exec rm -rf {} + 2>/dev/null || true
    find . -name ".claude-update-backup-*" -type d -mtime +30 -exec rm -rf {} + 2>/dev/null || true
    
    # Remove temp files
    find "$CLAUDE_DIR" -name "*.tmp" -delete 2>/dev/null || true
    find "$CLAUDE_DIR" -name "*.bak" -delete 2>/dev/null || true
    
    log_success "Cleanup completed"
}

show_update_summary() {
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                            Update Complete!                                  ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Show version information
    NEW_VERSION=$(cat "$VERSION_FILE" 2>/dev/null || echo "Unknown")
    echo -e "${BLUE}Version Information:${NC}"
    echo "Previous version: $CURRENT_VERSION"
    echo "Current version: $NEW_VERSION"
    echo ""
    
    # Show what was updated
    echo -e "${BLUE}What was updated:${NC}"
    if [ "$UPDATES_AVAILABLE" = true ]; then
        echo "✅ Core configuration files"
        echo "✅ Context documentation"
        echo "✅ Prompts and workflows"
        echo "✅ Tools and scripts"
    else
        echo "ℹ️  No updates were available"
    fi
    echo ""
    
    # Show backup location
    echo -e "${BLUE}Backup Information:${NC}"
    echo "Backup created at: $BACKUP_DIR"
    echo "You can restore from backup if needed"
    echo ""
    
    # Show next steps
    echo -e "${BLUE}Next Steps:${NC}"
    echo "1. Review any .new files created for manual merging"
    echo "2. Test your Claude Code integration"
    echo "3. Commit updated configuration to git"
    echo "4. Share updates with your team"
    echo ""
    
    # Show cleanup information
    echo -e "${BLUE}Maintenance:${NC}"
    echo "- Old backups (30+ days) have been cleaned up"
    echo "- Run this script regularly to stay up to date"
    echo "- Check for new features in the documentation"
    echo ""
    
    echo -e "${GREEN}Claude Config Global is now up to date! 🎉${NC}"
}

rollback_update() {
    log_info "Rolling back update..."
    
    if [ -d "$BACKUP_DIR" ]; then
        # Remove current .claude directory
        rm -rf "$CLAUDE_DIR"
        
        # Restore from backup
        cp -r "$BACKUP_DIR/claude-backup" "$CLAUDE_DIR"
        
        # Restore .claude.md if it exists
        if [ -f "$BACKUP_DIR/.claude.md" ]; then
            cp "$BACKUP_DIR/.claude.md" ".claude.md"
        fi
        
        log_success "Update rolled back successfully"
    else
        log_error "No backup found to rollback to"
        exit 1
    fi
}

# Main execution
main() {
    print_header
    
    # Run update steps
    check_prerequisites
    get_current_version
    check_for_updates
    backup_current_config
    update_core_config
    update_project_context
    update_team_standards
    update_custom_config
    update_claude_md
    detect_project_changes
    cleanup_old_files
    
    # Validate and show results
    if validate_configuration; then
        show_update_summary
    else
        log_error "Update failed validation. Rolling back..."
        rollback_update
        exit 1
    fi
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Claude Config Global Update Script"
        echo ""
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  -h, --help      Show this help message"
        echo "  --check         Check for updates without applying them"
        echo "  --force         Force update even if no changes detected"
        echo "  --rollback      Rollback to previous version"
        echo "  --quiet         Suppress non-error output"
        echo ""
        echo "This script updates Claude Config Global to the latest version."
        exit 0
        ;;
    --check)
        print_header
        check_prerequisites
        get_current_version
        check_for_updates
        if [ "$UPDATES_AVAILABLE" = true ]; then
            echo -e "${GREEN}Updates are available!${NC}"
            echo "Run without --check to apply updates"
        else
            echo -e "${BLUE}No updates available${NC}"
        fi
        exit 0
        ;;
    --force)
        log_info "Force mode - will update even if no changes detected"
        UPDATES_AVAILABLE=true
        main
        ;;
    --rollback)
        log_info "Rollback mode - will restore from latest backup"
        if [ -d "$BACKUP_DIR" ]; then
            rollback_update
        else
            # Find latest backup
            LATEST_BACKUP=$(ls -t .claude-update-backup-* 2>/dev/null | head -1)
            if [ -n "$LATEST_BACKUP" ]; then
                BACKUP_DIR="$LATEST_BACKUP"
                rollback_update
            else
                log_error "No backups found to rollback to"
                exit 1
            fi
        fi
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