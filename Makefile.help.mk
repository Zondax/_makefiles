ifndef __MAKEFILE_HELP_MK__
__MAKEFILE_HELP_MK__ := 1

## Help
help: ## Show this help.
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} \
		/^[a-zA-Z_-]+:.*?## / {printf "    ${YELLOW}%-20s${GREEN}%s${RESET}\n", $$1, $$2} \
		/^## .*/ {gsub(/^## /,""); printf "  ${CYAN}%s${RESET}\n", $$0}' \
		$(MAKEFILE_LIST)

endif # __MAKEFILE_HELP_MK__
