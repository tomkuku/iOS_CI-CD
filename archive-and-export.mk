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
CODE_SIGNING_ALLOWED = NO
ARCHIVE_RESULT_PATH = archive_result.xcarchive
EXPORT_OPTIONS_PLIST = ExportOptions.plist
EXPORT_RESULT_PATH = export_result
IPA_FILE = $(EXPORT_RESULT_PATH)/$(PROJECT_NAME).ipa
CODE_SIGN_STYLE = "Manual"
PROVISION_PROFILE = ~/Library/MobileDevice/Provisioning Profiles/$(PROVISION_PROFILE_UUID).mobileprovision
CERTIFICATE = certificate.p12

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
	@security import $(CERTIFICATE) -P "$(CERTIFICATE_PASSWORD)" -A -t cert -f pkcs12 -k $(KEYCHAIN_PATH)
	@security list-keychain -d user -s $(KEYCHAIN_PATH)

archive:
	@echo "ℹ️ Archive"
	set -euo pipefail && xcodebuild \
	clean archive \
	-project $(PROJECT) \
	-scheme $(SCHEME) \
	-sdk $(SDK) \
	-destination $(DESTINATION) \
	-archivePath $(ARCHIVE_RESULT_PATH) \
	PROVISIONING_PROFILE_SPECIFIER="$(PROVISION_PROFILE_UUID)" \ 
	CODE_SIGN_IDENTITY="$(CODE_SIGN_IDENTITY) \
	CODE_SIGN_STYLE=$(CODE_SIGN_STYLE) \
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
	PROVISIONING_PROFILE_SPECIFIER="$(PROVISION_PROFILE_UUID)" \ 
	CODE_SIGN_IDENTITY="$(CODE_SIGN_IDENTITY) \
	CODE_SIGN_STYLE=$(CODE_SIGN_STYLE) \
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
