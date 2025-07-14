#!/bin/bash

# Detect Project Script
# Script para detectar el tipo de proyecto y tecnologías utilizadas

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CLAUDE_DIR=".claude"
OUTPUT_FILE="$CLAUDE_DIR/project-detection.json"
QUIET=false

# Functions
log_info() {
    if [ "$QUIET" = false ]; then
        echo -e "${BLUE}[INFO]${NC} $1"
    fi
}

log_success() {
    if [ "$QUIET" = false ]; then
        echo -e "${GREEN}[SUCCESS]${NC} $1"
    fi
}

log_warning() {
    if [ "$QUIET" = false ]; then
        echo -e "${YELLOW}[WARNING]${NC} $1"
    fi
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

print_header() {
    if [ "$QUIET" = false ]; then
        echo -e "${BLUE}"
        echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
        echo "║                       Claude Project Detection                               ║"
        echo "║                  Analyze your project structure and setup                   ║"
        echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
        echo -e "${NC}"
    fi
}

# Project detection functions
detect_nodejs() {
    local confidence=0
    local indicators=()
    local package_info="{}"
    
    if [ -f "package.json" ]; then
        confidence=$((confidence + 40))
        indicators+=("package.json")
        
        # Extract package info if jq is available
        if command -v jq > /dev/null 2>&1; then
            package_info=$(jq '{name: .name, version: .version, description: .description, main: .main, scripts: .scripts, dependencies: (.dependencies // {} | keys), devDependencies: (.devDependencies // {} | keys)}' package.json 2>/dev/null || echo "{}")
        fi
    fi
    
    if [ -f "package-lock.json" ]; then
        confidence=$((confidence + 20))
        indicators+=("package-lock.json")
    fi
    
    if [ -f "yarn.lock" ]; then
        confidence=$((confidence + 20))
        indicators+=("yarn.lock")
    fi
    
    if [ -f "pnpm-lock.yaml" ]; then
        confidence=$((confidence + 20))
        indicators+=("pnpm-lock.yaml")
    fi
    
    if [ -d "node_modules" ]; then
        confidence=$((confidence + 10))
        indicators+=("node_modules/")
    fi
    
    if [ -f ".nvmrc" ]; then
        confidence=$((confidence + 5))
        indicators+=(".nvmrc")
    fi
    
    echo "{\"type\": \"nodejs\", \"confidence\": $confidence, \"indicators\": $(printf '%s\n' "${indicators[@]}" | jq -R . | jq -s .), \"package_info\": $package_info}"
}

detect_python() {
    local confidence=0
    local indicators=()
    local python_version=""
    local package_manager=""
    
    if [ -f "requirements.txt" ]; then
        confidence=$((confidence + 30))
        indicators+=("requirements.txt")
        package_manager="pip"
    fi
    
    if [ -f "setup.py" ]; then
        confidence=$((confidence + 25))
        indicators+=("setup.py")
    fi
    
    if [ -f "pyproject.toml" ]; then
        confidence=$((confidence + 25))
        indicators+=("pyproject.toml")
    fi
    
    if [ -f "Pipfile" ]; then
        confidence=$((confidence + 20))
        indicators+=("Pipfile")
        package_manager="pipenv"
    fi
    
    if [ -f "poetry.lock" ]; then
        confidence=$((confidence + 20))
        indicators+=("poetry.lock")
        package_manager="poetry"
    fi
    
    if [ -f "conda.yaml" ] || [ -f "environment.yml" ]; then
        confidence=$((confidence + 15))
        indicators+=("conda environment")
        package_manager="conda"
    fi
    
    if [ -f ".python-version" ]; then
        confidence=$((confidence + 10))
        indicators+=(".python-version")
        python_version=$(cat ".python-version" 2>/dev/null || echo "")
    fi
    
    if [ -d "venv" ] || [ -d ".venv" ]; then
        confidence=$((confidence + 10))
        indicators+=("virtual environment")
    fi
    
    # Check for Python files
    if find . -name "*.py" -type f | head -1 > /dev/null 2>&1; then
        confidence=$((confidence + 5))
        indicators+=("Python files")
    fi
    
    echo "{\"type\": \"python\", \"confidence\": $confidence, \"indicators\": $(printf '%s\n' "${indicators[@]}" | jq -R . | jq -s .), \"package_manager\": \"$package_manager\", \"python_version\": \"$python_version\"}"
}

detect_rust() {
    local confidence=0
    local indicators=()
    local cargo_info="{}"
    
    if [ -f "Cargo.toml" ]; then
        confidence=$((confidence + 50))
        indicators+=("Cargo.toml")
        
        # Extract basic cargo info
        if command -v grep > /dev/null 2>&1; then
            local name=$(grep "^name" Cargo.toml | head -1 | sed 's/name = "\(.*\)"/\1/' 2>/dev/null || echo "")
            local version=$(grep "^version" Cargo.toml | head -1 | sed 's/version = "\(.*\)"/\1/' 2>/dev/null || echo "")
            cargo_info="{\"name\": \"$name\", \"version\": \"$version\"}"
        fi
    fi
    
    if [ -f "Cargo.lock" ]; then
        confidence=$((confidence + 20))
        indicators+=("Cargo.lock")
    fi
    
    if [ -d "src" ] && [ -f "src/main.rs" ]; then
        confidence=$((confidence + 15))
        indicators+=("src/main.rs")
    fi
    
    if [ -d "src" ] && [ -f "src/lib.rs" ]; then
        confidence=$((confidence + 15))
        indicators+=("src/lib.rs")
    fi
    
    if [ -d "target" ]; then
        confidence=$((confidence + 10))
        indicators+=("target/")
    fi
    
    # Check for Rust files
    if find . -name "*.rs" -type f | head -1 > /dev/null 2>&1; then
        confidence=$((confidence + 5))
        indicators+=("Rust files")
    fi
    
    echo "{\"type\": \"rust\", \"confidence\": $confidence, \"indicators\": $(printf '%s\n' "${indicators[@]}" | jq -R . | jq -s .), \"cargo_info\": $cargo_info}"
}

detect_go() {
    local confidence=0
    local indicators=()
    local module_name=""
    
    if [ -f "go.mod" ]; then
        confidence=$((confidence + 50))
        indicators+=("go.mod")
        module_name=$(grep "^module" go.mod | head -1 | awk '{print $2}' 2>/dev/null || echo "")
    fi
    
    if [ -f "go.sum" ]; then
        confidence=$((confidence + 20))
        indicators+=("go.sum")
    fi
    
    if [ -f "main.go" ]; then
        confidence=$((confidence + 20))
        indicators+=("main.go")
    fi
    
    if [ -d "vendor" ]; then
        confidence=$((confidence + 10))
        indicators+=("vendor/")
    fi
    
    # Check for Go files
    if find . -name "*.go" -type f | head -1 > /dev/null 2>&1; then
        confidence=$((confidence + 10))
        indicators+=("Go files")
    fi
    
    echo "{\"type\": \"go\", \"confidence\": $confidence, \"indicators\": $(printf '%s\n' "${indicators[@]}" | jq -R . | jq -s .), \"module_name\": \"$module_name\"}"
}

detect_java() {
    local confidence=0
    local indicators=()
    local build_tool=""
    
    if [ -f "pom.xml" ]; then
        confidence=$((confidence + 40))
        indicators+=("pom.xml")
        build_tool="maven"
    fi
    
    if [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
        confidence=$((confidence + 40))
        indicators+=("build.gradle")
        build_tool="gradle"
    fi
    
    if [ -f "gradlew" ]; then
        confidence=$((confidence + 10))
        indicators+=("gradlew")
    fi
    
    if [ -d "src/main/java" ]; then
        confidence=$((confidence + 20))
        indicators+=("src/main/java")
    fi
    
    if [ -d "target" ]; then
        confidence=$((confidence + 10))
        indicators+=("target/")
    fi
    
    if [ -d "build" ]; then
        confidence=$((confidence + 10))
        indicators+=("build/")
    fi
    
    # Check for Java files
    if find . -name "*.java" -type f | head -1 > /dev/null 2>&1; then
        confidence=$((confidence + 10))
        indicators+=("Java files")
    fi
    
    echo "{\"type\": \"java\", \"confidence\": $confidence, \"indicators\": $(printf '%s\n' "${indicators[@]}" | jq -R . | jq -s .), \"build_tool\": \"$build_tool\"}"
}

detect_php() {
    local confidence=0
    local indicators=()
    local composer_info="{}"
    
    if [ -f "composer.json" ]; then
        confidence=$((confidence + 40))
        indicators+=("composer.json")
        
        if command -v jq > /dev/null 2>&1; then
            composer_info=$(jq '{name: .name, version: .version, description: .description, require: (.require // {} | keys), "require-dev": (."require-dev" // {} | keys)}' composer.json 2>/dev/null || echo "{}")
        fi
    fi
    
    if [ -f "composer.lock" ]; then
        confidence=$((confidence + 20))
        indicators+=("composer.lock")
    fi
    
    if [ -f "index.php" ]; then
        confidence=$((confidence + 20))
        indicators+=("index.php")
    fi
    
    if [ -d "vendor" ]; then
        confidence=$((confidence + 10))
        indicators+=("vendor/")
    fi
    
    # Check for PHP files
    if find . -name "*.php" -type f | head -1 > /dev/null 2>&1; then
        confidence=$((confidence + 10))
        indicators+=("PHP files")
    fi
    
    echo "{\"type\": \"php\", \"confidence\": $confidence, \"indicators\": $(printf '%s\n' "${indicators[@]}" | jq -R . | jq -s .), \"composer_info\": $composer_info}"
}

detect_ruby() {
    local confidence=0
    local indicators=()
    local ruby_version=""
    
    if [ -f "Gemfile" ]; then
        confidence=$((confidence + 40))
        indicators+=("Gemfile")
    fi
    
    if [ -f "Gemfile.lock" ]; then
        confidence=$((confidence + 20))
        indicators+=("Gemfile.lock")
    fi
    
    if [ -f ".ruby-version" ]; then
        confidence=$((confidence + 15))
        indicators+=(".ruby-version")
        ruby_version=$(cat ".ruby-version" 2>/dev/null || echo "")
    fi
    
    if [ -f "Rakefile" ]; then
        confidence=$((confidence + 10))
        indicators+=("Rakefile")
    fi
    
    if [ -f "config.ru" ]; then
        confidence=$((confidence + 10))
        indicators+=("config.ru")
    fi
    
    # Check for Ruby files
    if find . -name "*.rb" -type f | head -1 > /dev/null 2>&1; then
        confidence=$((confidence + 10))
        indicators+=("Ruby files")
    fi
    
    echo "{\"type\": \"ruby\", \"confidence\": $confidence, \"indicators\": $(printf '%s\n' "${indicators[@]}" | jq -R . | jq -s .), \"ruby_version\": \"$ruby_version\"}"
}

detect_dart_flutter() {
    local confidence=0
    local indicators=()
    local is_flutter=false
    
    if [ -f "pubspec.yaml" ]; then
        confidence=$((confidence + 40))
        indicators+=("pubspec.yaml")
        
        # Check if it's a Flutter project
        if grep -q "flutter:" pubspec.yaml 2>/dev/null; then
            is_flutter=true
            confidence=$((confidence + 20))
            indicators+=("Flutter dependencies")
        fi
    fi
    
    if [ -f "pubspec.lock" ]; then
        confidence=$((confidence + 20))
        indicators+=("pubspec.lock")
    fi
    
    if [ -d "lib" ]; then
        confidence=$((confidence + 15))
        indicators+=("lib/")
    fi
    
    if [ -d "android" ] && [ -d "ios" ]; then
        confidence=$((confidence + 15))
        indicators+=("mobile platforms")
        is_flutter=true
    fi
    
    # Check for Dart files
    if find . -name "*.dart" -type f | head -1 > /dev/null 2>&1; then
        confidence=$((confidence + 10))
        indicators+=("Dart files")
    fi
    
    local project_type="dart"
    if [ "$is_flutter" = true ]; then
        project_type="flutter"
    fi
    
    echo "{\"type\": \"$project_type\", \"confidence\": $confidence, \"indicators\": $(printf '%s\n' "${indicators[@]}" | jq -R . | jq -s .), \"is_flutter\": $is_flutter}"
}

detect_csharp() {
    local confidence=0
    local indicators=()
    local framework=""
    
    if find . -name "*.csproj" -type f | head -1 > /dev/null 2>&1; then
        confidence=$((confidence + 40))
        indicators+=("*.csproj")
    fi
    
    if find . -name "*.sln" -type f | head -1 > /dev/null 2>&1; then
        confidence=$((confidence + 30))
        indicators+=("*.sln")
    fi
    
    if [ -f "global.json" ]; then
        confidence=$((confidence + 20))
        indicators+=("global.json")
    fi
    
    if [ -d "bin" ] && [ -d "obj" ]; then
        confidence=$((confidence + 10))
        indicators+=("bin/ and obj/")
    fi
    
    # Check for C# files
    if find . -name "*.cs" -type f | head -1 > /dev/null 2>&1; then
        confidence=$((confidence + 10))
        indicators+=("C# files")
    fi
    
    # Detect framework
    if grep -r "Microsoft.AspNetCore" . --include="*.csproj" > /dev/null 2>&1; then
        framework="ASP.NET Core"
    elif grep -r "Microsoft.NET.Sdk.Web" . --include="*.csproj" > /dev/null 2>&1; then
        framework="ASP.NET Core"
    elif grep -r "netcoreapp" . --include="*.csproj" > /dev/null 2>&1; then
        framework=".NET Core"
    elif grep -r "net[0-9]" . --include="*.csproj" > /dev/null 2>&1; then
        framework=".NET"
    fi
    
    echo "{\"type\": \"csharp\", \"confidence\": $confidence, \"indicators\": $(printf '%s\n' "${indicators[@]}" | jq -R . | jq -s .), \"framework\": \"$framework\"}"
}

detect_cpp() {
    local confidence=0
    local indicators=()
    local build_system=""
    
    if [ -f "CMakeLists.txt" ]; then
        confidence=$((confidence + 30))
        indicators+=("CMakeLists.txt")
        build_system="cmake"
    fi
    
    if [ -f "Makefile" ]; then
        confidence=$((confidence + 25))
        indicators+=("Makefile")
        build_system="make"
    fi
    
    if [ -f "conanfile.txt" ] || [ -f "conanfile.py" ]; then
        confidence=$((confidence + 20))
        indicators+=("conanfile")
    fi
    
    if [ -f "vcpkg.json" ]; then
        confidence=$((confidence + 20))
        indicators+=("vcpkg.json")
    fi
    
    # Check for C++ files
    if find . \( -name "*.cpp" -o -name "*.cc" -o -name "*.cxx" -o -name "*.c++" \) -type f | head -1 > /dev/null 2>&1; then
        confidence=$((confidence + 15))
        indicators+=("C++ files")
    fi
    
    # Check for C files
    if find . -name "*.c" -type f | head -1 > /dev/null 2>&1; then
        confidence=$((confidence + 10))
        indicators+=("C files")
    fi
    
    # Check for header files
    if find . \( -name "*.h" -o -name "*.hpp" -o -name "*.hxx" \) -type f | head -1 > /dev/null 2>&1; then
        confidence=$((confidence + 10))
        indicators+=("Header files")
    fi
    
    echo "{\"type\": \"cpp\", \"confidence\": $confidence, \"indicators\": $(printf '%s\n' "${indicators[@]}" | jq -R . | jq -s .), \"build_system\": \"$build_system\"}"
}

detect_web_frontend() {
    local confidence=0
    local indicators=()
    local frameworks=()
    
    # Check for web files
    if find . -name "*.html" -type f | head -1 > /dev/null 2>&1; then
        confidence=$((confidence + 10))
        indicators+=("HTML files")
    fi
    
    if find . -name "*.css" -type f | head -1 > /dev/null 2>&1; then
        confidence=$((confidence + 10))
        indicators+=("CSS files")
    fi
    
    if find . -name "*.js" -type f | head -1 > /dev/null 2>&1; then
        confidence=$((confidence + 10))
        indicators+=("JavaScript files")
    fi
    
    if find . -name "*.ts" -type f | head -1 > /dev/null 2>&1; then
        confidence=$((confidence + 10))
        indicators+=("TypeScript files")
    fi
    
    # Check for framework-specific files
    if [ -f "angular.json" ]; then
        confidence=$((confidence + 30))
        indicators+=("angular.json")
        frameworks+=("Angular")
    fi
    
    if [ -f "next.config.js" ]; then
        confidence=$((confidence + 30))
        indicators+=("next.config.js")
        frameworks+=("Next.js")
    fi
    
    if [ -f "nuxt.config.js" ] || [ -f "nuxt.config.ts" ]; then
        confidence=$((confidence + 30))
        indicators+=("nuxt.config.js")
        frameworks+=("Nuxt.js")
    fi
    
    if [ -f "vue.config.js" ]; then
        confidence=$((confidence + 30))
        indicators+=("vue.config.js")
        frameworks+=("Vue.js")
    fi
    
    if [ -f "svelte.config.js" ]; then
        confidence=$((confidence + 30))
        indicators+=("svelte.config.js")
        frameworks+=("Svelte")
    fi
    
    # Check for build tools
    if [ -f "webpack.config.js" ]; then
        confidence=$((confidence + 15))
        indicators+=("webpack.config.js")
    fi
    
    if [ -f "vite.config.js" ] || [ -f "vite.config.ts" ]; then
        confidence=$((confidence + 15))
        indicators+=("vite.config.js")
    fi
    
    if [ -f "rollup.config.js" ]; then
        confidence=$((confidence + 15))
        indicators+=("rollup.config.js")
    fi
    
    echo "{\"type\": \"web-frontend\", \"confidence\": $confidence, \"indicators\": $(printf '%s\n' "${indicators[@]}" | jq -R . | jq -s .), \"frameworks\": $(printf '%s\n' "${frameworks[@]}" | jq -R . | jq -s .)}"
}

detect_mobile() {
    local confidence=0
    local indicators=()
    local platforms=()
    
    # iOS detection
    if [ -f "*.xcodeproj" ] || [ -f "*.xcworkspace" ]; then
        confidence=$((confidence + 40))
        indicators+=("Xcode project")
        platforms+=("iOS")
    fi
    
    if [ -f "Podfile" ]; then
        confidence=$((confidence + 30))
        indicators+=("Podfile")
        platforms+=("iOS")
    fi
    
    # Android detection
    if [ -f "build.gradle" ] && [ -d "app" ]; then
        confidence=$((confidence + 35))
        indicators+=("Android Gradle")
        platforms+=("Android")
    fi
    
    if [ -f "settings.gradle" ]; then
        confidence=$((confidence + 20))
        indicators+=("settings.gradle")
        platforms+=("Android")
    fi
    
    # React Native detection
    if [ -f "metro.config.js" ]; then
        confidence=$((confidence + 30))
        indicators+=("metro.config.js")
        platforms+=("React Native")
    fi
    
    if [ -d "android" ] && [ -d "ios" ] && [ -f "package.json" ]; then
        confidence=$((confidence + 35))
        indicators+=("React Native structure")
        platforms+=("React Native")
    fi
    
    # Xamarin detection
    if find . -name "*.xamarin" -type f | head -1 > /dev/null 2>&1; then
        confidence=$((confidence + 30))
        indicators+=("Xamarin files")
        platforms+=("Xamarin")
    fi
    
    echo "{\"type\": \"mobile\", \"confidence\": $confidence, \"indicators\": $(printf '%s\n' "${indicators[@]}" | jq -R . | jq -s .), \"platforms\": $(printf '%s\n' "${platforms[@]}" | jq -R . | jq -s .)}"
}

detect_docker() {
    local confidence=0
    local indicators=()
    
    if [ -f "Dockerfile" ]; then
        confidence=$((confidence + 30))
        indicators+=("Dockerfile")
    fi
    
    if [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ]; then
        confidence=$((confidence + 25))
        indicators+=("docker-compose.yml")
    fi
    
    if [ -f ".dockerignore" ]; then
        confidence=$((confidence + 10))
        indicators+=(".dockerignore")
    fi
    
    if [ -d ".devcontainer" ]; then
        confidence=$((confidence + 20))
        indicators+=(".devcontainer")
    fi
    
    echo "{\"type\": \"docker\", \"confidence\": $confidence, \"indicators\": $(printf '%s\n' "${indicators[@]}" | jq -R . | jq -s .)}"
}

detect_kubernetes() {
    local confidence=0
    local indicators=()
    
    if [ -d "k8s" ] || [ -d "kubernetes" ]; then
        confidence=$((confidence + 30))
        indicators+=("kubernetes directory")
    fi
    
    if find . -name "*.yaml" -o -name "*.yml" | xargs grep -l "apiVersion:" > /dev/null 2>&1; then
        confidence=$((confidence + 25))
        indicators+=("Kubernetes manifests")
    fi
    
    if [ -f "Chart.yaml" ]; then
        confidence=$((confidence + 30))
        indicators+=("Helm Chart")
    fi
    
    if [ -f "kustomization.yaml" ]; then
        confidence=$((confidence + 25))
        indicators+=("Kustomize")
    fi
    
    echo "{\"type\": \"kubernetes\", \"confidence\": $confidence, \"indicators\": $(printf '%s\n' "${indicators[@]}" | jq -R . | jq -s .)}"
}

detect_database() {
    local confidence=0
    local indicators=()
    local databases=()
    
    # SQL migrations
    if [ -d "migrations" ]; then
        confidence=$((confidence + 20))
        indicators+=("migrations/")
    fi
    
    # Database config files
    if grep -r "database\|db_" . --include="*.yaml" --include="*.yml" --include="*.json" --include="*.toml" > /dev/null 2>&1; then
        confidence=$((confidence + 15))
        indicators+=("Database config")
    fi
    
    # Specific database indicators
    if grep -r "postgresql\|postgres" . --include="*.yaml" --include="*.yml" --include="*.json" --include="*.env" > /dev/null 2>&1; then
        databases+=("PostgreSQL")
    fi
    
    if grep -r "mysql\|mariadb" . --include="*.yaml" --include="*.yml" --include="*.json" --include="*.env" > /dev/null 2>&1; then
        databases+=("MySQL")
    fi
    
    if grep -r "mongodb\|mongo" . --include="*.yaml" --include="*.yml" --include="*.json" --include="*.env" > /dev/null 2>&1; then
        databases+=("MongoDB")
    fi
    
    if grep -r "redis" . --include="*.yaml" --include="*.yml" --include="*.json" --include="*.env" > /dev/null 2>&1; then
        databases+=("Redis")
    fi
    
    if [ ${#databases[@]} -gt 0 ]; then
        confidence=$((confidence + 10))
    fi
    
    echo "{\"type\": \"database\", \"confidence\": $confidence, \"indicators\": $(printf '%s\n' "${indicators[@]}" | jq -R . | jq -s .), \"databases\": $(printf '%s\n' "${databases[@]}" | jq -R . | jq -s .)}"
}

analyze_git_repository() {
    local git_info="{}"
    
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local remote_url=$(git remote get-url origin 2>/dev/null || echo "")
        local current_branch=$(git branch --show-current 2>/dev/null || echo "")
        local commit_count=$(git rev-list --count HEAD 2>/dev/null || echo "0")
        local contributors=$(git shortlog -sn --all | wc -l 2>/dev/null || echo "0")
        local last_commit=$(git log -1 --format="%ci" 2>/dev/null || echo "")
        
        git_info=$(cat <<EOF
{
    "remote_url": "$remote_url",
    "current_branch": "$current_branch",
    "commit_count": $commit_count,
    "contributors": $contributors,
    "last_commit": "$last_commit"
}
EOF
)
    fi
    
    echo "$git_info"
}

analyze_file_structure() {
    local total_files=$(find . -type f | wc -l)
    local total_dirs=$(find . -type d | wc -l)
    local largest_file=$(find . -type f -exec ls -la {} \; | awk '{print $5 " " $9}' | sort -n | tail -1 || echo "0 ")
    
    # Get file extensions
    local extensions=$(find . -type f -name "*.*" | sed 's/.*\.//' | sort | uniq -c | sort -nr | head -10)
    
    # Convert to JSON
    local extensions_json="[]"
    if [ -n "$extensions" ]; then
        extensions_json=$(echo "$extensions" | awk '{print "{\"extension\": \"" $2 "\", \"count\": " $1 "}"}' | jq -s .)
    fi
    
    cat <<EOF
{
    "total_files": $total_files,
    "total_directories": $total_dirs,
    "largest_file": "$largest_file",
    "extensions": $extensions_json
}
EOF
}

get_project_metadata() {
    local project_name=$(basename "$(pwd)")
    local project_path=$(pwd)
    local size=$(du -sh . 2>/dev/null | cut -f1 || echo "unknown")
    
    cat <<EOF
{
    "name": "$project_name",
    "path": "$project_path",
    "size": "$size",
    "analyzed_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
}

run_detection() {
    log_info "Starting project detection..."
    
    # Run all detections
    local detections=()
    detections+=("$(detect_nodejs)")
    detections+=("$(detect_python)")
    detections+=("$(detect_rust)")
    detections+=("$(detect_go)")
    detections+=("$(detect_java)")
    detections+=("$(detect_php)")
    detections+=("$(detect_ruby)")
    detections+=("$(detect_dart_flutter)")
    detections+=("$(detect_csharp)")
    detections+=("$(detect_cpp)")
    detections+=("$(detect_web_frontend)")
    detections+=("$(detect_mobile)")
    detections+=("$(detect_docker)")
    detections+=("$(detect_kubernetes)")
    detections+=("$(detect_database)")
    
    # Filter out low-confidence detections and sort by confidence
    local filtered_detections=()
    for detection in "${detections[@]}"; do
        local confidence=$(echo "$detection" | jq -r '.confidence')
        if [ "$confidence" -gt 10 ]; then
            filtered_detections+=("$detection")
        fi
    done
    
    # Sort by confidence
    local sorted_detections=$(printf '%s\n' "${filtered_detections[@]}" | jq -s 'sort_by(.confidence) | reverse')
    
    # Get additional analysis
    local git_info=$(analyze_git_repository)
    local file_structure=$(analyze_file_structure)
    local project_metadata=$(get_project_metadata)
    
    # Create final result
    local result=$(cat <<EOF
{
    "project_metadata": $project_metadata,
    "detections": $sorted_detections,
    "git_info": $git_info,
    "file_structure": $file_structure
}
EOF
)
    
    echo "$result"
}

save_results() {
    local results="$1"
    
    # Create .claude directory if it doesn't exist
    mkdir -p "$CLAUDE_DIR"
    
    # Save results
    echo "$results" > "$OUTPUT_FILE"
    
    log_success "Results saved to $OUTPUT_FILE"
}

display_results() {
    local results="$1"
    
    if [ "$QUIET" = true ]; then
        return
    fi
    
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                           Detection Results                                   ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Project metadata
    local project_name=$(echo "$results" | jq -r '.project_metadata.name')
    local project_size=$(echo "$results" | jq -r '.project_metadata.size')
    local total_files=$(echo "$results" | jq -r '.file_structure.total_files')
    
    echo -e "${BLUE}Project Overview:${NC}"
    echo "📁 Name: $project_name"
    echo "📏 Size: $project_size"
    echo "📄 Files: $total_files"
    echo ""
    
    # Top detections
    echo -e "${BLUE}Detected Technologies:${NC}"
    echo "$results" | jq -r '.detections[] | select(.confidence > 20) | "🔍 \(.type) (confidence: \(.confidence)%)"'
    echo ""
    
    # Git information
    local git_branch=$(echo "$results" | jq -r '.git_info.current_branch // "unknown"')
    local git_commits=$(echo "$results" | jq -r '.git_info.commit_count // 0')
    
    if [ "$git_branch" != "unknown" ]; then
        echo -e "${BLUE}Git Information:${NC}"
        echo "🌿 Branch: $git_branch"
        echo "📦 Commits: $git_commits"
        echo ""
    fi
    
    # File extensions
    echo -e "${BLUE}Top File Extensions:${NC}"
    echo "$results" | jq -r '.file_structure.extensions[:5][] | "📄 .\(.extension): \(.count) files"'
    echo ""
    
    # Recommendations
    echo -e "${BLUE}Recommendations:${NC}"
    local primary_type=$(echo "$results" | jq -r '.detections[0].type // "unknown"')
    
    case $primary_type in
        "nodejs")
            echo "💡 Consider setting up ESLint and Prettier for code quality"
            echo "💡 Use npm scripts for common tasks"
            echo "💡 Set up GitHub Actions for CI/CD"
            ;;
        "python")
            echo "💡 Consider using virtual environments"
            echo "💡 Set up black and flake8 for code formatting"
            echo "💡 Use pytest for testing"
            ;;
        "rust")
            echo "💡 Use cargo fmt for code formatting"
            echo "💡 Set up cargo clippy for linting"
            echo "💡 Consider using cargo-watch for development"
            ;;
        "go")
            echo "💡 Use go fmt for code formatting"
            echo "💡 Set up golint for linting"
            echo "💡 Consider using go modules"
            ;;
        *)
            echo "💡 Set up appropriate linting and formatting tools"
            echo "💡 Consider containerization with Docker"
            echo "💡 Set up CI/CD pipeline"
            ;;
    esac
    
    echo ""
    echo -e "${GREEN}Detection complete! Results saved to $OUTPUT_FILE${NC}"
}

# Main execution
main() {
    if [ "$QUIET" = false ]; then
        print_header
    fi
    
    # Run detection
    local results=$(run_detection)
    
    # Save and display results
    save_results "$results"
    display_results "$results"
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Claude Project Detection Script"
        echo ""
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  -h, --help     Show this help message"
        echo "  --quiet        Only output results, suppress info messages"
        echo "  --json         Output results as JSON"
        echo "  --summary      Show only summary information"
        echo ""
        echo "This script analyzes your project and detects technologies, frameworks, and tools."
        echo "Results are saved to .claude/project-detection.json"
        exit 0
        ;;
    --quiet)
        QUIET=true
        main
        ;;
    --json)
        QUIET=true
        results=$(run_detection)
        echo "$results"
        save_results "$results"
        ;;
    --summary)
        QUIET=true
        results=$(run_detection)
        primary_type=$(echo "$results" | jq -r '.detections[0].type // "unknown"')
        primary_confidence=$(echo "$results" | jq -r '.detections[0].confidence // 0')
        project_name=$(echo "$results" | jq -r '.project_metadata.name')
        
        echo "Project: $project_name"
        echo "Primary Type: $primary_type ($primary_confidence% confidence)"
        
        save_results "$results"
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