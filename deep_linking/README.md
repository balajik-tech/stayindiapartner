# Share links (`share.stayindia.in`)

Referral links look like `https://share.stayindia.in/r/<referralId>` and open the
Partner app directly when it is installed.

## Host these two files

| URL | File |
|---|---|
| `https://share.stayindia.in/.well-known/assetlinks.json` | `.well-known/assetlinks.json` (Android) |
| `https://share.stayindia.in/.well-known/apple-app-site-association` | `.well-known/apple-app-site-association` (iOS, no file extension) |

Requirements:

- HTTPS with a valid certificate, status `200`, **no redirects** (not even http→https or to `www`).
- `Content-Type: application/json` for both files.
- Publicly reachable (no auth, no Cloudflare bot challenge).

## `/r/*` fallback page

When the app is not installed, the browser opens `https://share.stayindia.in/r/<referralId>`.
Serve a page there that sends the user to the store:

- Android: `https://play.google.com/store/apps/details?id=com.stayindia.stayindiaowner&referrer=ref%3D<referralId>`
- iOS: the App Store page for the Partner app.

## Signing fingerprints in `assetlinks.json`

1. `52:9F:5A:…:33:95`: release upload key (`android/app/keystore.jks`).
2. `60:45:72:…:39:4D`: local debug key, for testing only.

If the app uses **Play App Signing**, add the "App signing key certificate" SHA-256 from
Play Console → Test and release → App integrity. Without it, links won't verify for Play
Store installs.

## Verify

- Android: `adb shell pm get-app-links com.stayindia.stayindiaowner` should show `share.stayindia.in: verified`.
- iOS: `https://app-site-association.cdn-apple.com/a/v1/share.stayindia.in` should return the file.
