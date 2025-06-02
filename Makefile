.PHONY: help f_clean pubspec_delete

help: ## This help dialog.
	@IFS=$$'\n' ; \
	help_lines=(`fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//'`); \
	for help_line in $${help_lines[@]}; do \
		IFS=$$'#' ; \
		help_split=($$help_line) ; \
		help_command=`echo $${help_split[0]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
		help_info=`echo $${help_split[2]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
		printf "%-30s %s\n" $$help_command $$help_info ; \
	done

f_clean: ## This is clean step.
	@echo "⊢ Running flutter clean ⊣"
	@flutter clean
	@echo "Done"

pubspec_delete: f_clean ## This is delete pubspec.lock step.
	@echo "⊢ Deleting pubspec.lock ⊣"
	@rm pubspec.lock
	@echo "Done"

f_pub_get: pubspec_delete ## This is flutter pub get step.
	@echo "⊢ Running flutter pub get ⊣"
	@flutter pub get
	@echo "Done"
