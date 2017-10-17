# ICPageManager

[![CI Status](http://img.shields.io/travis/_ivanC/ICPageManager.svg?style=flat)](https://travis-ci.org/_ivanC/ICPageManager)
[![Version](https://img.shields.io/cocoapods/v/ICPageManager.svg?style=flat)](http://cocoapods.org/pods/ICPageManager)
[![License](https://img.shields.io/cocoapods/l/ICPageManager.svg?style=flat)](http://cocoapods.org/pods/ICPageManager)
[![Platform](https://img.shields.io/cocoapods/p/ICPageManager.svg?style=flat)](http://cocoapods.org/pods/ICPageManager)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

ICPageManager is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ICPageManager'
```

## Usage

Setup page window
 
```
[[ICPageManager sharedManager] setupWithRootViewController:rootVC];
    
[YourMainView addSubview:[ICPageManager sharedManager].pageWindow];
```

UINavigationController-like Api

```
- (void)pushPageViewController:(UIViewController *)pageViewController animated:(BOOL)animated completion:(void (^)(UINavigationController *navigationController))completion;
- (void)popPageViewController:(BOOL)animated completion:(ICPageManagerCompletionBlock)completion;
- (void)popToRootPageViewController:(BOOL)animated completion:(ICPageManagerCompletionBlock)completion;
- (void)popToViewController:(UIViewController *)pageViewController animated:(BOOL)animated completion:(ICPageManagerCompletionBlock)completion;
```

Please try out demo for you own.

## Author

_ivanC

## License

ICPageManager is available under the MIT license. See the LICENSE file for more info.
