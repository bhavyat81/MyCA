# MyCA

MyCA is a cross-platform Expo (React Native + TypeScript) app for personal Chartered Accountant workflow tracking across businesses.

## What the app does

- Select from your businesses (Planet Rehab, 83 Kennedy, Meltwich)
- Track **salary entries per employee, per month, per business**
- Track **expense entries per month, per business**
- Persist salary/expense data locally with AsyncStorage
- Use a dark modern gradient UI theme across screens

## Run locally

```bash
npm install
npx expo start
```

Then press:
- `i` for iOS Simulator
- `a` for Android Emulator

## Build for testing (EAS)

```bash
npm i -g eas-cli
eas build --profile preview --platform ios
eas build --profile preview --platform android
```

`eas.json` includes `development`, `preview`, and `production` profiles.

## Xcode Cloud note

An `.ipa` built with EAS can be uploaded to App Store Connect / TestFlight. Alternatively, you can run:

```bash
npx expo prebuild
```

Then open the generated `ios/` project in Xcode and wire it into Xcode Cloud.
