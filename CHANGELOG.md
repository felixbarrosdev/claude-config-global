# Changelog

All notable changes to Claude Config Global will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Database Schema Design Module** - Complete assistance module for database design
- `database-schema-design.md` prompt for scalable database schema generation
- `database-schema-design-usage.md` comprehensive usage documentation
- Meta-testing scenario for database schema design validation
- Comprehensive CONTRIBUTING.md with detailed contribution guidelines
- CODE_OF_CONDUCT.md based on Contributor Covenant
- GitHub issue templates for bug reports, feature requests, and new prompts
- Pull request template with comprehensive checklist
- GitHub labels configuration for better issue organization
- setup-github-labels.sh script for automated label setup
- Meta-testing requirement documentation for all prompt contributions

### Changed
- README.md updated with improved contribution section
- Enhanced documentation structure for better contributor experience

## [2.0.0] - 2024-01-15

### Added
- **Lite Installation Mode** - Simplified setup for new users and small projects
- **Meta-Testing Framework** - Comprehensive testing system for prompt quality
- **upgrade-to-full.sh** - Script to upgrade Lite installations to Full
- **run-meta-tests.sh** - Meta-testing engine with intelligent comparison
- Four new test scenarios covering all major prompts:
  - `generate-documentation-jsdoc` for documentation.md
  - `review-code-with-smells` for code-review.md  
  - `debug-async-error-js` for debugging.md
  - `analyze-system-architecture` for architecture-analysis.md
- GitHub Actions CI/CD for automated meta-testing

### Changed
- **setup-project.sh** enhanced with installation mode selection
- **README.md** updated with comprehensive documentation
- Installation process now supports gradual adoption

### Technical
- 100% prompt coverage in meta-testing (up from 20%)
- Intelligent semantic comparison for test validation
- Comprehensive golden masters for all prompt scenarios
- CI/CD integration for quality assurance

## [1.0.0] - 2024-01-14

### Added
- Initial release of Claude Config Global
- Core prompts: refactoring, code-review, debugging, documentation, architecture-analysis
- Universal contexts: code-quality, security-basics, development-patterns, documentation-standards
- Automated workflows: feature-development, bug-fixing, code-review
- Essential tools: setup-project.sh, update-config.sh, detect-project.sh
- Template system for project customization
- Multi-database support detection
- Cross-platform compatibility

### Features
- Universal configuration system for Claude Code
- Project type auto-detection
- Configurable templates
- Modular and extensible structure
- Comprehensive documentation