# Zondax Makefile Modules

This directory contains modular Makefile components that provide standardized development workflows across different technologies and environments.

## 📁 Module Overview

| Module | Purpose | Key Features |
|--------|---------|--------------|
| **Makefile.libs.mk** | Shell utilities | Color definitions for terminal output |
| **Makefile.help.mk** | Documentation | Auto-generated help system with categories |
| **Makefile.docker.mk** | Containerization | Multi-platform builds, remote BuildKit, bake support |
| **Makefile.golang.mk** | Go development | Build, test, lint, coverage, mod management |
| **Makefile.rust.mk** | Rust development | Cargo workflows, cross-compilation, security audit |
| **Makefile.node.mk** | Node.js/TypeScript | Multi-PM support (npm/yarn/pnpm/bun), smart script detection |
| **Makefile.yaml.mk** | YAML validation | Prettier formatting, syntax validation |
| **Makefile.infra.mk** | Infrastructure | Kubernetes manifest validation with kubeconform |
| **Makefile.macros.mk** | Utilities | Reusable macro functions |
| **Makefile.misc.mk** | Miscellaneous | Git cleanup and other utilities |

## 🚀 Quick Start

### Including Modules

Add modules to your project's `Makefile`:

```makefile
# Core modules (recommended for all projects)
-include .make/Makefile.libs.mk
-include .make/Makefile.help.mk
-include .make/Makefile.misc.mk

# Language-specific modules (choose based on your project)
-include .make/Makefile.golang.mk
-include .make/Makefile.rust.mk
-include .make/Makefile.node.mk

# Infrastructure modules (for containerized/K8s projects)
-include .make/Makefile.docker.mk
-include .make/Makefile.infra.mk
-include .make/Makefile.yaml.mk

# Local overrides (optional)
-include Makefile.local.mk
```

### Basic Commands

```bash
# Show all available targets
make help

# Language-specific workflows
make go-ci          # Go: format check, lint, test, security audit
make rust-ci        # Rust: format check, clippy, test, audit
make node-ci        # Node.js: format check, lint, type-check, test, audit

# Docker operations
make docker-build   # Build multi-platform images
make docker-publish # Build and push to registry

# Infrastructure validation
make infra-checks   # Validate Kubernetes manifests
make yaml-lint      # Format and validate YAML files
```

## 🔧 Configuration

### Environment Variables

Each module supports configuration through environment variables:

#### Docker Module
```bash
DOCKER_IMAGE_NAME=myorg/myapp
PLATFORMS=linux/amd64,linux/arm64
REMOTE_BUILD_KIT=tcp://buildkit.example.com:8372
```

#### Rust Module
```bash
RUST_TOOLCHAIN=stable
RUST_FEATURES=--all-features
COVERAGE_THRESHOLD=80
```

#### Node.js Module
```bash
PACKAGE_MANAGER=pnpm
NODE_VERSION=18
WORKSPACE_DIR=packages/frontend
```

#### Go Module
```bash
CMD_DIR=cmd
OUTPUT_DIR=bin
DEFAULT_APP_NAME=myapp
```

### Project-Specific Settings

Create `Makefile.settings.mk` in your project root:

```makefile
# Project configuration
DOCKER_IMAGE_NAME := myorg/myproject
RUST_FEATURES := --no-default-features --features=production
PACKAGE_MANAGER := bun
COVERAGE_THRESHOLD := 85

# Custom variables
PROJECT_NAME := My Project
VERSION := $(shell git describe --tags --always)
```

## 📋 Common Workflows

### Multi-Language Project

For projects using multiple languages:

```makefile
# Full CI pipeline
ci: go-ci rust-ci node-ci docker-build infra-checks

# Development workflow
dev: go-build rust-build node-dev

# Clean everything
clean: go-clean rust-clean node-clean docker-clean
```

### Container-First Development

```makefile
# Development in containers
dev-container: docker-build
	docker run -it --rm -v $(PWD):/workspace $(DOCKER_IMAGE_NAME):latest

# Multi-stage builds
build-frontend:
	$(MAKE) docker-build DOCKER_BUILD_TARGET=frontend

build-backend:
	$(MAKE) docker-build DOCKER_BUILD_TARGET=backend
```

### Release Pipeline

```makefile
# Complete release workflow
release: clean test build package publish

test: go-test rust-test node-test
build: go-build rust-build node-build
package: docker-build
publish: docker-publish
```

## 🔍 Module Details

### Docker Module (`Makefile.docker.mk`)

**Smart Build System**: Automatically detects `docker-bake.hcl` and switches between bake and legacy modes.

**Key Features**:
- Multi-platform builds (`linux/amd64`, `linux/arm64`)
- Remote BuildKit support for faster builds
- Automatic image tagging (git hash, branch, build date)
- Target-specific builds for multi-stage Dockerfiles

**Common Targets**:
```bash
make docker-info     # Show build configuration
make docker-targets  # List available build stages
make docker-load     # Build and load locally
make docker-publish  # Build and push to registry
```

### Rust Module (`Makefile.rust.mk`)

**Comprehensive Rust Workflow**: From development to production deployment.

**Key Features**:
- Cross-compilation support
- Coverage with threshold checking
- Security auditing with `cargo audit`
- Automatic tool installation

**Common Targets**:
```bash
make rust-all        # Full development workflow
make rust-coverage-check  # Verify coverage threshold
make rust-audit      # Security vulnerability scan
make rust-install-tools   # Install development tools
```

### Node.js Module (`Makefile.node.mk`)

**Multi-Package Manager Support**: Works with npm, yarn, pnpm, and bun.

**Key Features**:
- Smart script detection from `package.json`
- Frozen lockfile installs for CI
- Automatic package manager detection
- Development server management

**Common Targets**:
```bash
make node-info       # Show project information
make node-ci         # CI workflow with frozen dependencies
make node-dev        # Start development server
make node-add PACKAGE=lodash  # Add dependencies
```

### Go Module (`Makefile.golang.mk`)

**Enterprise Go Development**: Supports both single and multi-binary projects.

**Key Features**:
- Automatic binary discovery in `cmd/` directories
- Nested project structure support
- Coverage reporting with filtering
- Version management integration

**Common Targets**:
```bash
make go-list         # List all buildable binaries
make go-coverage     # Generate coverage reports
make go-mod-check    # Verify go.mod consistency
```

## 🛠 Advanced Usage

### Custom Targets

Extend modules with project-specific targets:

```makefile
# In your main Makefile
deploy: docker-publish
	kubectl set image deployment/myapp myapp=$(DOCKER_IMAGE_NAME):$(GIT_HASH)

integration-test: docker-build
	docker-compose -f test/docker-compose.yml up --abort-on-container-exit

benchmark: rust-build go-build
	./scripts/run-benchmarks.sh
```

### Conditional Module Loading

Load modules based on project structure:

```makefile
# Detect project languages
HAS_RUST := $(shell test -f Cargo.toml && echo "yes")
HAS_GO := $(shell test -f go.mod && echo "yes")
HAS_NODE := $(shell test -f package.json && echo "yes")

# Conditionally include modules
ifdef HAS_RUST
-include .make/Makefile.rust.mk
endif

ifdef HAS_GO
-include .make/Makefile.golang.mk
endif

ifdef HAS_NODE
-include .make/Makefile.node.mk
endif
```

### Environment-Specific Configuration

```makefile
# Environment detection
ENV ?= development

ifeq ($(ENV),production)
    RUST_FEATURES := --features=production --no-default-features
    DOCKER_BUILD_TARGET := production
    COVERAGE_THRESHOLD := 90
else
    RUST_FEATURES := --all-features
    DOCKER_BUILD_TARGET := development
    COVERAGE_THRESHOLD := 70
endif
```

## 🚨 Troubleshooting

### Common Issues

1. **"DO NOT EDIT" Files**: The `.make/*.mk` files are generated. Modify the source templates instead.

2. **Missing Tools**: Use the installation targets:
   ```bash
   make rust-install-tools
   make go-lint-install
   make infra-kubeconform-install
   ```

3. **Permission Issues**: For Docker builds requiring sudo:
   ```bash
   sudo make docker-build
   ```

4. **Package Manager Detection**: Override auto-detection:
   ```bash
   make node-install PACKAGE_MANAGER=bun
   ```

### Debug Mode

Enable verbose output for debugging:

```bash
make VERBOSE=1 rust-build
make DEBUG=1 docker-build
```

## 📚 Best Practices

1. **Module Organization**: Include only the modules you need
2. **Local Overrides**: Use `Makefile.local.mk` for temporary changes
3. **CI Integration**: Use the `*-ci` targets in your GitHub Actions
4. **Documentation**: Always run `make help` to see available targets
5. **Version Control**: Commit `Makefile.settings.mk` but not `Makefile.local.mk`

## 🤝 Contributing

When adding new modules:

1. Follow the existing naming convention (`Makefile.<topic>.mk`)
2. Include comprehensive help documentation
3. Add configuration variables with sensible defaults
4. Provide both individual and combined workflow targets
5. Include the "DO NOT EDIT" header for generated files

---

For more information, see the individual module files or run `make help` to explore available targets.