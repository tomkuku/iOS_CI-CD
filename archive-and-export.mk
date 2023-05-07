#
#  build-and-test.mk
#  iOS_CI-CD
#
#  Created by Tomasz Kukułka on 07/05/2023.
#

PROVISION_PROFILE = ~/Library/MobileDevice/Provisioning Profiles/${PROVISION_UUID}.mobileprovision

install_profile:
	@echo "ℹ️ Installing profile"
	@echo $PROVISION_PROFILE_BASE64 | base64 --decode > $PROVISION_PROFILE
	