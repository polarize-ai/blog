.DEFAULT_GOAL := help
SHELL := /bin/bash


help: ## This help panel.
	@IFS=$$'\n' ; \
	help_lines=(`fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##/:/'`); \
	printf "%-30s %s\n" "DevOps console for Project polarize-ai/blog" ; \
	printf "%-30s %s\n" "===========================================" ; \
	printf "%-30s %s\n" "" ; \
	printf "%-30s %s\n" "Target" "Help" ; \
	printf "%-30s %s\n" "------" "----" ; \
	for help_line in $${help_lines[@]}; do \
        IFS=$$':' ; \
        help_split=($$help_line) ; \
        help_command=`echo $${help_split[0]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
        help_info=`echo $${help_split[2]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
        printf '\033[36m'; \
        printf "%-30s %s" $$help_command ; \
        printf '\033[0m'; \
        printf "%s\n" $$help_info; \
    done

%:      # thanks to chakrit
	@:    # thanks to Wi.lliam Pursell


requirements: ## Install requirements on workstation
	workflow/requirements/macOS/bootstrap
	source ~/.bash_profile && rbenv install --skip-existing 2.5.5
	source ~/.bash_profile && ansible-galaxy install -r workflow/requirements/macOS/ansible/requirements.yml
	ansible-playbook -i "localhost," workflow/requirements/generic/ansible/playbook.yml --tags "hosts" --ask-become-pass
	source ~/.bash_profile && ansible-playbook -i "localhost," workflow/requirements/macOS/ansible/playbook.yml --ask-become-pass
	rbenv rehash
	bundle install

requirements-hosts: ## Update /etc/hosts on workstation
	ansible-playbook -i "localhost," workflow/requirements/generic/ansible/playbook.yml --tags "hosts" --ask-become-pass

requirements-packages: ## Install packages on workstation
	ansible-playbook -i "localhost," workflow/requirements/macOS/ansible/playbook.yml --ask-become-pass

requirements-bundle: ## Install bundle requirements on workstation
	rbenv rehash
	bundle install

serve: ## Serve on workstation
	bundle exec jekyll serve

open: ## Open on workstation
	python -mwebbrowser http://127.0.0.1:4000/

glossary: ## Copy glossary data
	cp -f _data/glossary.json assets/glossary.json

build: glossary ## Build _site
	JEKYLL_ENV="production" bundle exec jekyll build --verbose --trace

index: ## Index content with Algolia
	JEKYLL_ENV="production" ALGOLIA_API_KEY="$(shell sed '1q;d' .algolia.token)" bundle exec jekyll algolia

publish: index ## Index content with Algolia, build, publish to gh-pages branch on GitHub and cross-publish to Medium
	JEKYLL_ENV="production" MEDIUM_INTEGRATION_TOKEN="$(shell sed '1q;d' .medium.token)" jgd
