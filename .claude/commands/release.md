---
description: Build, sign, notarize, and release the app to GitHub
arguments:
  - name: bump
    description: Version bump type (patch, minor, major) or explicit version (e.g., 1.2.0)
    required: false
    default: patch
---

# Release slownyt

Follow these steps to release a new version:

## 1. Determine New Version

Get current version from `slownyt.xcodeproj/project.pbxproj`:
```bash
grep "MARKETING_VERSION" slownyt.xcodeproj/project.pbxproj | head -1
```

Calculate the new version based on `$ARGUMENTS.bump`:
- If `patch` (default): 1.0 -> 1.0.1, or 1.0.1 -> 1.0.2
- If `minor`: 1.0.1 -> 1.1.0
- If `major`: 1.0.1 -> 2.0.0
- If explicit version (e.g., "1.2.0"): use that version directly

Also increment `CURRENT_PROJECT_VERSION` by 1.

## 2. Update Version in Xcode Project

Update ALL occurrences of `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` in `slownyt.xcodeproj/project.pbxproj` using the Edit tool with `replace_all: true`.

## 3. Detect Signing Identity

Find the Developer ID certificate:
```bash
security find-identity -v -p codesigning | grep "Developer ID Application"
```

Extract the certificate name and team ID for use in subsequent steps.

## 4. Build and Archive

```bash
xcodebuild -project slownyt.xcodeproj -scheme slownyt -configuration Release \
  -archivePath build/slownyt.xcarchive archive \
  CODE_SIGN_IDENTITY="<Developer ID from step 2>" \
  CODE_SIGN_STYLE=Manual DEVELOPMENT_TEAM=<Team ID from step 2>
```

## 5. Export with Developer ID

Ensure `build/ExportOptions.plist` exists with the correct team ID, then:
```bash
rm -rf build/export
xcodebuild -exportArchive \
  -archivePath build/slownyt.xcarchive \
  -exportPath build/export \
  -exportOptionsPlist build/ExportOptions.plist
```

## 6. Notarize

Requires stored credentials: `xcrun notarytool store-credentials "notarytool"`

```bash
cd build/export
ditto -c -k --keepParent slownyt.app slownyt.zip
xcrun notarytool submit slownyt.zip --keychain-profile "notarytool" --wait
```

## 7. Staple and Package

```bash
xcrun stapler staple slownyt.app
rm slownyt.zip
ditto -c -k --keepParent slownyt.app slownyt.zip
```

## 8. Create GitHub Release

Ask the user for release notes, or generate from commits since last tag:
```bash
gh release create v<new_version> build/export/slownyt.zip \
  --title "slownyt v<new_version>" \
  --notes "<release notes>"
```

Use the new version calculated in step 1.

## 9. Verify

Confirm the release was created and provide the release URL to the user.
