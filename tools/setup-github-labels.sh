#!/bin/bash

# Setup GitHub Labels Script
# Configura las etiquetas de GitHub para Claude Config Global

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
    echo "║                     GitHub Labels Setup for Claude Config Global            ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if gh CLI is installed
    if ! command -v gh > /dev/null 2>&1; then
        log_error "GitHub CLI (gh) is not installed"
        echo ""
        echo "Please install GitHub CLI first:"
        echo "  macOS: brew install gh"
        echo "  Ubuntu: https://cli.github.com/manual/installation"
        echo "  Windows: winget install GitHub.cli"
        exit 1
    fi
    
    # Check if user is authenticated
    if ! gh auth status > /dev/null 2>&1; then
        log_error "You are not authenticated with GitHub CLI"
        echo ""
        echo "Please authenticate first:"
        echo "  gh auth login"
        exit 1
    fi
    
    # Check if labels file exists
    if [ ! -f ".github/labels.yml" ]; then
        log_error "Labels file not found at .github/labels.yml"
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

setup_labels() {
    log_info "Setting up GitHub labels..."
    
    # Get repository info
    REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
    log_info "Repository: $REPO"
    
    # Parse and create labels from YAML file
    log_info "Creating labels from .github/labels.yml..."
    
    # Read labels from YAML and create them
    # Note: This is a simple parser - for production, consider using yq
    while IFS= read -r line; do
        if [[ $line =~ ^[[:space:]]*-[[:space:]]*name:[[:space:]]*\"(.*)\" ]]; then
            name="${BASH_REMATCH[1]}"
            # Read next lines for color and description
            read -r color_line
            read -r desc_line
            
            if [[ $color_line =~ color:[[:space:]]*\"(.*)\" ]]; then
                color="${BASH_REMATCH[1]}"
            fi
            
            if [[ $desc_line =~ description:[[:space:]]*\"(.*)\" ]]; then
                description="${BASH_REMATCH[1]}"
            fi
            
            # Create or update label
            if gh label create "$name" --color "$color" --description "$description" 2>/dev/null; then
                log_success "Created label: $name"
            else
                # Label might exist, try to update
                if gh label edit "$name" --color "$color" --description "$description" 2>/dev/null; then
                    log_info "Updated existing label: $name"
                else
                    log_warning "Could not create/update label: $name"
                fi
            fi
        fi
    done < .github/labels.yml
    
    log_success "Labels setup completed"
}

show_summary() {
    echo ""
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                              Setup Complete!                                 ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${BLUE}What was configured:${NC}"
    echo "✅ Priority labels (critical, high, medium, low)"
    echo "✅ Type labels (bug, enhancement, documentation, etc.)"
    echo "✅ Component labels (prompts, meta-testing, tools, etc.)"
    echo "✅ Technology labels (javascript, python, docker, etc.)"
    echo "✅ Status labels (needs-triage, in-progress, etc.)"
    echo "✅ Meta-testing specific labels"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Labels are now available in your GitHub repository"
    echo "2. Use them when creating issues and PRs"
    echo "3. Configure GitHub issue templates (already in .github/ISSUE_TEMPLATE/)"
    echo "4. Set up branch protection rules if needed"
    echo ""
    echo -e "${YELLOW}Note:${NC} You can view all labels at:"
    echo "https://github.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/labels"
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "GitHub Labels Setup Script for Claude Config Global"
        echo ""
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  -h, --help     Show this help message"
        echo "  --dry-run      Show what would be done without making changes"
        echo ""
        echo "Prerequisites:"
        echo "  - GitHub CLI (gh) installed and authenticated"
        echo "  - Run from repository root directory"
        echo ""
        echo "This script creates/updates GitHub labels for better issue organization."
        exit 0
        ;;
    --dry-run)
        log_info "Dry run mode - showing what would be done"
        check_prerequisites
        log_info "Would create/update labels from .github/labels.yml"
        log_info "Repository: $(gh repo view --json nameWithOwner -q .nameWithOwner)"
        echo ""
        echo "Labels to be created/updated:"
        grep -E "^\s*-\s*name:" .github/labels.yml | sed 's/.*name: *"/  - /' | sed 's/".*//'
        exit 0
        ;;
    "")
        # No arguments, run normally
        print_header
        check_prerequisites
        setup_labels
        show_summary
        ;;
    *)
        log_error "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac