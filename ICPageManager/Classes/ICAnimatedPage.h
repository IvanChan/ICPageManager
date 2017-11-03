//
//  ICAnimatedPage.h
//  ICPageManager
//
//  Created by _ivanC on 4/15/16.
//  Copyright © 2016 _ivanC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PageGestureDirection) {
    PageGestureDirectionNone            = 0,
    PageGestureDirectionHorizontal      = 1 << 0,
    PageGestureDirectionVertical        = 1 << 1,
};

@protocol ICAnimatedPage <NSObject>

- (PageGestureDirection)supportedPageGestureDirection;

@optional

// Navigation stuff
- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController;

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC;

// Gesture stuff
- (CGFloat)borderTriggerWidthHorizontal;
- (CGFloat)borderTriggerWidthVertical;

// Customized Gesture callback
// Return Value indicates wheather transition is being handled
// It's important that you have to call completion when your transtion done
- (BOOL)handleTransitionGesture:(UIPanGestureRecognizer *)recognizer completion:(void (^)(BOOL isCanceled))completion;

// after the interactie transition finished,the method will be triggered!
- (void)viewControllerDidDismissed:(BOOL)animated;

@end
