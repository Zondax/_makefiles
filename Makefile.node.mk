ifndef __MAKEFILE_NODE_MK__
__MAKEFILE_NODE_MK__ := 1

# Node.js configuration
NODE_VERSION ?= lts/*
PACKAGE_MANAGER ?= npm
PACKAGE_MANAGER_VERSION ?= latest

# Package manager commands - auto-detected or overridden
ifeq ($(PACKAGE_MANAGER),bun)
    PM := bun
    PM_RUN := bun run
    PM_INSTALL := bun install
    PM_ADD := bun add
    PM_REMOVE := bun remove
    LOCKFILE := bun.lockb
else ifeq ($(PACKAGE_MANAGER),yarn)
    PM := yarn
    PM_RUN := yarn run
    PM_INSTALL := yarn install
    PM_ADD := yarn add
    PM_REMOVE := yarn remove
    LOCKFILE := yarn.lock
else ifeq ($(PACKAGE_MANAGER),pnpm)
    PM := pnpm
    PM_RUN := pnpm run
    PM_INSTALL := pnpm install
    PM_ADD := pnpm add
    PM_REMOVE := pnpm remove
    LOCKFILE := pnpm-lock.yaml
else
    PM := npm
    PM_RUN := npm run
    PM_INSTALL := npm install
    PM_ADD := npm install
    PM_REMOVE := npm uninstall
    LOCKFILE := package-lock.json
endif

# Project configuration
WORKSPACE_DIR ?= .
BUILD_DIR ?= dist
COVERAGE_DIR ?= coverage
DOCS_DIR ?= docs

# Script detection - check if scripts exist in package.json
HAS_BUILD := $(shell test -f package.json && jq -r '.scripts.build // empty' package.json 2>/dev/null)
HAS_TEST := $(shell test -f package.json && jq -r '.scripts.test // empty' package.json 2>/dev/null)
HAS_LINT := $(shell test -f package.json && jq -r '.scripts.lint // empty' package.json 2>/dev/null)
HAS_FORMAT := $(shell test -f package.json && jq -r '.scripts.format // empty' package.json 2>/dev/null)
HAS_FORMAT_CHECK := $(shell test -f package.json && jq -r '.scripts["format:check"] // empty' package.json 2>/dev/null)
HAS_TYPE_CHECK := $(shell test -f package.json && jq -r '.scripts["type-check"] // empty' package.json 2>/dev/null)
HAS_COVERAGE := $(shell test -f package.json && jq -r '.scripts.coverage // empty' package.json 2>/dev/null)
HAS_DEV := $(shell test -f package.json && jq -r '.scripts.dev // empty' package.json 2>/dev/null)
HAS_START := $(shell test -f package.json && jq -r '.scripts.start // empty' package.json 2>/dev/null)

## Node.js/TypeScript
node-info: ## Show Node.js project information
	@echo "$(GREEN)Node.js Project Information$(RESET)"
	@echo "Package manager: $(PM)"
	@echo "Lock file: $(LOCKFILE)"
	@echo "Workspace: $(WORKSPACE_DIR)"
	@if [ -f package.json ]; then \
		echo "Project name: $$(jq -r '.name // "Unknown"' package.json)"; \
		echo "Version: $$(jq -r '.version // "Unknown"' package.json)"; \
		echo "Available scripts:"; \
		jq -r '.scripts | keys[]' package.json 2>/dev/null | sed 's/^/  - /' || echo "  None"; \
	else \
		echo "$(YELLOW)No package.json found$(RESET)"; \
	fi

node-install: ## Install dependencies
	@echo "$(GREEN)Installing dependencies with $(PM)...$(RESET)"
	@cd $(WORKSPACE_DIR) && $(PM_INSTALL)

node-install-frozen: ## Install dependencies with frozen lockfile
	@echo "$(GREEN)Installing dependencies (frozen lockfile)...$(RESET)"
	@cd $(WORKSPACE_DIR) && \
		if [ "$(PM)" = "npm" ]; then \
			npm ci; \
		elif [ "$(PM)" = "yarn" ]; then \
			yarn install --frozen-lockfile; \
		elif [ "$(PM)" = "pnpm" ]; then \
			pnpm install --frozen-lockfile; \
		elif [ "$(PM)" = "bun" ]; then \
			bun install --frozen-lockfile; \
		fi

node-update: ## Update dependencies
	@echo "$(GREEN)Updating dependencies...$(RESET)"
	@cd $(WORKSPACE_DIR) && \
		if [ "$(PM)" = "npm" ]; then \
			npm update; \
		elif [ "$(PM)" = "yarn" ]; then \
			yarn upgrade; \
		elif [ "$(PM)" = "pnpm" ]; then \
			pnpm update; \
		elif [ "$(PM)" = "bun" ]; then \
			bun update; \
		fi

node-outdated: ## Check for outdated dependencies
	@echo "$(GREEN)Checking for outdated dependencies...$(RESET)"
	@cd $(WORKSPACE_DIR) && \
		if [ "$(PM)" = "npm" ]; then \
			npm outdated; \
		elif [ "$(PM)" = "yarn" ]; then \
			yarn outdated; \
		elif [ "$(PM)" = "pnpm" ]; then \
			pnpm outdated; \
		elif [ "$(PM)" = "bun" ]; then \
			bun outdated; \
		fi

## Building
node-build: ## Build the project
ifneq ($(HAS_BUILD),)
	@echo "$(GREEN)Building project...$(RESET)"
	@cd $(WORKSPACE_DIR) && $(PM_RUN) build
else
	@echo "$(YELLOW)No build script found in package.json$(RESET)"
endif

node-build-watch: ## Build in watch mode
	@echo "$(GREEN)Building in watch mode...$(RESET)"
	@cd $(WORKSPACE_DIR) && \
		if [ -n "$(shell jq -r '.scripts["build:watch"] // empty' package.json 2>/dev/null)" ]; then \
			$(PM_RUN) build:watch; \
		else \
			echo "$(YELLOW)No build:watch script found$(RESET)"; \
		fi

## Development
node-dev: ## Start development server
ifneq ($(HAS_DEV),)
	@echo "$(GREEN)Starting development server...$(RESET)"
	@cd $(WORKSPACE_DIR) && $(PM_RUN) dev
else
	@echo "$(YELLOW)No dev script found in package.json$(RESET)"
endif

node-start: ## Start production server
ifneq ($(HAS_START),)
	@echo "$(GREEN)Starting production server...$(RESET)"
	@cd $(WORKSPACE_DIR) && $(PM_RUN) start
else
	@echo "$(YELLOW)No start script found in package.json$(RESET)"
endif

## Testing
node-test: ## Run tests
ifneq ($(HAS_TEST),)
	@echo "$(GREEN)Running tests...$(RESET)"
	@cd $(WORKSPACE_DIR) && $(PM_RUN) test
else
	@echo "$(YELLOW)No test script found in package.json$(RESET)"
endif

node-test-watch: ## Run tests in watch mode
	@echo "$(GREEN)Running tests in watch mode...$(RESET)"
	@cd $(WORKSPACE_DIR) && \
		if [ -n "$(shell jq -r '.scripts["test:watch"] // empty' package.json 2>/dev/null)" ]; then \
			$(PM_RUN) test:watch; \
		else \
			echo "$(YELLOW)No test:watch script found$(RESET)"; \
		fi

node-test-coverage: ## Run tests with coverage
ifneq ($(HAS_COVERAGE),)
	@echo "$(GREEN)Running tests with coverage...$(RESET)"
	@cd $(WORKSPACE_DIR) && $(PM_RUN) coverage
else ifneq ($(HAS_TEST),)
	@echo "$(GREEN)Running tests (coverage via test script)...$(RESET)"
	@cd $(WORKSPACE_DIR) && $(PM_RUN) test --coverage
else
	@echo "$(YELLOW)No coverage or test script found$(RESET)"
endif

## Linting and Formatting
node-lint: ## Run linter
ifneq ($(HAS_LINT),)
	@echo "$(GREEN)Running linter...$(RESET)"
	@cd $(WORKSPACE_DIR) && $(PM_RUN) lint
else
	@echo "$(YELLOW)No lint script found in package.json$(RESET)"
endif

node-lint-fix: ## Run linter with auto-fix
	@echo "$(GREEN)Running linter with auto-fix...$(RESET)"
	@cd $(WORKSPACE_DIR) && \
		if [ -n "$(shell jq -r '.scripts["lint:fix"] // empty' package.json 2>/dev/null)" ]; then \
			$(PM_RUN) lint:fix; \
		else \
			echo "$(YELLOW)No lint:fix script found$(RESET)"; \
		fi

node-format: ## Format code
ifneq ($(HAS_FORMAT),)
	@echo "$(GREEN)Formatting code...$(RESET)"
	@cd $(WORKSPACE_DIR) && $(PM_RUN) format
else
	@echo "$(YELLOW)No format script found in package.json$(RESET)"
endif

node-format-check: ## Check code formatting
ifneq ($(HAS_FORMAT_CHECK),)
	@echo "$(GREEN)Checking code formatting...$(RESET)"
	@cd $(WORKSPACE_DIR) && $(PM_RUN) format:check
else
	@echo "$(YELLOW)No format:check script found in package.json$(RESET)"
endif

node-type-check: ## Run TypeScript type checking
ifneq ($(HAS_TYPE_CHECK),)
	@echo "$(GREEN)Running type checking...$(RESET)"
	@cd $(WORKSPACE_DIR) && $(PM_RUN) type-check
else
	@echo "$(YELLOW)No type-check script found in package.json$(RESET)"
endif

## Quality Checks
node-audit: ## Run security audit
	@echo "$(GREEN)Running security audit...$(RESET)"
	@cd $(WORKSPACE_DIR) && \
		if [ "$(PM)" = "npm" ]; then \
			npm audit; \
		elif [ "$(PM)" = "yarn" ]; then \
			yarn audit; \
		elif [ "$(PM)" = "pnpm" ]; then \
			pnpm audit; \
		elif [ "$(PM)" = "bun" ]; then \
			bun audit; \
		fi

node-audit-fix: ## Fix security vulnerabilities
	@echo "$(GREEN)Fixing security vulnerabilities...$(RESET)"
	@cd $(WORKSPACE_DIR) && \
		if [ "$(PM)" = "npm" ]; then \
			npm audit fix; \
		elif [ "$(PM)" = "yarn" ]; then \
			yarn audit --fix; \
		elif [ "$(PM)" = "pnpm" ]; then \
			pnpm audit --fix; \
		elif [ "$(PM)" = "bun" ]; then \
			echo "Bun doesn't support audit fix yet"; \
		fi

## Documentation
node-docs: ## Generate documentation
	@echo "$(GREEN)Generating documentation...$(RESET)"
	@cd $(WORKSPACE_DIR) && \
		if [ -n "$(shell jq -r '.scripts.docs // empty' package.json 2>/dev/null)" ]; then \
			$(PM_RUN) docs; \
		else \
			echo "$(YELLOW)No docs script found$(RESET)"; \
		fi

## Cleaning
node-clean: ## Clean build artifacts and node_modules
	@echo "$(GREEN)Cleaning build artifacts...$(RESET)"
	@cd $(WORKSPACE_DIR) && rm -rf $(BUILD_DIR) $(COVERAGE_DIR) $(DOCS_DIR)

node-clean-deps: ## Remove node_modules and lockfile
	@echo "$(GREEN)Removing dependencies...$(RESET)"
	@cd $(WORKSPACE_DIR) && rm -rf node_modules $(LOCKFILE)

node-clean-all: node-clean node-clean-deps ## Clean everything

## Package Management
node-add: ## Add a dependency (usage: make node-add PACKAGE=package-name)
	@if [ -z "$(PACKAGE)" ]; then \
		echo "$(YELLOW)Usage: make node-add PACKAGE=package-name$(RESET)"; \
		exit 1; \
	fi
	@echo "$(GREEN)Adding package $(PACKAGE)...$(RESET)"
	@cd $(WORKSPACE_DIR) && $(PM_ADD) $(PACKAGE)

node-add-dev: ## Add a dev dependency (usage: make node-add-dev PACKAGE=package-name)
	@if [ -z "$(PACKAGE)" ]; then \
		echo "$(YELLOW)Usage: make node-add-dev PACKAGE=package-name$(RESET)"; \
		exit 1; \
	fi
	@echo "$(GREEN)Adding dev package $(PACKAGE)...$(RESET)"
	@cd $(WORKSPACE_DIR) && \
		if [ "$(PM)" = "npm" ]; then \
			npm install --save-dev $(PACKAGE); \
		elif [ "$(PM)" = "yarn" ]; then \
			yarn add --dev $(PACKAGE); \
		elif [ "$(PM)" = "pnpm" ]; then \
			pnpm add --save-dev $(PACKAGE); \
		elif [ "$(PM)" = "bun" ]; then \
			bun add --dev $(PACKAGE); \
		fi

node-remove: ## Remove a dependency (usage: make node-remove PACKAGE=package-name)
	@if [ -z "$(PACKAGE)" ]; then \
		echo "$(YELLOW)Usage: make node-remove PACKAGE=package-name$(RESET)"; \
		exit 1; \
	fi
	@echo "$(GREEN)Removing package $(PACKAGE)...$(RESET)"
	@cd $(WORKSPACE_DIR) && $(PM_REMOVE) $(PACKAGE)

## Combined Commands
node-ci: node-install-frozen node-format-check node-lint node-type-check node-test node-audit ## Run all CI checks
node-all: node-install node-build node-test node-lint node-format ## Run full development workflow
node-reset: node-clean-all node-install ## Reset project (clean and reinstall)

.PHONY: node-info node-install node-install-frozen node-update node-outdated \
        node-build node-build-watch node-dev node-start \
        node-test node-test-watch node-test-coverage \
        node-lint node-lint-fix node-format node-format-check node-type-check \
        node-audit node-audit-fix node-docs \
        node-clean node-clean-deps node-clean-all \
        node-add node-add-dev node-remove \
        node-ci node-all node-reset

endif # __MAKEFILE_NODE_MK__