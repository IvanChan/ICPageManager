//
//  ICCommonAnimationController.m
//  ICPageManager
//
//  Created by _ivanC on 03/11/2017.
//

#import "ICCommonAnimationController.h"

#define VELOCITY_TRIGGER_VALUE  600

@interface ICCommonAnimationController ()

@property (nonatomic, strong) UIViewController *targetViewController;
@property (nonatomic, strong) UIPanGestureRecognizer *interactiveGestureRecognizer;

@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactiveTransition;
@property (nonatomic, assign) CGFloat progressX;
@property (nonatomic, assign) CGFloat progressY;

@property (nonatomic, assign) BOOL isMovingHorizontal;

@end

@implementation ICCommonAnimationController
@synthesize progressX = _progressX;
@synthesize progressY = _progressY;

#pragma mark - Lifecycle
- (instancetype)init
{
    if (self = [super init])
    {
        self.finishThreshold = 0.3;
    }
    return self;
}

- (void)reset
{
    self.targetViewController = nil;
    [self.targetViewController.view removeGestureRecognizer:self.interactiveGestureRecognizer];
    
    self.interactiveGestureRecognizer.delegate = nil;
    self.interactiveGestureRecognizer = nil;
}

- (void)setupWithTargetViewController:(UIViewController *)targetViewController;
{
    [self reset];
    
    self.targetViewController = targetViewController;
    self.interactiveGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleTransitionGesture:)];
    self.interactiveGestureRecognizer.delegate = self;
    [self.targetViewController.view addGestureRecognizer:self.interactiveGestureRecognizer];
    
    self.borderTriggerWidthHorizontal = IC_PAGEMANAGER_DEFAULT_BORDER_TRIGGER_WIDTH;
    self.borderTriggerWidthVertical = IC_PAGEMANAGER_DEFAULT_BORDER_TRIGGER_WIDTH;
}

#pragma mark - Gesture Action
- (void)existCurrentViewController
{
    // for sub-class implement
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
            
            _isMovingHorizontal = (!self.enabledVerticalMove ||  fabs(_progressY) < fabs(_progressX) );
            
            self.interactiveTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
            
            [self existCurrentViewController];
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
            
            __strong ICCommonAnimationController *strongSelf = self; // in case released during the delegate callback
            if ([strongSelf.delegate respondsToSelector:@selector(commonAnimationControllerDidFinishInteractiveTransition:isCanceled:)])
            {
                [strongSelf.delegate commonAnimationControllerDidFinishInteractiveTransition:self isCanceled:!finished];
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
        
        if (!directionEnabled
            || [self.targetViewController.transitionCoordinator isAnimated]
            || (!self.enabledVerticalMove && !self.enabledHorizontalMove)
            || (self.enabledHorizontalMove && !self.enabledVerticalMove && [gestureRecognizer locationInView:gestureRecognizer.view].x >= self.borderTriggerWidthHorizontal)
            || (!self.enabledHorizontalMove && self.enabledVerticalMove && [gestureRecognizer locationInView:gestureRecognizer.view].y > self.borderTriggerWidthVertical))
        {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer != self.interactiveGestureRecognizer)
    {
        return NO;
    }
    
    CGPoint touchPoint = [self.interactiveGestureRecognizer locationInView:self.targetViewController.view];
    
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
