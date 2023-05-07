#
#  build-and-test.mk
#  iOS_CI-CD
#
#  Created by Tomasz Kukułka on 07/05/2023.
#

PROJECT = $(PROJECT_NAME).xcodeproj
SCHEME = $(TEST_SCHEME_NAME)
PLATFORM = 'iOS Simulator'
DEVICE = 'iPhone 14 Pro'
IOS_VERSION = 16.2
BUNDLE_IDENTIFIER = $(TEST_PROJECT_CONFIG_BUNDLE_ID)
CODE_SIGNING_ALLOWED = NO
DANGER_XCRESULT = test_project.xcresult

# - Targets
all: reset_environment prepare_project build_and_test run_danger

reset_environment:
	@echo "ℹ️ Reseting simulators"
	@# Shutdown all devices and boot again to be sure that right simulator is booted
	@xcrun simctl shutdown all
	@xcrun simctl boot $(DEVICE)
	@# Uninstall app and erase simulator to avoid error while tests
	@xcrun simctl uninstall $(DEVICE) $(BUNDLE_IDENTIFIER)
	@xcrun simctl shutdown $(DEVICE)
	@xcrun simctl erase $(DEVICE)
	@echo "ℹ️ Removing DerivedData" 
	@rm -rf ~/Library/Developer/Xcode/DerivedData

prepare_project:
	@echo "ℹ️ Preparing project"
	@bash prepare_project.sh

build_and_test:
	@echo "ℹ️ Building and Testing"
	@set -euo pipefail && xcodebuild \
	clean test \
	-project $(PROJECT) \
	-scheme $(SCHEME) \
	-destination platform=$(PLATFORM),name=$(DEVICE),OS=$(IOS_VERSION) \
	CODE_SIGNING_ALLOWED=$(CODE_SIGNING_ALLOWED) \
	| xcbeautify
	
run_danger:
	@echo "ℹ️ Running danger"
	@# Copy the newest .xcresult into home dir for danger-xcode_summary
	@cp -r ~/Library/Developer/Xcode/DerivedData/$(PROJECT_NAME)*/Logs/Test/*.xcresult $(DANGER_XCRESULT)
	@bundle install --path ~/.gem 1>/dev/null
	@bundle exec danger