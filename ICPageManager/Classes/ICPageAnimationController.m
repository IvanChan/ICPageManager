//
//  ICPageAnimationController.m
//  ICPageManager
//
//  Created by _ivanC on 1/20/16.
//  Copyright © 2016 _ivanC. All rights reserved.
//

#import "ICPageAnimationController.h"
#import "ICAnimatedPage.h"

#import "ICCommonNavigationAnimatedTransitioning.h"

@interface ICPageAnimationController ()

@property (nonatomic, strong) UIViewController<ICAnimatedPage> *mightBecomeActiveViewController;
@property (nonatomic, strong) UIViewController *currentActiveViewController;

@end

@implementation ICPageAnimationController

#pragma mark - Lifecycle
- (instancetype)initWithNavigationController:(UINavigationController *)navigationController
{
    if (self = [super initWithNavigationController:navigationController])
    {
        self.enabledVerticalMove = YES;
        self.borderTriggerWidthVertical = 0;
    }
    return self;
}

#pragma mark - Public
- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    id<UIViewControllerAnimatedTransitioning> result = nil;
    self.mightBecomeActiveViewController = nil;
    
    // We ask for the current view controller for customized anmation whether push or pop
    // In order to keep logic in the same view controller
    UIViewController *responsableViewController = operation == UINavigationControllerOperationPush ? toVC : fromVC;
    UIViewController<ICAnimatedPage> *responsablePageAnimationController = nil;
    if ([responsableViewController conformsToProtocol:@protocol(ICAnimatedPage)])
    {
        responsablePageAnimationController = (UIViewController<ICAnimatedPage> *)responsableViewController;
        self.mightBecomeActiveViewController = responsablePageAnimationController;
    }
        
    // Ask if there is customized animation for different page
    if (responsablePageAnimationController)
    {
        if ([responsablePageAnimationController respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)])
        {
            result = [responsablePageAnimationController navigationController:navigationController
                                              animationControllerForOperation:operation
                                                           fromViewController:fromVC
                                                             toViewController:toVC];
        }
    }
    
    if (result == nil)
    {
        // Default animation
        result = [[ICCommonNavigationAnimatedTransitioning alloc] initWithOperation:operation];
    }
    
    return result;
}

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController
{
    id <UIViewControllerInteractiveTransitioning> result = nil;
    if ([self.mightBecomeActiveViewController respondsToSelector:@selector(navigationController:interactionControllerForAnimationController:)])
    {
        result = [self.mightBecomeActiveViewController navigationController:navigationController interactionControllerForAnimationController:animationController];
    }
    
    if (result == nil)
    {
        result = [super navigationController:navigationController interactionControllerForAnimationController:animationController];
    }
    
    return result;
}

- (void)updateStateWithViewController:(UIViewController *)viewController
{
    self.mightBecomeActiveViewController = nil;
    
    self.currentActiveViewController = viewController;
    UIViewController<ICAnimatedPage> *animatedPageAnimationController = nil;
    if ([viewController conformsToProtocol:@protocol(ICAnimatedPage)])
    {
        animatedPageAnimationController = (UIViewController<ICAnimatedPage> *)viewController;
    }
    
    // Update Gesture direction
    {
        PageGestureDirection supportedPageGestureDirection = PageGestureDirectionHorizontal;
        if (animatedPageAnimationController)
        {
            supportedPageGestureDirection = [animatedPageAnimationController supportedPageGestureDirection];
        }
        
        self.enabledHorizontalMove = (supportedPageGestureDirection & PageGestureDirectionHorizontal);
        self.enabledVerticalMove = (supportedPageGestureDirection & PageGestureDirectionVertical);
    }
    
    // Update trigger width
    {
        if ([animatedPageAnimationController respondsToSelector:@selector(borderTriggerWidthHorizontal)])
        {
            self.borderTriggerWidthHorizontal = [animatedPageAnimationController borderTriggerWidthHorizontal];
        }
        else
        {
            self.borderTriggerWidthHorizontal = 30;
        }
        
        if ([animatedPageAnimationController respondsToSelector:@selector(borderTriggerWidthVertical)])
        {
            self.borderTriggerWidthVertical = [animatedPageAnimationController borderTriggerWidthVertical];
        }
        else
        {
            self.borderTriggerWidthVertical = 30;
        }
    }
}

#pragma mark - Gesture Stuff
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
     // Update Gesture direction
    UIViewController<ICAnimatedPage> *animatedPageAnimationController = nil;
    if ([self.currentActiveViewController conformsToProtocol:@protocol(ICAnimatedPage)])
    {
        animatedPageAnimationController = (UIViewController<ICAnimatedPage> *)self.currentActiveViewController;
    }
    PageGestureDirection supportedPageGestureDirection = PageGestureDirectionHorizontal;
    if (animatedPageAnimationController)
    {
        supportedPageGestureDirection = [animatedPageAnimationController supportedPageGestureDirection];
    }
    
    self.enabledHorizontalMove = (supportedPageGestureDirection & PageGestureDirectionHorizontal);
    self.enabledVerticalMove = (supportedPageGestureDirection & PageGestureDirectionVertical);
    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}


- (void)handleTransitionGesture:(UIPanGestureRecognizer *)recognizer
{
    UIViewController<ICAnimatedPage> *animatedPageAnimationController = nil;
    if ([self.currentActiveViewController conformsToProtocol:@protocol(ICAnimatedPage)])
    {
        animatedPageAnimationController = (UIViewController<ICAnimatedPage> *)self.currentActiveViewController;
    }
    
    BOOL handled = NO;
    if ([animatedPageAnimationController respondsToSelector:@selector(handleTransitionGesture:completion:)])
    {
        handled = [animatedPageAnimationController handleTransitionGesture:recognizer
                                                                completion:^(BOOL isCanceled){
                                                                    if ([self.delegate respondsToSelector:@selector(commonNavigationAnimationControllerDidFinishInteractiveTransition:isCanceled:)])
                                                                    {
                                                                        [self.delegate commonNavigationAnimationControllerDidFinishInteractiveTransition:self
                                                                                                                                              isCanceled:isCanceled];
                                                                    }
                                                                }];
    }
    
    if (!handled)
    {
        [super handleTransitionGesture:recognizer];
    }
}

@end
