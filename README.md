# Example app using the Dronecode SDK on iOS

### Getting started

1. Create the Xcode project file from `project.yml` with [xcodegen](https://github.com/yonaskolb/XcodeGen) (that can be installed with Homebrew: `$ brew install xcodegen`):

```
xcodegen
```

2. Get the dependencies with Carthage:

```
carthage bootstrap --platform ios
```

3. Open `DronecodeSDK-Swift-Example.xcodeproj` with Xcode.
4. Set the signing team in the "General" tab of target `DronecodeSDK_Swift_Example`
