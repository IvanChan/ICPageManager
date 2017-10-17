//
//  ICCommonNavigationAnimationController.m
//  ICPageManager
//
//  Created by _ivanC on 3/11/16.
//  Copyright © 2016 _ivanC. All rights reserved.
//

#import "ICCommonNavigationAnimationController.h"
#import "ICCommonNavigationAnimatedTransitioning.h"

#define BORDER_TRIGGER_WIDTH	30	 ///< 边界的热区大小
#define VELOCITY_TRIGGER_VALUE  600

@interface ICCommonNavigationAnimationController ()

@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) UIPanGestureRecognizer *interactiveGestureRecognizer; 

@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactiveTransition;
@property (nonatomic, assign) CGFloat progressX;
@property (nonatomic, assign) CGFloat progressY;
@property (nonatomic, assign) BOOL isMovingHorizontal;

@end

@implementation ICCommonNavigationAnimationController
@synthesize progressX = _progressX;
@synthesize progressY = _progressY;

#pragma mark - Lifecycle
- (instancetype)initWithNavigationController:(UINavigationController *)navigationController
{
    if (self = [super init])
    {
        self.navigationController = navigationController;
        self.interactiveGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleTransitionGesture:)];
        self.interactiveGestureRecognizer.delegate = self;
        [self.navigationController.view addGestureRecognizer:self.interactiveGestureRecognizer];
        
        // Disable original pop gesture since we have our own one
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        
        self.enabledHorizontalMove = YES;
        
        self.finishThreshold = 0.3;
        self.borderTriggerWidthHorizontal = BORDER_TRIGGER_WIDTH;
        self.borderTriggerWidthVertical = BORDER_TRIGGER_WIDTH;
    }
    return self;
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
- (void)handleTransitionGesture:(UIPanGestureRecognizer *)recognizer
{
    _progressX = [recognizer translationInView:recognizer.view].x / recognizer.view.frame.size.width;
    _progressY = [recognizer translationInView:recognizer.view].y / recognizer.view.frame.size.height;
    
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            assert(self.enabledVerticalMove || self.enabledHorizontalMove);
            
            _isMovingHorizontal = !self.enabledVerticalMove || (self.enabledHorizontalMove &&  fabs(_progressY) <= fabs(_progressX) );

            self.interactiveTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
            [self.navigationController popViewControllerAnimated:YES];
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
            
            __strong ICCommonNavigationAnimationController *strongSelf = self;
            if ([strongSelf.delegate respondsToSelector:@selector(commonNavigationAnimationControllerDidFinishInteractiveTransition:isCanceled:)])
            {
                [strongSelf.delegate commonNavigationAnimationControllerDidFinishInteractiveTransition:self isCanceled:!finished];
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
    
    if (!directionEnabled
        || [self.navigationController.transitionCoordinator isAnimated]
        || self.navigationController.viewControllers.count < 2
        || (!self.enabledVerticalMove && !self.enabledHorizontalMove)
        || (self.enabledHorizontalMove && !self.enabledVerticalMove && [gestureRecognizer locationInView:gestureRecognizer.view].x >= self.borderTriggerWidthHorizontal)
        || (!self.enabledHorizontalMove && self.enabledVerticalMove && [gestureRecognizer locationInView:gestureRecognizer.view].y > self.borderTriggerWidthVertical))
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer != self.interactiveGestureRecognizer)
    {
        return NO;
    }
    
    CGPoint touchPoint = [self.interactiveGestureRecognizer locationInView:self.navigationController.view];
    
    CGFloat transX = [gestureRecognizer translationInView:gestureRecognizer.view].x;
    CGFloat transY = [gestureRecognizer translationInView:gestureRecognizer.view].y;

    // We dealing with our gesture in high priority when touch in border-trigger-zone & fail other gesture
    if ( (self.enabledHorizontalMove && fabs(transX) > fabs(transY) && touchPoint.x < self.borderTriggerWidthHorizontal )
        ||  (self.enabledVerticalMove && fabs(transX) < fabs(transY) && touchPoint.y < self.borderTriggerWidthVertical) )
    {
        BOOL enabled = otherGestureRecognizer.enabled;
        UIGestureRecognizerState state = otherGestureRecognizer.state;
        //设置界面从从边缘触发的时候会把其他手势吃掉，因此在导航控制器的根控制器里不需要屏蔽其他手势
        if (enabled && (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged) && self.navigationController.viewControllers.count > 1)
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
