.DEFAULT: all

.PHONY: lint trivy test

all: test

lint:
	$(info Running lint tests ...)
	@RAILS_ENV=test bundle exec rubocop -c .rubocop.yml

trivy:
	$(info Running vulnerability tests with trivy ...)
	@trivy fs --skip-dirs node_modules --skip-dirs vendor --skip-dirs .ruby-lsp --security-checks vuln .

test: lint trivy
