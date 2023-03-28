# Setup

## Android

Add to AndroidManifest.xml

    <!-- Permissions options for the `storage` group -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" tools:node="replace"/>
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
    <uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />

    <!-- Permissions options for the `camera` group -->
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.QUERY_ALL_PACKAGES"/>
    
    <!-- Permissions options for the `location` group -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

    <!-- Permissions options for the `background_location` group -->
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

    <!-- Permissions options for the `record_audio` group -->
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    
    <!-- Permissions options for the `notification` group -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

## iOS

Add to Info.plist

    <!-- Permission options for the `location` group -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Need location when in use</string>
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>Always and when in use!</string>
    <key>NSLocationUsageDescription</key>
    <string>Older devices need location.</string>
    <key>NSLocationAlwaysUsageDescription</key>
    <string>Can I have location always?</string>
    
    <!-- Permission options for the `camera` group -->
    <key>NSCameraUsageDescription</key>
    <string>camera</string>
    
    <!-- Permission options for the `record_audio` group -->
    <key>NSMicrophoneUsageDescription</key>
    <string>microphone</string>
    <key>NSSpeechRecognitionUsageDescription</key>
    <string>speech</string>

# How to use

## Request Permission

    bool permission = await PermissionRequest.request(PermissionRequestType.CAMERA, onDontAskAgain: (){});

## Check Permission

    bool permission = await PermissionRequest.check(PermissionRequestType.CAMERA);

## Open Setting

    PermissionRequest.openSetting();

    
