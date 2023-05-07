# iOS CI/CD

## Variables
### List of variables:
- `PROJECT_NAME` - Name of the project.
- `TEST_SCHEME_NAME` - Name of the scheme which'll be used for building and testing (CI).
- `TEST_PROJECT_CONFIG_BUNDLE_ID` - Bundle identifier used into uninstall the app form simulator. If you use SaaS CI/CD runner you can skip it.
- If you use GitLab export `DANGER_GITLAB_API_TOKEN`, if you use GitHub export `DANGER_GITHUB_API_TOKEN`, see docs: https://danger.systems/guides/getting_started.html


## CI

### Configuration:
1. In `Gemfile` choose right gem dependency depending on what remote repo you use (`gem 'danger-gitlab'` for GitLab, `gem 'danger'` for others). See docs: https://github.com/danger/danger.
2. In `build-and-test.mk` file add required steps which must be executed before buid your project ec. SwiftGen.
3. Check if `xcbeautify` is installed, link to docs: https://github.com/tuist/xcbeautify. You can change it into `xcpretty` if you want. If installation of any formatter is impossible, delete the last line from `build_and_test` target in `build-and-test.mk` file.
4. If you use SaaS CI/CD runner you can delete target `reset_simulator` from `build-and-test.mk` file. Do not forget to delete it from target `all`!
5. In `build-and-test.mk` chnage `DEVICE`, `PLATFORM`, `IOS_VERSION` into compatible with your project settings.