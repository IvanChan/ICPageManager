//
//  ICPagePresentAnimationController.m
//  ICPageManager
//
//  Created by _ivanC on 03/11/2017.
//

#import "ICPagePresentAnimationController.h"
#import "ICAnimatedPage.h"

@implementation ICPagePresentAnimationController

#pragma mark - Lifecycle
- (void)setupWithTargetViewController:(UIViewController *)targetViewController
{
    [super setupWithTargetViewController:targetViewController];
    
    UIViewController<ICAnimatedPage> *responsablePageAnimationController = nil;
    if ([targetViewController conformsToProtocol:@protocol(ICAnimatedPage)])
    {
        responsablePageAnimationController = (UIViewController<ICAnimatedPage> *)targetViewController;
    }
    
    if ([responsablePageAnimationController respondsToSelector:@selector(borderTriggerWidthHorizontal)])
    {
        self.borderTriggerWidthHorizontal = [responsablePageAnimationController borderTriggerWidthHorizontal];
    }

    if ([responsablePageAnimationController respondsToSelector:@selector(borderTriggerWidthVertical)])
    {
        self.borderTriggerWidthVertical = [responsablePageAnimationController borderTriggerWidthVertical];
    }
    
    // Update Gesture direction
    if ([responsablePageAnimationController respondsToSelector:@selector(supportedPageGestureDirection)])
    {
        PageGestureDirection supportedPageGestureDirection = [responsablePageAnimationController supportedPageGestureDirection];
        
        self.enabledHorizontalMove = (supportedPageGestureDirection & PageGestureDirectionHorizontal);
        self.enabledVerticalMove = (supportedPageGestureDirection & PageGestureDirectionVertical);
    }

    targetViewController.transitioningDelegate = self;
}

#pragma mark - UIViewControllerTransitioningDelegate
- (nullable id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                           presentingController:(UIViewController *)presenting
                                                                               sourceController:(UIViewController *)source
{
    UIViewController<UIViewControllerTransitioningDelegate> *animatedViewController = (UIViewController<UIViewControllerTransitioningDelegate> *)presented;
    if ([animatedViewController respondsToSelector:@selector(animationControllerForPresentedController:presentingController:sourceController:)]) {
        return [animatedViewController animationControllerForPresentedController:presented presentingController:presenting sourceController:source];
    }
    else
    {
        return [super animationControllerForPresentedController:presented presentingController:presenting sourceController:source];
    }
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    UIViewController<UIViewControllerTransitioningDelegate> *animatedViewController = (UIViewController<UIViewControllerTransitioningDelegate> *)dismissed;
    if ([animatedViewController respondsToSelector:@selector(animationControllerForDismissedController:)]) {
        return [animatedViewController animationControllerForDismissedController:dismissed];
    }
    else
    {
        return [super animationControllerForDismissedController:dismissed];
    }
}

@end
