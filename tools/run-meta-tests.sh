#!/bin/bash

# Meta-Testing Script for Claude Config Global
# Tests the quality and consistency of prompts and workflows

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$(dirname "$SCRIPT_DIR")"
META_TESTING_DIR="$CLAUDE_DIR/meta-testing"
SCENARIOS_DIR="$META_TESTING_DIR/scenarios"
TEMP_DIR="/tmp/claude-meta-tests-$$"
SIMILARITY_THRESHOLD=0.7
VERBOSE=false

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

log_test() {
    echo -e "${MAGENTA}[TEST]${NC} $1"
}

log_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${CYAN}[VERBOSE]${NC} $1"
    fi
}

print_header() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                           Claude Config Global Meta-Testing                  ║"
    echo "║                    Testing Prompt Quality and Consistency                    ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_usage() {
    echo "Claude Config Global Meta-Testing Script"
    echo ""
    echo "Usage: $0 [OPTIONS] [SCENARIO_NAME]"
    echo ""
    echo "Arguments:"
    echo "  SCENARIO_NAME    Name of specific scenario to test (optional)"
    echo "                   If not provided, all scenarios will be tested"
    echo ""
    echo "Options:"
    echo "  -h, --help       Show this help message"
    echo "  -v, --verbose    Enable verbose output"
    echo "  -t, --threshold  Set similarity threshold (0.0-1.0, default: 0.7)"
    echo "  --dry-run        Show what would be tested without running tests"
    echo "  --list           List available test scenarios"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Run all scenarios"
    echo "  $0 refactor-python-complex-function  # Run specific scenario"
    echo "  $0 --verbose --threshold 0.8         # Run with high similarity threshold"
    echo ""
    echo "Exit codes:"
    echo "  0    All tests passed"
    echo "  1    One or more tests failed"
    echo "  2    Configuration or setup error"
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if we're in the right directory
    if [ ! -d "$CLAUDE_DIR" ]; then
        log_error "Claude Config Global not found. Run this script from a project with .claude/ directory"
        exit 2
    fi
    
    # Check if meta-testing directory exists
    if [ ! -d "$META_TESTING_DIR" ]; then
        log_error "Meta-testing directory not found at $META_TESTING_DIR"
        exit 2
    fi
    
    # Check if scenarios directory exists
    if [ ! -d "$SCENARIOS_DIR" ]; then
        log_error "Scenarios directory not found at $SCENARIOS_DIR"
        exit 2
    fi
    
    # Check for required tools
    local missing_tools=()
    
    if ! command -v python3 > /dev/null 2>&1; then
        missing_tools+=("python3")
    fi
    
    # Check if we can install required Python packages
    if ! python3 -c "import difflib, re, json, hashlib" 2>/dev/null; then
        log_warning "Some Python modules may be missing. Basic comparison will be used."
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        exit 2
    fi
    
    # Create temp directory
    mkdir -p "$TEMP_DIR"
    
    log_success "Prerequisites check passed"
}

list_scenarios() {
    log_info "Available test scenarios:"
    echo ""
    
    if [ ! -d "$SCENARIOS_DIR" ]; then
        log_warning "No scenarios directory found"
        return
    fi
    
    local count=0
    for scenario_dir in "$SCENARIOS_DIR"/*; do
        if [ -d "$scenario_dir" ]; then
            local scenario_name=$(basename "$scenario_dir")
            echo "  • $scenario_name"
            
            # Show description if available
            if [ -f "$scenario_dir/README.md" ]; then
                local description=$(head -n 5 "$scenario_dir/README.md" | grep -E "^# |^## " | head -n 1 | sed 's/^#* *//')
                if [ -n "$description" ]; then
                    echo "    $description"
                fi
            fi
            
            count=$((count + 1))
        fi
    done
    
    echo ""
    log_info "Total scenarios: $count"
}

validate_scenario() {
    local scenario_path="$1"
    local scenario_name=$(basename "$scenario_path")
    
    log_verbose "Validating scenario: $scenario_name"
    
    # Check required files
    local required_files=("input" "prompt.md" "golden-master.md")
    for file in "${required_files[@]}"; do
        if [ ! -e "$scenario_path/$file" ]; then
            log_error "Scenario '$scenario_name' missing required file/directory: $file"
            return 1
        fi
    done
    
    # Check if input directory has files
    if [ -z "$(ls -A "$scenario_path/input" 2>/dev/null)" ]; then
        log_error "Scenario '$scenario_name' has empty input directory"
        return 1
    fi
    
    log_verbose "Scenario validation passed: $scenario_name"
    return 0
}

simulate_claude_execution() {
    local scenario_path="$1"
    local scenario_name=$(basename "$scenario_path")
    local output_file="$2"
    
    log_verbose "Simulating Claude execution for: $scenario_name"
    
    # For now, we'll create a mock response that analyzes the input and follows the prompt
    # In a real implementation, this would integrate with Claude API
    
    cat > "$output_file" << EOF
# Simulated Claude Response for $scenario_name

## Analysis of Input Files

EOF
    
    # Add analysis of input files
    echo "### Input Files Found:" >> "$output_file"
    find "$scenario_path/input" -type f | while read -r file; do
        local filename=$(basename "$file")
        local filesize=$(wc -l < "$file" 2>/dev/null || echo "0")
        echo "- **$filename**: $filesize lines" >> "$output_file"
    done
    
    echo "" >> "$output_file"
    echo "### Prompt Analysis:" >> "$output_file"
    
    # Extract key requirements from prompt
    if [ -f "$scenario_path/prompt.md" ]; then
        # Look for specific instructions or objectives
        grep -E "^##|^###|\*\*.*\*\*|Objetivo|Instrucciones|Requirements" "$scenario_path/prompt.md" | head -10 >> "$output_file"
    fi
    
    echo "" >> "$output_file"
    echo "### Simulated Response:" >> "$output_file"
    echo "" >> "$output_file"
    echo "This is a simulated response. In a real implementation, this would be" >> "$output_file"
    echo "the actual output from Claude Code CLI using the prompt and input files." >> "$output_file"
    echo "" >> "$output_file"
    echo "The response would contain:" >> "$output_file"
    echo "- Detailed analysis of the input code" >> "$output_file"
    echo "- Identification of issues and improvements" >> "$output_file"
    echo "- Refactored code following best practices" >> "$output_file"
    echo "- Explanations of changes made" >> "$output_file"
    echo "" >> "$output_file"
    echo "**Note**: This simulation is for testing the meta-testing framework." >> "$output_file"
    echo "Replace this with actual Claude API integration for production use." >> "$output_file"
    
    log_verbose "Claude simulation completed for: $scenario_name"
}

calculate_similarity() {
    local file1="$1"
    local file2="$2"
    local output_file="$3"
    
    # Use Python for more sophisticated comparison
    python3 - "$file1" "$file2" << 'PYTHON_EOF' > "$output_file"
import difflib
import re
import json
import sys

def normalize_text(text):
    """Normalize text for comparison"""
    # Remove extra whitespace
    text = re.sub(r'\s+', ' ', text)
    # Remove common markdown formatting variations
    text = re.sub(r'\*\*([^*]+)\*\*', r'\1', text)  # Bold
    text = re.sub(r'\*([^*]+)\*', r'\1', text)      # Italic
    text = re.sub(r'`([^`]+)`', r'\1', text)        # Code
    # Normalize line endings
    text = text.replace('\r\n', '\n').replace('\r', '\n')
    return text.strip().lower()

def extract_semantic_blocks(text):
    """Extract semantic blocks from markdown text"""
    blocks = []
    current_block = []
    
    for line in text.split('\n'):
        line = line.strip()
        if not line:
            if current_block:
                blocks.append(' '.join(current_block))
                current_block = []
        else:
            current_block.append(line)
    
    if current_block:
        blocks.append(' '.join(current_block))
    
    return blocks

def calculate_semantic_similarity(text1, text2):
    """Calculate semantic similarity between two texts"""
    # Normalize texts
    norm_text1 = normalize_text(text1)
    norm_text2 = normalize_text(text2)
    
    # Extract semantic blocks
    blocks1 = extract_semantic_blocks(norm_text1)
    blocks2 = extract_semantic_blocks(norm_text2)
    
    # Calculate similarity using SequenceMatcher
    matcher = difflib.SequenceMatcher(None, blocks1, blocks2)
    similarity = matcher.ratio()
    
    return similarity, matcher.get_opcodes()

def analyze_differences(opcodes, blocks1, blocks2):
    """Analyze differences between texts"""
    differences = {
        'added': [],
        'deleted': [],
        'modified': []
    }
    
    for op, i1, i2, j1, j2 in opcodes:
        if op == 'delete':
            differences['deleted'].extend(blocks1[i1:i2])
        elif op == 'insert':
            differences['added'].extend(blocks2[j1:j2])
        elif op == 'replace':
            differences['modified'].append({
                'original': blocks1[i1:i2],
                'replacement': blocks2[j1:j2]
            })
    
    return differences

try:
    file1 = sys.argv[1]
    file2 = sys.argv[2]
    
    with open(file1, 'r', encoding='utf-8') as f:
        text1 = f.read()
    
    with open(file2, 'r', encoding='utf-8') as f:
        text2 = f.read()
    
    similarity, opcodes = calculate_semantic_similarity(text1, text2)
    
    # Extract blocks for difference analysis
    blocks1 = extract_semantic_blocks(normalize_text(text1))
    blocks2 = extract_semantic_blocks(normalize_text(text2))
    
    differences = analyze_differences(opcodes, blocks1, blocks2)
    
    result = {
        'similarity_score': round(similarity, 4),
        'total_blocks_expected': len(blocks1),
        'total_blocks_actual': len(blocks2),
        'differences': differences
    }
    
    print(json.dumps(result, indent=2))
    
except Exception as e:
    print(json.dumps({
        'similarity_score': 0.0,
        'error': str(e),
        'total_blocks_expected': 0,
        'total_blocks_actual': 0,
        'differences': {'added': [], 'deleted': [], 'modified': []}
    }))
    sys.exit(1)

PYTHON_EOF
}

compare_outputs() {
    local actual_file="$1"
    local expected_file="$2"
    local scenario_name="$3"
    
    log_verbose "Comparing outputs for scenario: $scenario_name"
    
    # Calculate similarity
    local comparison_file="$TEMP_DIR/${scenario_name}_comparison.json"
    calculate_similarity "$expected_file" "$actual_file" "$comparison_file"
    
    if [ ! -f "$comparison_file" ]; then
        log_error "Failed to generate comparison for $scenario_name"
        return 1
    fi
    
    # Parse results
    local similarity_score=$(python3 -c "import json; data=json.load(open('$comparison_file')); print(data['similarity_score'])")
    local expected_blocks=$(python3 -c "import json; data=json.load(open('$comparison_file')); print(data['total_blocks_expected'])")
    local actual_blocks=$(python3 -c "import json; data=json.load(open('$comparison_file')); print(data['total_blocks_actual'])")
    
    # Check if similarity meets threshold
    local meets_threshold=$(python3 -c "print('true' if $similarity_score >= $SIMILARITY_THRESHOLD else 'false')")
    
    if [ "$meets_threshold" = "true" ]; then
        log_success "✅ $scenario_name: Similarity ${similarity_score} >= ${SIMILARITY_THRESHOLD} (PASS)"
        return 0
    else
        log_error "❌ $scenario_name: Similarity ${similarity_score} < ${SIMILARITY_THRESHOLD} (FAIL)"
        
        if [ "$VERBOSE" = true ]; then
            echo ""
            echo -e "${YELLOW}Detailed comparison for $scenario_name:${NC}"
            echo "Expected blocks: $expected_blocks"
            echo "Actual blocks: $actual_blocks"
            echo "Similarity score: $similarity_score"
            echo ""
            
            # Show some differences
            python3 - "$comparison_file" << 'PYTHON_DIFF_EOF'
import json
import sys
with open(sys.argv[1], 'r') as f:
    data = json.load(f)

differences = data['differences']
print("Key differences:")

if differences['deleted']:
    print("  Deleted content:")
    for item in differences['deleted'][:3]:  # Show first 3
        print(f"    - {item[:100]}...")

if differences['added']:
    print("  Added content:")
    for item in differences['added'][:3]:  # Show first 3
        print(f"    + {item[:100]}...")

if differences['modified']:
    print("  Modified content:")
    for item in differences['modified'][:2]:  # Show first 2
        print(f"    ~ Original: {str(item['original'])[:100]}...")
        print(f"    ~ New: {str(item['replacement'])[:100]}...")
PYTHON_DIFF_EOF
            echo ""
        fi
        
        return 1
    fi
}

run_scenario_test() {
    local scenario_path="$1"
    local scenario_name=$(basename "$scenario_path")
    
    log_test "Running test scenario: $scenario_name"
    
    # Validate scenario structure
    if ! validate_scenario "$scenario_path"; then
        return 1
    fi
    
    # Simulate Claude execution
    local actual_output="$TEMP_DIR/${scenario_name}_actual.md"
    simulate_claude_execution "$scenario_path" "$actual_output"
    
    # Compare with golden master
    local expected_output="$scenario_path/golden-master.md"
    if compare_outputs "$actual_output" "$expected_output" "$scenario_name"; then
        return 0
    else
        return 1
    fi
}

run_all_scenarios() {
    log_info "Running all test scenarios..."
    
    local total_scenarios=0
    local passed_scenarios=0
    local failed_scenarios=0
    local failed_scenario_names=()
    
    for scenario_dir in "$SCENARIOS_DIR"/*; do
        if [ -d "$scenario_dir" ]; then
            total_scenarios=$((total_scenarios + 1))
            
            if run_scenario_test "$scenario_dir"; then
                passed_scenarios=$((passed_scenarios + 1))
            else
                failed_scenarios=$((failed_scenarios + 1))
                failed_scenario_names+=($(basename "$scenario_dir"))
            fi
            
            echo ""
        fi
    done
    
    # Print summary
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                                Test Summary                                   ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo "Total scenarios: $total_scenarios"
    echo -e "Passed: ${GREEN}$passed_scenarios${NC}"
    echo -e "Failed: ${RED}$failed_scenarios${NC}"
    
    if [ $failed_scenarios -gt 0 ]; then
        echo ""
        echo -e "${RED}Failed scenarios:${NC}"
        for scenario in "${failed_scenario_names[@]}"; do
            echo "  • $scenario"
        done
    fi
    
    echo ""
    
    if [ $failed_scenarios -eq 0 ]; then
        log_success "All tests passed! 🎉"
        return 0
    else
        log_error "Some tests failed. Please review the output above."
        return 1
    fi
}

run_specific_scenario() {
    local scenario_name="$1"
    local scenario_path="$SCENARIOS_DIR/$scenario_name"
    
    if [ ! -d "$scenario_path" ]; then
        log_error "Scenario '$scenario_name' not found in $SCENARIOS_DIR"
        log_info "Available scenarios:"
        list_scenarios
        return 1
    fi
    
    log_info "Running specific scenario: $scenario_name"
    echo ""
    
    if run_scenario_test "$scenario_path"; then
        echo ""
        log_success "Test passed! ✅"
        return 0
    else
        echo ""
        log_error "Test failed! ❌"
        return 1
    fi
}

cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
        log_verbose "Cleaned up temporary directory: $TEMP_DIR"
    fi
}

# Main execution
main() {
    local scenario_name=""
    local dry_run=false
    local list_only=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                print_usage
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -t|--threshold)
                SIMILARITY_THRESHOLD="$2"
                shift 2
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            --list)
                list_only=true
                shift
                ;;
            -*)
                log_error "Unknown option: $1"
                print_usage
                exit 2
                ;;
            *)
                scenario_name="$1"
                shift
                ;;
        esac
    done
    
    print_header
    
    if [ "$list_only" = true ]; then
        list_scenarios
        exit 0
    fi
    
    if [ "$dry_run" = true ]; then
        log_info "Dry run mode - showing what would be tested"
        if [ -n "$scenario_name" ]; then
            echo "Would test scenario: $scenario_name"
        else
            echo "Would test all scenarios:"
            list_scenarios
        fi
        exit 0
    fi
    
    # Set up cleanup trap
    trap cleanup EXIT
    
    # Run prerequisite checks
    check_prerequisites
    
    # Run tests
    local exit_code=0
    if [ -n "$scenario_name" ]; then
        run_specific_scenario "$scenario_name" || exit_code=1
    else
        run_all_scenarios || exit_code=1
    fi
    
    exit $exit_code
}

# Run main function with all arguments
main "$@"