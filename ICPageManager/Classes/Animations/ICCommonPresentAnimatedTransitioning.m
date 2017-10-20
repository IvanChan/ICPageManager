//
//  ICCommonPresentAnimatedTransitioning.m
//  ICPageManager
//
//  Created by _ivanC on 3/4/16.
//  Copyright © 2016 _ivanC. All rights reserved.
//

#import "ICCommonPresentAnimatedTransitioning.h"

@interface ICCommonPresentAnimatedTransitioning ()

@property (nonatomic, assign) ICPresentationOperation operation;
@property (nonatomic, strong) UIView *backgroundMaskView;

@end

@implementation ICCommonPresentAnimatedTransitioning

#pragma mark - Lifecycle
- (instancetype)initWithOperation:(ICPresentationOperation)operation
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
    [containerView addSubview:self.backgroundMaskView];

    CGFloat maskFromAlpha = 0;
    CGFloat maskToAlpha = 0.4;

    if (self.operation == ICPresentationOperationPresent)
    {
        CGRect rect = containerView.bounds;
        rect.origin.y = CGRectGetMaxY(rect);
        toViewController.view.frame = rect;
        [containerView addSubview:toViewController.view];
    }
    else
    {
        maskFromAlpha = 0.4;
        maskToAlpha = 0;
        
        toViewController.view.transform = CGAffineTransformIdentity;
        toViewController.view.frame = containerView.bounds;
        [containerView addSubview:toViewController.view];
        
        [containerView bringSubviewToFront:self.backgroundMaskView];
        [containerView bringSubviewToFront:fromViewController.view];

    }
    self.backgroundMaskView.alpha = maskFromAlpha;
    
    if (![transitionContext isInteractive])
    {
        [CATransaction begin];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         
                         self.backgroundMaskView.alpha = maskToAlpha;
                         
                         if (self.operation == ICPresentationOperationPresent)
                         {
                             toViewController.view.frame = containerView.bounds;
                         }
                         else
                         {
                             CGRect rect = containerView.bounds;
                             rect.origin.y = CGRectGetMaxY(rect);
                             fromViewController.view.frame = rect;
                         }
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
