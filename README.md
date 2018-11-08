# Example app using the Dronecode SDK on iOS

## Include the SDK in an existing application

### Carthage

Add the following line to your `Cartfile`:

```
github "Dronecode/DronecodeSDK-Swift" == 0.1.6
```

And then get the framework using:

```
carthage bootstrap --platform ios
```

When you later change the version in the `Cartfile`, you can update with:

```
carthage update --platform ios
```
