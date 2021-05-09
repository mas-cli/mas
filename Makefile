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

SWIFT_VERSION = 5.3.2

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
# Targets
#

# Prints versions of tools used by this Makefile.
.PHONY: version
version:
	xcodebuild -version
	swiftenv version
	swift --version
	swift package tools-version

.PHONY: init
init:
	- swiftenv install $(SWIFT_VERSION)
	swiftenv local $(SWIFT_VERSION)

.PHONY: bootstrap
bootstrap:
	script/bootstrap

.PHONY: clean
clean:
	script/clean

.PHONY: distclean
distclean: clean

.PHONY: updateHeaders
updateHeaders:
	script/update_headers

.PHONY: build
build:
	script/build

.PHONY: test
test: build
	script/test

# make run ARGS="asdf"
.PHONY: run
run: build
	${EXECUTABLE_DIRECTORY}/${CMD_NAME} $(ARGS)

.PHONY: install
install:
	script/install $(PREFIX)

.PHONY: uninstall
uninstall:
	script/uninstall

.PHONY: format
format:
	script/format

.PHONY: lint
lint:
	script/lint

.PHONY: danger
danger:
	script/danger

# Builds bottles
.PHONY: bottles
bottles:
	script/bottle

# Alias for bottles
.PHONY: bottle
bottle: bottles

.PHONY: package
package:
	script/package

.PHONY: packageInstall
packageInstall:
	script/package_install

.PHONY: describe
describe:
	swift package describe

.PHONY: resolve
resolve:
	swift package resolve

.PHONY: dependencies
dependencies: resolve
	swift package show-dependencies

.PHONY: update
update: resolve
	swift package update
