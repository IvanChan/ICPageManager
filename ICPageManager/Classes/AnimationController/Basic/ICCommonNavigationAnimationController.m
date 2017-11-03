//
//  ICCommonNavigationAnimationController.m
//  ICPageManager
//
//  Created by _ivanC on 3/11/16.
//  Copyright © 2016 _ivanC. All rights reserved.
//

#import "ICCommonNavigationAnimationController.h"
#import "ICCommonNavigationAnimatedTransitioning.h"

@implementation ICCommonNavigationAnimationController

#pragma mark - Lifecycle
- (void)setupWithTargetViewController:(UIViewController *)targetViewController;
{
    [super setupWithTargetViewController:targetViewController];
    
    // Disable original pop gesture since we have our own one
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;

    self.enabledVerticalMove = NO;
    self.enabledHorizontalMove = YES;
}

#pragma mark - Gesture Action
- (void)existCurrentViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Getters
- (UINavigationController *)navigationController
{
    if ([self.targetViewController isKindOfClass:[UINavigationController class]])
    {
        return (UINavigationController *)self.targetViewController;
    }
    
    return nil;
}

#pragma mark - Public
- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    return [[ICCommonNavigationAnimatedTransitioning alloc] initWithOperation:operation];
}

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController
{
    return self.interactiveTransition;
}

#pragma mark - Gesture Stuff
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.navigationController.viewControllers.count < 2) {
        return NO;
    }
    else
    {
        return [super gestureRecognizerShouldBegin:gestureRecognizer];
    }
}

@end
