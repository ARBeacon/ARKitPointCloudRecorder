# ARKitPointCloudRecorder

An iOS app to capture and export ARKit raw feature points (identifiers and positions) during AR sessions.

## Overview
This app records ARKit's [`rawFeaturePoints`](https://developer.apple.com/documentation/arkit/arframe/rawfeaturepoints) from ARFrames, including 3D coordinates and identifiers of detected feature points. Data is saved as JSON files for post-processing. Designed for analyzing feature point consistency across AR sessions.

## Usage
1. **Run the app:**
Build and run on a physical iOS device (ARKit requires a real camera).

2. **Start Scanning:**

Point the camera at a static scene (e.g., a room with textured surfaces).

Tap Start to begin recording ARFrames.

3. **Export Data:**

Tap Flush to save captured data to a JSON file in the app's Documents directory.

Transfer files via iTunes File Sharing.

## Log Output Format
```json
[
  {
    "timestamp": 123456789.0,
    "camera": { "transform": [ ] },
    "rawFeaturePoints": {
      "points": [ [1, 2, 3] ],
      "identifiers": ["absj", "sgwerg" ]
    }
  },
]
```

## Acknowledgment
This app idea and code are inspired by [CurvSurf/ARKitPointCloudRecorder](https://github.com/CurvSurf/ARKitPointCloudRecorder)
