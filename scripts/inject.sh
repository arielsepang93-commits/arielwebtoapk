#!/bin/bash
set -e

cd apk-builder

echo "App: $APP_NAME | URL: $APP_URL | Pkg: $PKG"

cat > app/src/main/res/values/strings.xml <<XML
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">$APP_NAME</string>
    <string name="web_url">$APP_URL</string>
</resources>
XML

PERMS_XML=""
IFS=',' read -ra ARR <<< "$PERMS"
for p in "${ARR[@]}"; do
  [ -z "$p" ] && continue
  PERMS_XML="$PERMS_XML    <uses-permission android:name=\"android.permission.$p\" />
"
done

cat > app/src/main/AndroidManifest.xml <<XML
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

$PERMS_XML

    <application
        android:label="@string/app_name"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="true"
        android:theme="@style/Theme.AppCompat.Light.NoActionBar">
        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
XML

sed -i "s|applicationId \".*\"|applicationId \"$PKG\"|" app/build.gradle

if [ -n "$ICON" ]; then
  echo "$ICON" | base64 -d > /tmp/icon.png
  for d in mipmap-hdpi mipmap-mdpi mipmap-xhdpi mipmap-xxhdpi mipmap-xxxhdpi; do
    mkdir -p "app/src/main/res/$d"
    cp /tmp/icon.png "app/src/main/res/$d/ic_launcher.png"
  done
fi

echo "Inject done"
