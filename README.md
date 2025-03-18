# Demo

![](demo.gif)

# Setup

## Change fvm flutter version

```bash
fvm use 3.29.1
```

## Change google api key

> Replace "google-api-key" in **AndroidManifest.xml** (Android) and **AppDelegate.swift** (iOS) with your google api key

## Setup android

```bash
cd android
./gradlew clean
```

## Setup ios

```bash
cd ios
pod install
```