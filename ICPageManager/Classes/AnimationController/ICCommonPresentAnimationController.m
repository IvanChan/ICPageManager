//
//  ICCommonPresentAnimationControllerDelegate.m
//  ICPageManager
//
//  Created by _ivanC on 3/11/16.
//  Copyright © 2016 _ivanC. All rights reserved.
//

#import "ICCommonPresentAnimationController.h"
#import "ICCommonNavigationAnimatedTransitioning.h"

#define BORDER_TRIGGER_WIDTH	30	 ///< 边界的热区大小
#define VELOCITY_TRIGGER_VALUE  600

@interface ICCommonPresentAnimationController ()

@property (nonatomic, strong) UIViewController *presentedViewController;
@property (nonatomic, strong) UIPanGestureRecognizer *interactiveGestureRecognizer;

@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactiveTransition;
@property (nonatomic, assign) CGFloat progressX;
@property (nonatomic, assign) CGFloat progressY;
//@property (nonatomic, assign) BOOL isMovingHorizontal;

@end

@implementation ICCommonPresentAnimationController

#pragma mark - Lifecycle
- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController
{
    if (self = [super init])
    {
        self.presentedViewController = presentedViewController;
        self.interactiveGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleTransitionGesture:)];
        self.interactiveGestureRecognizer.delegate = self;
        [self.presentedViewController.view addGestureRecognizer:self.interactiveGestureRecognizer];
        
        self.enabledHorizontalMove = YES;
        
        self.finishThreshold = 0.3;
        self.borderTriggerWidthHorizontal = BORDER_TRIGGER_WIDTH;
        self.borderTriggerWidthVertical = BORDER_TRIGGER_WIDTH;
    }
    return self;
}

#pragma mark - UIViewControllerTransitioningDelegate
- (nullable id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    return [[ICCommonNavigationAnimatedTransitioning alloc] initWithOperation:UINavigationControllerOperationPush];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [[ICCommonNavigationAnimatedTransitioning alloc] initWithOperation:UINavigationControllerOperationPop];
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

#pragma mark - Gesture Stuff
- (void)handleTransitionGesture:(UIPanGestureRecognizer *)recognizer
{
    _progressX = [recognizer translationInView:recognizer.view].x / recognizer.view.frame.size.width;
    _progressY = [recognizer translationInView:recognizer.view].y / recognizer.view.frame.size.height;
        
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            assert(self.enabledVerticalMove || self.enabledHorizontalMove);
            
            _isMovingHorizontal = (!self.enabledVerticalMove ||  fabs(_progressY) < fabs(_progressX) );

            self.interactiveTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
            [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            if (_isMovingHorizontal)
            {
                [self.interactiveTransition updateInteractiveTransition:_progressX];
            }
            else
            {
                [self.interactiveTransition updateInteractiveTransition:_progressY];
            }
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            CGFloat progress = _progressX;
            CGFloat velocity = [recognizer velocityInView:recognizer.view].x;
            if (!_isMovingHorizontal)
            {
                progress = _progressY;
                velocity = [recognizer velocityInView:recognizer.view].y;
            }
            
            BOOL finished = (progress > self.finishThreshold || velocity > VELOCITY_TRIGGER_VALUE);
            if (finished)
            {
                [self.interactiveTransition finishInteractiveTransition];
            }
            else
            {
                [self.interactiveTransition cancelInteractiveTransition];
            }
            
            __strong ICCommonPresentAnimationController *strongSelf = self;
            if ([strongSelf.delegate respondsToSelector:@selector(commonPresentAnimationControllerDidFinishInteractiveTransition:isCanceled:)])
            {
                [strongSelf.delegate commonPresentAnimationControllerDidFinishInteractiveTransition:self isCanceled:!finished];
            }
            
            self.interactiveTransition = nil;
            _progressX = 0;
            _progressY = 0;
        }
            break;
        default:
            break;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    BOOL directionEnabled = YES;
    if (gestureRecognizer == self.interactiveGestureRecognizer)
    {
        CGPoint translate = [self.interactiveGestureRecognizer translationInView:self.interactiveGestureRecognizer.view];
        
        BOOL xMoved = fabs(translate.x) > 0.01;
        BOOL yMoved = fabs(translate.y) > 0.01;

        directionEnabled = ((self.enabledHorizontalMove && xMoved) || (self.enabledVerticalMove && yMoved));
    }
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer != self.interactiveGestureRecognizer)
    {
        return NO;
    }
    
    CGPoint touchPoint = [self.interactiveGestureRecognizer locationInView:self.presentedViewController.view];

    CGFloat transX = [gestureRecognizer translationInView:gestureRecognizer.view].x;
    CGFloat transY = [gestureRecognizer translationInView:gestureRecognizer.view].y;

    // We dealing with our gesture in high priority when touch in border-trigger-zone & fail other gesture
    if ( (self.enabledHorizontalMove && fabs(transX) > fabs(transY) && touchPoint.x < self.borderTriggerWidthHorizontal )
        ||  (self.enabledVerticalMove && fabs(transX) < fabs(transY) && touchPoint.y < self.borderTriggerWidthVertical) )
    {
        BOOL enabled = otherGestureRecognizer.enabled;
        UIGestureRecognizerState state = otherGestureRecognizer.state;
        if (enabled && (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged))
        {
            otherGestureRecognizer.enabled = NO;
            otherGestureRecognizer.enabled = enabled;
            //if a gesture fail one and another,the performance of client will be decreased enormously
            return NO;
        }
    }
    
    return NO;
}

@end
