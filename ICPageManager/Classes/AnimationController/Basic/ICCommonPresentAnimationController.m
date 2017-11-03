//
//  ICCommonPresentAnimationControllerDelegate.m
//  ICPageManager
//
//  Created by _ivanC on 3/11/16.
//  Copyright © 2016 _ivanC. All rights reserved.
//

#import "ICCommonPresentAnimationController.h"
#import "ICCommonPresentAnimatedTransitioning.h"

@implementation ICCommonPresentAnimationController

#pragma mark - Lifecycle
- (void)setupWithTargetViewController:(UIViewController *)targetViewController;
{
    [super setupWithTargetViewController:targetViewController];

    self.enabledVerticalMove = YES;
    self.enabledHorizontalMove = NO;
}

#pragma mark - Gesture Action
- (void)existCurrentViewController
{
    [self.targetViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIViewControllerTransitioningDelegate
- (nullable id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    return [[ICCommonPresentAnimatedTransitioning alloc] initWithOperation:ICPresentationOperationPresent];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [[ICCommonPresentAnimatedTransitioning alloc] initWithOperation:ICPresentationOperationDismiss];
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator
{
    // Not Support yet
    return nil;
}

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator
{
    return self.interactiveTransition;
}

//- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
//{
//    // Not Support yet
//    return nil;
//}

@end
