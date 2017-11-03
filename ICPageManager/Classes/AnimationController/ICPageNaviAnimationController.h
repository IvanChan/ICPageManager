//
//  ICPageNaviAnimationController.h
//  ICPageManager
//
//  Created by _ivanC on 1/20/16.
//  Copyright © 2016 _ivanC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICCommonNavigationAnimationController.h"

@interface ICPageNaviAnimationController : ICCommonNavigationAnimationController

@property (nonatomic, strong, readonly) UIViewController *currentActiveViewController;

- (void)updateStateWithViewController:(UIViewController *)viewController;

@end
