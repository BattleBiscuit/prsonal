# Releasing prsonal_app to the Play Store

CI (`.github/workflows/ci.yml`) gates every push/PR. Releases are built by
`.github/workflows/release.yml` when you push a `vX.Y.Z` tag.

## One-time setup

### 1. Create an upload keystore
```bash
cd prsonal_app/android/app
keytool -genkey -v -keystore upload-keystore.jks \
  -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
Keep this file safe and **out of git** (it's git-ignored). For local release
builds, copy `android/key.properties.example` → `android/key.properties` and fill
it in.

### 2. Add GitHub Actions secrets
Settings → Secrets and variables → Actions:

| Secret | Value |
|--------|-------|
| `ANDROID_KEYSTORE_BASE64` | `base64 -w0 prsonal_app/android/app/upload-keystore.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | store password |
| `ANDROID_KEY_PASSWORD` | key password |
| `ANDROID_KEY_ALIAS` | `upload` |
| `PLAY_SERVICE_ACCOUNT_JSON` | *(optional)* Play Console service-account JSON for auto-upload |

Without the keystore secrets the release workflow still runs and produces a
(debug-signed, non-uploadable) AAB artifact, so you can test the pipeline first.

### 3. Play Console (for auto-upload)
- Create the app with package name **`com.prsonal.prsonal_app`** and upload the
  first AAB manually once.
- Create a service account (Google Cloud → IAM) with the Play Developer API,
  grant it release access in the Play Console, download its JSON key, and store
  it as `PLAY_SERVICE_ACCOUNT_JSON`. The workflow then pushes to the **internal**
  track.

## Cutting a release
1. Bump the version in `pubspec.yaml` — `version: X.Y.Z+N`. The build number `N`
   (versionCode) **must increase** on every Play upload.
2. Commit, then tag and push:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
3. The Release workflow then:
   - builds the signed **`.aab`** (Play) and **`.apk`** (direct download),
   - creates a **GitHub Release** for the tag with both attached as
     `prsonal-vX.Y.Z.aab` / `prsonal-vX.Y.Z.apk` and auto-generated notes, and
   - (if configured) publishes the bundle to the Play **internal** track.

   Versioned binaries live permanently on the repo's **Releases** page; promote
   to closed/open/production from the Play Console.

## Notes
- App display name: **PRsonal** (`android:label` in AndroidManifest.xml).
- Code shrinking (R8/minify) is intentionally off; enable it later with
  Drift/notification keep rules if you want smaller bundles.
