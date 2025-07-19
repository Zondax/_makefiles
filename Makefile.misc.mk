ifndef __MAKEFILE_MISC_MK__
__MAKEFILE_MISC_MK__ := 1

## Misc

gitclean: ## Git Clean 
	git clean -xfd
	git submodule foreach --recursive git clean -xfd

endif # __MAKEFILE_MISC_MK__
