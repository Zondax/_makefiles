ifndef __MAKEFILE_YAML_MK__
__MAKEFILE_YAML_MK__ := 1

KUBECONFORM_EXTRA_CRD_VERSION := main
KUBECONFORM_EXTRA_CRD_URL := https://raw.githubusercontent.com/datreeio/CRDs-catalog/$(KUBECONFORM_EXTRA_CRD_VERSION)

## Yaml
yaml-checks: ## Yaml Checks
	@$(MAKE) yaml-lint

yaml-lint: ## Yaml Lint with Auto-fix
	@echo "\nRunning prettier on YAML files..."
	@bunx prettier --write "**/*.{yaml,yml}"

.PHONY: yaml-checks yaml-lint

endif # __MAKEFILE_YAML_MK__
