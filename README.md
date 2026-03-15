
# BudGator
Budgeting - one bite at a time

gantt
    title 🐊 BudGator Projektstatus
    dateFormat  YYYY-MM-DD
    axisFormat  %d.%m.

    section Erledigt
    Projekt-Setup & Flutter Umgebung :done, des1, 2026-03-01, 2026-03-03
    Grundlegende UI-Struktur         :done, des2, 2026-03-04, 2026-03-07
    Datenmodelle (Models)            :done, des3, 2026-03-08, 2026-03-10

    section In Arbeit
    Datenbank (sqflite) Integration  :active, des4, 2026-03-11, 2026-03-18
    State Management (Provider)      :active, des5, 2026-03-15, 2026-03-22

    section Geplant
    Input-Validierung & Formulare    :2026-03-23, 2026-03-27
    Statistik-Dashboard (Charts)     :2026-04-02, 2026-04-08
    Export-Funktion (CSV/PDF)        :2026-04-09, 2026-04-12
    Finaler Build & Testing          :2026-04-17, 2026-04-20

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

