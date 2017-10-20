//
//  ICCommonNavigationAnimatedTransitioning.m
//  ICPageManager
//
//  Created by _ivanC on 3/4/16.
//  Copyright © 2016 _ivanC. All rights reserved.
//

#import "ICCommonNavigationAnimatedTransitioning.h"

@interface ICCommonNavigationAnimatedTransitioning ()

@property (nonatomic, assign) UINavigationControllerOperation operation;
@property (nonatomic, strong) UIView *backgroundMaskView;

@end

@implementation ICCommonNavigationAnimatedTransitioning

- (instancetype)initWithOperation:(UINavigationControllerOperation)operation
{
    if (self = [super init])
    {
        self.operation = operation;
    }
    
    return self;
}

#pragma mark - Getters
- (UIView *)backgroundMaskView
{
    if (_backgroundMaskView == nil)
    {
        _backgroundMaskView = [[UIView alloc] initWithFrame:CGRectZero];
        _backgroundMaskView.backgroundColor = [UIColor blackColor];
    }
    return _backgroundMaskView;
}

#pragma mark - UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3f;//[transitionContext isInteractive] ? 0.3f : 0.5f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    assert(self.operation);
    
    UIView *containerView = [transitionContext containerView];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    self.backgroundMaskView.frame = containerView.bounds;
    
    CGFloat maskFromAlpha = 0;
    CGFloat maskToAlpha = 0.2;
    
    if (self.operation == UINavigationControllerOperationPush)
    {
        [containerView addSubview:self.backgroundMaskView];

        CGRect rect = containerView.bounds;
        rect.origin.x = CGRectGetWidth(rect);
        toViewController.view.frame = rect;
        [containerView addSubview:toViewController.view];
    }
    else
    {
        maskFromAlpha = 0.2;
        maskToAlpha = 0;
        
        CGRect rect = containerView.bounds;
        rect.origin.x = - CGRectGetWidth(rect)/3.0;
        toViewController.view.frame = rect;
        toViewController.view.transform = CGAffineTransformIdentity;

        [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
        [containerView insertSubview:self.backgroundMaskView belowSubview:fromViewController.view];

    }
    
    self.backgroundMaskView.alpha = maskFromAlpha;

    
    if (![transitionContext isInteractive])
    {
        [CATransaction begin];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         
                         self.backgroundMaskView.alpha = maskToAlpha;

                         if (self.operation == UINavigationControllerOperationPush)
                         {
                             CGRect rect = containerView.bounds;
                             rect.origin.x = - CGRectGetWidth(rect)/3.0;
                             fromViewController.view.frame = rect;
                         }
                         else
                         {
                             CGRect rect = containerView.bounds;
                             rect.origin.x = CGRectGetWidth(rect);
                             fromViewController.view.frame = rect;
                         }
                         toViewController.view.frame = containerView.bounds;

                     }
                     completion:^(BOOL finished){

                         [self.backgroundMaskView removeFromSuperview];
                         self.backgroundMaskView = nil;
                         
                         BOOL isCanceled = [transitionContext transitionWasCancelled];
                         if (isCanceled)
                         {
                             [toViewController.view removeFromSuperview];
                         }
                         else
                         {
                             [fromViewController.view removeFromSuperview];
                         }
                         
                         [transitionContext completeTransition:!isCanceled];
                     }];
    
    if (![transitionContext isInteractive])
    {
        [CATransaction commit];
    }
}

@end
