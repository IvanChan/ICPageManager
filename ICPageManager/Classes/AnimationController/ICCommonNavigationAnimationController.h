//
//  ICCommonNavigationAnimationController.h
//  ICPageManager
//
//  Created by _ivanC on 3/11/16.
//  Copyright © 2016 _ivanC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ICCommonNavigationAnimationControllerDelegate;
@interface ICCommonNavigationAnimationController : NSObject <UIGestureRecognizerDelegate>
{
    @protected
    CGFloat _progressX;
    CGFloat _progressY;
}

@property (nonatomic, weak) id<ICCommonNavigationAnimationControllerDelegate> delegate;

@property (nonatomic, strong, readonly) UIPanGestureRecognizer *interactiveGestureRecognizer;

@property (nonatomic, assign) BOOL enabledHorizontalMove;      // Default is YES
@property (nonatomic, assign) BOOL enabledVerticalMove;      // Default is NO
@property (nonatomic, assign) CGFloat finishThreshold;      // [0, 1], Default is 0.3

@property (nonatomic, assign) CGFloat borderTriggerWidthHorizontal;     // Default is 30
@property (nonatomic, assign) CGFloat borderTriggerWidthVertical;       // Default is 30

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController;

- (void)handleTransitionGesture:(UIPanGestureRecognizer *)recognizer;

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController;

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC;

@end

@protocol ICCommonNavigationAnimationControllerDelegate <NSObject>

@optional
- (void)commonNavigationAnimationControllerDidFinishInteractiveTransition:(ICCommonNavigationAnimationController *)animationController
                                                               isCanceled:(BOOL)isCanceled;

@end
