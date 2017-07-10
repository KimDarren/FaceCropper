# FaceCropper

[![Version](https://img.shields.io/cocoapods/v/FaceCropper.svg?style=flat)](http://cocoapods.org/pods/FaceCropper)
[![License](https://img.shields.io/cocoapods/l/FaceCropper.svg?style=flat)](http://cocoapods.org/pods/FaceCropper)

## Requirements

* Xcode 9.0 _(beta)_ or higher.
* iOS 11.0 _(beta)_ or higher.
  - _(It is possible to import this library under the iOS 11. But it won't be working.)_
  
## Usage

* Crop faces from your image (`UIImage` or `CGImage`) in the easy way.

```swift
let image = UIImage(named: "image_contains_faces")
image.face.crop { result in
  switch result {
  case .success(let faces):
    // When the `Vision` successfully find faces, and `FaceCropper` cropped it.
    // `faces` argument is a collection of cropped images.
  case .notFound:
    // When the image doesn't contain any face, `result` will be `.notFound`.
  case .failure(let error):
    // When the any error occured, `result` will be `failure`.
  }
}
```

## Example

![Example app screenshot](https://github.com/KimDarren/FaceCropper/blob/master/screenshots/example.png?raw=true)

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

**FaceCropper** is available through [CocoaPods](http://cocoapods.org).
To install it, simply add the following line to your Podfile:

```ruby
pod "FaceCropper"
```

## Author

KimDarren, korean.darren@gmail.com

## License

FaceCropper is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
