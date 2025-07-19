# Makefile.base.mk - Common functionality for all makefiles
# This file provides shared utilities and patterns to reduce duplication

ifndef __MAKEFILE_BASE_MK__
__MAKEFILE_BASE_MK__ := 1

# Directory detection - used by multiple modules
MAKEFILES_DIR ?= $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

# Common error handling function
# Usage: $(call check_command,command_name,install_instructions)
define check_command
	@command -v $(1) >/dev/null 2>&1 || \
		(echo "Error: $(1) is required but not installed.$(if $(2), $(2))" && exit 1)
endef

# Tool installation helper
# Usage: $(call install_tool,tool_name,install_command)
define install_tool
	@echo "Installing $(1)..."
	@$(2)
	@echo "$(1) installed successfully"
endef

# Check if running in CI environment
CI ?= $(if $(GITHUB_ACTIONS)$(GITLAB_CI)$(JENKINS_HOME)$(CIRCLECI),true,)

# Verbose mode support
VERBOSE ?= $(if $(CI),true,)
V ?= $(if $(VERBOSE),,-s)

# Debug mode support
DEBUG ?=
D ?= $(if $(DEBUG),-x,)

# Common shell options for safety
SHELL_OPTS := set -euo pipefail;

# Function to safely execute shell commands
# Usage: $(call safe_shell,command)
define safe_shell
	@bash -c '$(SHELL_OPTS) $(1)'
endef

# Function to check if a makefile target exists
# Usage: $(call target_exists,target_name)
target_exists = $(shell $(MAKE) -n $(1) >/dev/null 2>&1 && echo yes || echo no)

# Function to get package manager (npm/yarn/pnpm/bun)
# Moved here from Makefile.node.mk as it's a common pattern
define detect_package_manager
	$(shell \
		if [ -f bun.lockb ]; then echo bun; \
		elif [ -f pnpm-lock.yaml ]; then echo pnpm; \
		elif [ -f yarn.lock ]; then echo yarn; \
		elif [ -f package-lock.json ]; then echo npm; \
		else echo npm; fi)
endef

# Common build information
BUILD_DATE ?= $(shell date -u +%Y%m%d%H%M%S)
GIT_HASH ?= $(shell git rev-parse HEAD 2>/dev/null || echo "unknown")
GIT_HASH_SHORT ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
GIT_BRANCH ?= $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
GIT_DIRTY ?= $(shell git diff --quiet || echo "-dirty")

# Export common variables for sub-makes
export MAKEFILES_DIR
export CI
export VERBOSE
export DEBUG

endif # __MAKEFILE_BASE_MK__