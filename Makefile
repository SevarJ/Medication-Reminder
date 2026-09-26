.DEFAULT_GOAL := project

TUIST ?= mise exec -- tuist

help: ## show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

generate: ## create features declared in Project.swift that have no files yet, then generate the project
	$(TUIST) install
	python3 Scripts/scaffold_features.py $(TUIST)
	$(TUIST) generate --no-open
	$(TUIST) inspect dependencies

project: generate ## generate the project and open Xcode
	open MedReminder.xcworkspace

edit: ## edit the Tuist manifests
	$(TUIST) edit

clean: ## clean Tuist caches
	$(TUIST) clean

.PHONY: help generate project edit clean
