# Example app using the Dronecode SDK on iOS

### Getting started

1. Create the Xcode project file from `project.yml` with [xcodegen](https://github.com/yonaskolb/XcodeGen) (that can be installed with Homebrew: `$ brew install xcodegen`):

```
xcodegen
```

2. Make sure you have [RubyGems](https://rubygems.org/pages/download) installed, then install the xcodeproj gem:

```
gem install --user xcodeproj
```

3. Get the dependencies with Carthage:

```
carthage bootstrap --platform ios
```

4. Open `DronecodeSDK-Swift-Example.xcodeproj` with Xcode.
5. Set the signing team in the "General" tab of target `DronecodeSDK_Swift_Example`
