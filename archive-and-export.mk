#
#  archive-and-export.mk
#  iOS_CI-CD
#
#  Created by Tomasz Kukułka on 07/05/2023.
#

PROJECT = $(PROJECT_NAME).xcodeproj
SCHEME = $(DISTRIBUTING_SCHEME_NAME)
SDK = iphoneos
DESTINATION = generic/platform=iOS

ARCHIVE_RESULT_PATH = archive_result.xcarchive
EXPORT_RESULT_PATH = export_result
EXPORT_OPTIONS_PLIST = ExportOptions.plist
IPA_FILE = $(EXPORT_RESULT_PATH)/$(PROJECT_NAME).ipa

PROVISION_PROFILE = ~/Library/MobileDevice/Provisioning Profiles/$(PROVISION_PROFILE_UUID).mobileprovision
CERTIFICATE = certificate.p12

DEFAULT_KEYCHAINS = $(shell security list-keychains -d user)

# - Targets
all: prepare_project archive export distribute clean

prepare_project: install_profile install_certificate
	@echo "ℹ️ Prepare project environment"
	@bash prepare_project.sh

install_profile:
	@echo "ℹ️ Installing profile"
	@echo $(PROVISION_PROFILE_BASE64) | base64 --decode > $(PROVISION_PROFILE)

install_certificate:
	@echo $(CERTIFICATE_BASE64) | base64 --decode > $(CERTIFICATE)
	@security create-keychain -p "$(KEYCHAIN_PASSWORD)" $(KEYCHAIN_PATH) 2>/dev/null
	@# Set infinite time-out of the keychain
	@security set-keychain-settings $(KEYCHAIN_PATH)
	@security unlock-keychain -p "$(KEYCHAIN_PASSWORD)" $(KEYCHAIN_PATH)
	@security import $(CERTIFICATE) \
	-P "$(CERTIFICATE_PASSWORD)" -t cert -f pkcs12 \
	-k $(KEYCHAIN_PATH) \
	-A -T /usr/bin/codesign
	@# List default keychain and created keychain. If you use a SaaS runner you can delete DEFAULT_KEYCHAINS.
	@security list-keychain -d user -s $(DEFAULT_KEYCHAINS) $(KEYCHAIN_PATH)

archive:
	@echo "ℹ️ Archive"
	set -euo pipefail && xcodebuild \
	clean archive \
	-project $(PROJECT) \
	-scheme $(SCHEME) \
	-sdk $(SDK) \
	-destination $(DESTINATION) \
	-archivePath $(ARCHIVE_RESULT_PATH) \
	OTHER_CODE_SIGN_FLAGS="--keychain=$(KEYCHAIN_PATH)" \
	| xcbeautify

export:
	@echo "ℹ️ Exporting"
	@echo $(EXPORT_OPTIONS_PLIST_BASE64) | base64 --decode > $(EXPORT_OPTIONS_PLIST)
	@# Do not modify order of parameters!
	set -euo pipefail && xcodebuild \
	-exportArchive \
	-archivePath $(ARCHIVE_RESULT_PATH) \
	-exportPath $(EXPORT_RESULT_PATH) \
	-exportOptionsPlist $(EXPORT_OPTIONS_PLIST) \
	| xcbeautify

distributing:
	@echo "ℹ️ Distributing"
	# Your code here ...

clean:
	@echo "ℹ️ Cleaning up"
	@rm -rf $(ARCHIVE_RESULT_PATH)
	@rm -rf $(EXPORT_RESULT_PATH)
	@rm -rf $(EXPORT_OPTIONS_PLIST)
	@rm -rf $(PROVISION_PROFILE)
	@security delete-keychain $(KEYCHAIN_PATH)
