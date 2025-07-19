# Makefile.config.mk - Centralized configuration for all makefiles
# This file contains all configurable values used across the build system

ifndef __MAKEFILE_CONFIG_MK__
__MAKEFILE_CONFIG_MK__ := 1

##@ Infrastructure Configuration

# Docker registry settings
DOCKER_REGISTRY ?= docker.io
DOCKER_NAMESPACE ?= zondax

# Remote BuildKit configuration
REMOTE_BUILD_KIT ?= tcp://buildkit.zondax.dev:8372
DOCKER_BUILDER_NAME ?= zondax-builder

# Platform defaults
DEFAULT_PLATFORMS ?= linux/amd64,linux/arm64

##@ Tool Versions

# Go tools
GOLANGCI_LINT_VERSION ?= latest
GO_DEFAULT_VERSION ?= 1.21

# Rust tools
RUST_DEFAULT_TOOLCHAIN ?= stable

# Node.js tools
NODE_DEFAULT_VERSION ?= 20

# Infrastructure tools
KUBECONFORM_VERSION ?= v0.6.7

##@ Build Settings

# Coverage thresholds
GO_COVERAGE_THRESHOLD ?= 70
RUST_COVERAGE_THRESHOLD ?= 80
NODE_COVERAGE_THRESHOLD ?= 80

# Timeouts
TEST_TIMEOUT ?= 10m
BUILD_TIMEOUT ?= 30m

# Parallel jobs (default to number of CPUs)
PARALLEL_JOBS ?= $(shell nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

##@ Directory Configuration

# Common directory names
BUILD_DIR ?= build
DIST_DIR ?= dist
COVERAGE_DIR ?= coverage
DOCS_DIR ?= docs
INTERNAL_DIR ?= internal

# Cache directories
CACHE_DIR ?= .cache
GO_CACHE_DIR ?= $(CACHE_DIR)/go
RUST_CACHE_DIR ?= $(CACHE_DIR)/rust
NODE_CACHE_DIR ?= $(CACHE_DIR)/node

##@ Output Configuration

# ANSI color codes (if not already defined)
ifndef GREEN
GREEN  := $(shell command -v tput >/dev/null 2>&1 && tput -Txterm setaf 2 || echo '')
YELLOW := $(shell command -v tput >/dev/null 2>&1 && tput -Txterm setaf 3 || echo '')
RED    := $(shell command -v tput >/dev/null 2>&1 && tput -Txterm setaf 1 || echo '')
CYAN   := $(shell command -v tput >/dev/null 2>&1 && tput -Txterm setaf 6 || echo '')
RESET  := $(shell command -v tput >/dev/null 2>&1 && tput -Txterm sgr0 || echo '')
endif

# Output formatting
ARROW := →
CHECK := ✓
CROSS := ✗

##@ Feature Flags

# Enable experimental features
ENABLE_EXPERIMENTAL ?= false

# Enable build caching
ENABLE_BUILD_CACHE ?= true

# Enable parallel builds
ENABLE_PARALLEL ?= true

# Enable verbose output in CI
CI_VERBOSE ?= true

endif # __MAKEFILE_CONFIG_MK__