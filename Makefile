#
# Makefile
# mas
#

################################################################################
#
# Variables
#

CMD_NAME = mas
SHELL = /bin/sh
PREFIX ?= /usr/local

# trunk
# SWIFT_VERSION = swift-DEVELOPMENT-SNAPSHOT-2020-04-23-a

# Swift 5.3
# SWIFT_VERSION = swift-5.3-DEVELOPMENT-SNAPSHOT-2020-04-21-a

SWIFT_VERSION = 5.6.1

# set EXECUTABLE_DIRECTORY according to your specific environment
# run swift build and see where the output executable is created

# OS specific differences
UNAME = ${shell uname}
ARCH = ${shell uname -m}

ifeq ($(UNAME), Darwin)
PLATFORM = $(ARCH)-apple-macosx
EXECUTABLE_DIRECTORY = ./.build/${PLATFORM}/debug
endif

################################################################################
#
# Help
#

.DEFAULT_GOAL := help

.PHONY: help
help: MAKEFILE_FMT = "  \033[36m%-25s\033[0m%s\n"
help: ## (default) Displays this message
	@echo "Ditto main Makefile."
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z0-9_-]*:.*?##' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?##"}; {printf $(MAKEFILE_FMT), $$1, $$2}'
	@echo ""
	@echo "Parameters:"
	@grep -E '^[A-Z0-9_-]* ?\?=.*?##' $(MAKEFILE_LIST) | awk 'BEGIN {FS = " ?\\?=.*?##"}; {printf $(MAKEFILE_FMT), $$1, $$2}'
: # Hacky way to display a newline ##

################################################################################
#
# Targets
#

.PHONY: version
version: ## Prints versions of tools used by this Makefile.
	xcodebuild -version
	swiftenv version
	swift --version
	swift package tools-version

.PHONY: init
init: ## Installs tools.
	- swiftenv install $(SWIFT_VERSION)
	swiftenv local $(SWIFT_VERSION)

.PHONY: bootstrap
bootstrap: ## Installs tools.
	script/bootstrap

.PHONY: clean
clean: ## Cleans built products.
	script/clean

.PHONY: updateHeaders
updateHeaders: ## Updates private headers.
	script/update_headers

.PHONY: build
build: ## Builds the project.
	script/build

.PHONY: test
test: build ## Runs tests.
	script/test

# make run ARGS="asdf"
.PHONY: run
run: build
	${EXECUTABLE_DIRECTORY}/${CMD_NAME} $(ARGS)

.PHONY: install
install: ## Installs the project.
	script/install $(PREFIX)

.PHONY: uninstall
uninstall: ## Uninstalls the project.
	script/uninstall

.PHONY: format
format: ## Formats source code.
	script/format

.PHONY: lint
lint: ## Lints source code.
	script/lint

.PHONY: danger
danger: ## Runs danger.
	script/danger

# Builds bottles
.PHONY: bottles
bottles: ## Builds bottles.
	script/bottle

.PHONY: bottle
bottle: bottles ## Alias for bottles

.PHONY: package
package: build ## Packages the project.
	script/package

.PHONY: packageInstall
packageInstall: package ## Installs the package.
	script/package_install

.PHONY: describe
describe: ## Describes the Swift package.
	swift package describe

.PHONY: resolve
resolve: ## Resolves SwiftPM dependencies.
	swift package resolve

.PHONY: dependencies
dependencies: resolve ## Lists SwiftPM dependencies.
	swift package show-dependencies

.PHONY: update
update: resolve ## Updates SwiftPM dependencies.
	swift package update
