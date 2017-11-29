# Interval UI Kit for iOS #

This is a collection of UIKit extensions to make it easier to style Interval Apps.  Included are UIButton extensions, color palettes, and more.

### Getting Started ###

Use CocoaPods to install this as a framework in your project:


```
pod 'IntervalUIKit', :git => 'https://YOUR_BITBUCKET_USERNAME@bitbucket.org/intervalintl/intervaluikit-ios.git'

```

### IUIKitManager ###

This class can be used to apply general appearance rules to your application.  For example, it will update all UINavigatioBar objects to use the 
standard Interval color palette.  To use this class, add the line below to you AppDelegate's `didFinishLaunchingWithOptions` method:

```
IUIKitManager.updateAppearance()
```


### Color Palettes ###

Included in this repo is an Xcode Color Palette named `Interval Color Palette.clr`.  You can download this file from the [Downloads page](https://bitbucket.org/intervalintl/intervaluikit-ios/downloads), and then place it in your local `~/Library/Colors` directory.  
Once installed, you will be able to pick colors in Xcode by their Interval Style Guide names.  

There is also a related Swift enum named `IUIKColorPalette` that can be used in your code to access the RGB values for each
named color.  For example, `IUIKColorPalette.Primary1` will return an enum with the first primary color. To access the values of the enum,
you have two choices:

```
// This will give you the raw RGB value as an unsigned integer
IUIKColorPalette.Primary1.rawValue

// This will give you the UIColor value
IUIKColorPalette.Primary1.color
```

Also included in the IUIKit framework is an extension to `UIColor`, which can be used to access a color palette value.  For example:

```
UIColor.color(IUIKColorPalette.Primary1)
```



### Buttons ###

This framework includes a subclass of UIButton named `IUIKButton`, which exposes several IBInspectable values.  They are:

* cornerRadius
* borderWidth
* borderColor

Because these attributes are exposed to Xcode's storyboard interface builder, you will be set these values at design time easily.

### More Information ###

Articles on UIAppearance and theming in iOS

* http://www.raywenderlich.com/108766/uiappearance-tutorial


