//
//  ICCommonPresentAnimationControllerDelegate.h
//  ICPageManager
//
//  Created by _ivanC on 3/11/16.
//  Copyright © 2016 _ivanC. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ICPAGEMANAGER_PRESENT_DEFAULT_BORDER_TRIGGER_WIDTH    60     ///< Default border trigger width

@protocol ICCommonPresentAnimationControllerDelegate;

@interface ICCommonPresentAnimationController : NSObject <UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, weak) id<ICCommonPresentAnimationControllerDelegate> delegate;

@property (nonatomic, assign) BOOL enabledHorizontalMove;      // Default is YES
@property (nonatomic, assign) BOOL enabledVerticalMove;      // Default is NO
@property (nonatomic, assign) CGFloat finishThreshold;      // [0, 1], Default is 0.3

@property (nonatomic, assign) BOOL isMovingHorizontal;

@property (nonatomic, assign) CGFloat borderTriggerWidthHorizontal;     // Default is 30
@property (nonatomic, assign) CGFloat borderTriggerWidthVertical;       // Default is 30

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController;

@end

@protocol ICCommonPresentAnimationControllerDelegate <NSObject>

@optional
- (void)commonPresentAnimationControllerDidFinishInteractiveTransition:(ICCommonPresentAnimationController *)animationController
                                                               isCanceled:(BOOL)isCanceled;

@end
