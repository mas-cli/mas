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

SWIFT_VERSION = 5.2.4

# set EXECUTABLE_DIRECTORY according to your specific environment
# run swift build and see where the output executable is created

# OS specific differences
UNAME = ${shell uname}

ifeq ($(UNAME), Darwin)
SWIFTC_FLAGS =
LINKER_FLAGS = -Xlinker -L/usr/local/lib
PLATFORM = x86_64-apple-macosx
EXECUTABLE_DIRECTORY = ./.build/${PLATFORM}/debug
TEST_BUNDLE = ${CMD_NAME}PackageTests.xctest
TEST_RESOURCES_DIRECTORY = ./.build/${PLATFORM}/debug/${TEST_BUNDLE}/Contents/Resources
endif

RUN_RESOURCES_DIRECTORY = ${EXECUTABLE_DIRECTORY}

################################################################################
#
# Targets
#

.PHONY: version
version:
	xcodebuild -version
	swift --version
	# swift package tools-version

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
	xcodebuild clean
	# swift package clean
	# swift package reset

.PHONY: distclean
distclean:
	rm -rf Packages
	# swift package clean

.PHONY: updateHeaders
updateHeaders:
	script/update_headers

.PHONY: build
build: #copyRunResources
	script/build
	# swift build $(SWIFTC_FLAGS) $(LINKER_FLAGS)

.PHONY: test
test: build #copyTestResources
	script/test
	# swift test --enable-test-discovery

.PHONY: copyRunResources
copyRunResources:
	mkdir -p ${RUN_RESOURCES_DIRECTORY}
	cp -r Resources/* ${RUN_RESOURCES_DIRECTORY}

.PHONY: copyTestResources
copyTestResources:
	mkdir -p ${TEST_RESOURCES_DIRECTORY}
	cp -r Resources/* ${TEST_RESOURCES_DIRECTORY}

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

.PHONY: sort
sort:
	script/sort

.PHONY: lint
lint:
	script/lint

.PHONY: danger
danger:
	script/danger

.PHONY: archive
archive:
	script/archive

.PHONY: bottle
bottle:
	script/bottle

.PHONY: package
package:
	script/package

.PHONY: packageInstall
packageInstall:
	script/package_install

.PHONY: release
release:
	script/release

# .PHONY: describe
# describe:
# 	swift package describe

# .PHONY: resolve
# resolve:
# 	swift package resolve

# .PHONY: dependencies
# dependencies: resolve
# 	swift package show-dependencies

# .PHONY: update
# update: resolve
# 	swift package update

# .PHONY: xcproj
# xcproj:
# 	swift package generate-xcodeproj
