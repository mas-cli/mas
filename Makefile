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
PREFIX ?= $(shell brew --prefix)

# trunk
# SWIFT_VERSION = swift-DEVELOPMENT-SNAPSHOT-2020-04-23-a

# Swift 5.3
# SWIFT_VERSION = swift-5.3-DEVELOPMENT-SNAPSHOT-2020-04-21-a

SWIFT_VERSION = 5.7

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
	@echo "mas Makefile"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z0-9_-]*:.*?##' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?##"}; {printf $(MAKEFILE_FMT), $$1, $$2}'
: # Hacky way to display a newline ##

################################################################################
#
# ℹ️ Info Targets
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

################################################################################
#
# 👢 Bootstrap
#

.PHONY: bootstrap
bootstrap: ## Installs tools.
	script/bootstrap

################################################################################
#
# 👩🏻‍💻 Development Targets
#

.PHONY: clean
clean: ## Cleans built products.
	script/clean

.PHONY: lint
lint: ## Lints source code.
	script/lint

.PHONY: format
format: ## Formats source code.
	script/format

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

.PHONY: update-headers
update-headers: ## Updates private macOS headers.
	script/update_headers

################################################################################
#
# 🕊️ Swift Package Targets
#

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

################################################################################
#
# 🚀 Release Targets
#

.PHONY: build-universal
build-universal: ## Builds a "fat" universal binary.
	script/build --universal

.PHONY: install
install: build ## Installs the binary.
	script/install $(PREFIX)

.PHONY: install-universal
install-universal: build-universal ## Installs a universal binary.
	script/install --universal

.PHONY: uninstall
uninstall: ## Uninstalls the binary.
	script/uninstall

.PHONY: package
package: build ## Packages the project.
	script/package

.PHONY: package-install
package-install: package ## Installs the package.
	script/package_install

.PHONY: bottle
bottle: ## Builds Homebrew bottles.
	script/bottle

.PHONY: brew_formula_update
brew_formula_update: ## Updates homebrew-core formula.
	script/brew_formula_update

.PHONY: brew_release_validate
brew_release_validate: ## Builds Homebrew bottle for the current system.
	script/brew_release_validate
