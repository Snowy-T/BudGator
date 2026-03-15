# BudGator
Budgeting - one bite at a time


## Build an IPA for Sideloadly

Sideloadly installs `.ipa` files on iPhone, but Flutter iOS builds require macOS + Xcode.

1. Make sure your iOS bundle ID is unique in `ios/Runner.xcodeproj/project.pbxproj`.
2. On a Mac with Flutter + Xcode installed, run:

	```bash
	chmod +x scripts/build_ipa_for_sideloadly.sh
	./scripts/build_ipa_for_sideloadly.sh
	```

3. The generated IPA will be at:

	```
	build/ios/iphoneos/Budgator.ipa
	```

4. Open Sideloadly on Windows, select your iPhone and Apple ID, then choose that IPA file to sideload.

### Notes

- IPA generation cannot be done natively on Windows for Flutter iOS targets.
- If you use a free Apple ID, the app signature typically expires after 7 days.

## Build with Codemagic (recommended for your setup)

This repo now includes [codemagic.yaml](codemagic.yaml) with:

- `sideloadly_ipa`
- `sideloadly_ipa_auto_build_number` (recommended)

1. In Codemagic, connect this repository.
2. Start a new build using workflow: `sideloadly_ipa_auto_build_number`.
3. After build completion, download artifact:

	```
	build/ios/iphoneos/Budgator.ipa
	```

4. Open Sideloadly on Windows and select the downloaded IPA.

### Why auto build number helps

Using `sideloadly_ipa_auto_build_number` sets iOS build number from Codemagic `BUILD_NUMBER`, which avoids install failures caused by reusing the same build number.

