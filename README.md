# iOS CI/CD

### List of variables:
- `PROJECT_NAME` - Name of the project.
- `TEST_SCHEME_NAME` - Name of the scheme which'll be used for building and testing.
 - `DISTRIBUTING_SCHEME_NAME` - Name of the scheme which'll be used for archive.
- `TEST_PROJECT_CONFIG_BUNDLE_ID` - Bundle identifier used into uninstall the app form simulator. If you use SaaS CI/CD runner you can skip it.
- If you use GitLab export `DANGER_GITLAB_API_TOKEN`, if you use GitHub export `DANGER_GITHUB_API_TOKEN`, see docs: https://danger.systems/guides/getting_started.html
- `PROVISION_PROFILE_BASE64` - base64 value of Provisioning Profile used to archive and export.
- `PROVISION_PROFILE_UUID` - Provisioning profiles UUID. You can use cat to find it.
- `CERTIFICATE_BASE64` - bas64 value of certificate .p12 used to sing during archiving and exporting.
- `CERTIFICATE_PASSWORD` - Certificate password.
- `KEYCHAIN_PATH` - Keychain path used to temporary store certificate.
- `KEYCHAIN_PASSWORD` - Password to keychain.
- `EXPORT_OPTIONS_PLIST_BASE64` - base64 value of export options .plist file used to export archive.
- `CODE_SIGN_IDENTITY` - Code sign identity e.g. `iPhone Distribution: Your Company'.

## Configuration:

### **General**
- Check if `xcbeautify` is installed, link to docs: https://github.com/tuist/xcbeautify. You can change it into `xcpretty` if you want but you have to change it in `build-and-test.mk` and `archive-and-export.mk`.
- In `prepare_project.sh` file add required steps which must be executed before buid your project ec. SwiftGen.

### **CI**
1. In `Gemfile` choose right gem dependency depending on what remote repo you use (`gem 'danger-gitlab'` for GitLab, `gem 'danger'` for others). See docs: https://github.com/danger/danger.
2. If you use SaaS CI/CD runner you can delete target `reset_simulator` from `build-and-test.mk` file. Do not forget to delete it from target `all`!
3. In `build-and-test.mk` change `DEVICE`, `PLATFORM`, `IOS_VERSION` values into compatible with your project settings.
4. Add `make -f build-and-test.mk` into your pipeline.

### **CD**
1. In `archive-and-export.mk` change `DESTINATION` and `SDK` values into compatible with your project settings.
2. Add `make -f archive-and-export.mk` into your pipeline.
3. Add `make -f archive-and-export.mk clean` into your pipeline when job finish with failure.