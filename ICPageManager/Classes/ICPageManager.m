//
//  ICPageManager.m
//  ICPageManager
//
//  Created by _ivanC on 4/15/16.
//  Copyright © 2016 _ivanC. All rights reserved.
//

#import "ICPageManager.h"
#import "ICPageNaviAnimationController.h"
#import "ICPagePresentAnimationController.h"

@interface ICPageManagerCompletionInfo : NSObject

@property (nonatomic, copy) ICPageManagerCompletionBlock completionBlock;
@property (nonatomic, strong) UIViewController *relativeViewController;

@end

@implementation ICPageManagerCompletionInfo

@end

@interface ICPageManager () <UINavigationControllerDelegate, ICCommonAnimationControllerDelegate>

@property (nonatomic, strong) UINavigationController *mainNavigationController;
@property (nonatomic, strong) ICPageNaviAnimationController *naviAnimationController;
@property (nonatomic, strong) ICPagePresentAnimationController *presentAnimationController;

@property (nonatomic, strong) NSMutableDictionary *completionBlockHash;

@end

@implementation ICPageManager

#pragma mark - Lifecycle
+ (nullable instancetype)sharedManager
{
    static ICPageManager *s_instance = nil;
    
    if (s_instance == nil)
    {
        @synchronized(self)
        {
            if (s_instance == nil)
            {
                s_instance = [[self alloc] init];
            }
        }
    }
    
    return s_instance;
}

#pragma mark - Setters
- (void)setupWithRootViewController:(UIViewController *)rootViewController
{
    self.mainNavigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController] ;
    self.mainNavigationController.navigationBarHidden = YES;
    
    [self.naviAnimationController setupWithTargetViewController:self.mainNavigationController];
}

#pragma mark - Getters
- (ICPageNaviAnimationController *)naviAnimationController
{
    if (_naviAnimationController == nil)
    {
        _naviAnimationController = [ICPageNaviAnimationController new];
        _naviAnimationController.delegate = self;
    }
    return _naviAnimationController;
}

- (ICPagePresentAnimationController *)presentAnimationController
{
    if (_presentAnimationController == nil)
    {
        _presentAnimationController = [ICPagePresentAnimationController new];
        _presentAnimationController.delegate = self;
    }
    return _presentAnimationController;
}

- (NSMutableDictionary *)completionBlockHash
{
    if (_completionBlockHash == nil)
    {
        _completionBlockHash = [[NSMutableDictionary alloc] initWithCapacity:3];
    }
    return _completionBlockHash;
}

- (nonnull UIViewController *)currentPageViewController
{
    return [self.mainNavigationController topViewController];
}

- (nonnull UIView *)pageWindow
{
    return self.mainNavigationController.view;
}

- (nonnull UIViewController *)topViewController
{
    return [self.mainNavigationController topViewController];
}

- (nullable NSArray<__kindof UIViewController *> *)viewControllers
{
    return [[self.mainNavigationController viewControllers] copy];
}

#pragma mark - Completion Logic
- (void)addCompletionCallback:(ICPageManagerCompletionBlock)completionCallbackBlock
            forViewController:(UIViewController *)viewController
{
    if (viewController == nil || completionCallbackBlock == nil)
    {
        return;
    }
    
    ICPageManagerCompletionInfo *completionInfo = [ICPageManagerCompletionInfo new];
    completionInfo.completionBlock = completionCallbackBlock;
    
    completionInfo.relativeViewController = [self.mainNavigationController.viewControllers lastObject];
    
    NSString *key = [NSString stringWithFormat:@"%p", viewController];
    self.completionBlockHash[key] = completionInfo;
}

- (void)flushCompletionCallbackForViewController:(UIViewController *)viewController
{
    if (viewController == nil)
    {
        return;
    }
    
    NSString *key = [NSString stringWithFormat:@"%p", viewController];
    
    ICPageManagerCompletionInfo *completionInfo = self.completionBlockHash[key];
    if (completionInfo && completionInfo.completionBlock)
    {
        completionInfo.completionBlock(self.mainNavigationController);
        [self.completionBlockHash removeObjectForKey:key];
    }
}

#pragma mark - Convinient api
- (void)pushPageViewController:(nonnull UIViewController *)pageViewController animated:(BOOL)animated completion:(ICPageManagerCompletionBlock)completion
{
    self.mainNavigationController.delegate = self;

    [self addCompletionCallback:completion
              forViewController:pageViewController];
    
    [self.mainNavigationController pushViewController:pageViewController
                                             animated:animated];
}

- (void)popPageViewController:(BOOL)animated completion:(ICPageManagerCompletionBlock)completion
{
    NSArray *viewControllerArray = [self.mainNavigationController viewControllers];
    if ([viewControllerArray count] > 1)
    {
        UIViewController *viewController = [viewControllerArray objectAtIndex:[viewControllerArray count] - 2];
        
        [self addCompletionCallback:completion
                  forViewController:viewController];
    }
    
    [self.mainNavigationController popViewControllerAnimated:animated];
}

- (void)popToViewController:(UIViewController *)pageViewController animated:(BOOL)animated completion:(ICPageManagerCompletionBlock)completion
{
    [self addCompletionCallback:completion
              forViewController:pageViewController];

    [self.mainNavigationController popToViewController:pageViewController animated:animated];
}

- (void)popToRootPageViewController:(BOOL)animated completion:(void (^ __nullable)(UINavigationController * __nullable navigationController))completion
{
    UIViewController *rootViewController = [[self.mainNavigationController viewControllers] firstObject];
    
    [self addCompletionCallback:completion
              forViewController:rootViewController];
    
    [self.mainNavigationController popToRootViewControllerAnimated:animated];
}

- (void)presentPageViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)animated completion:(void (^)(void))completion
{
    UIViewController *appRootViewController = UIApplication.sharedApplication.delegate.window.rootViewController;
    if (appRootViewController.presentedViewController) {
        // Presenting view controllers on detached view controllers is discouraged
        assert(0);
        return;
    }
    
    [self.presentAnimationController setupWithTargetViewController:viewControllerToPresent];
    [appRootViewController presentViewController:viewControllerToPresent animated:animated completion:completion];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(nonnull UINavigationController *)navigationController willShowViewController:(nonnull UIViewController *)viewController animated:(BOOL)animated
{
}

- (void)navigationController:(nonnull UINavigationController *)navigationController didShowViewController:(nonnull UIViewController *)viewController animated:(BOOL)animated
{
    [self flushCompletionCallbackForViewController:viewController];
 
    [self.naviAnimationController updateStateWithViewController:viewController];
}

- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController
{
    return [self.naviAnimationController navigationController:navigationController interactionControllerForAnimationController:animationController];
}


- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(nonnull UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(nonnull UIViewController *)fromVC
                                                           toViewController:(nonnull UIViewController *)toVC
{
    return [self.naviAnimationController navigationController:navigationController
                          animationControllerForOperation:operation
                                       fromViewController:fromVC
                                         toViewController:toVC];
}

#pragma mark - CommonAnimationControllerDelegate
- (void)commonAnimationControllerDidFinishInteractiveTransition:(ICCommonAnimationController *)animationController
                                                               isCanceled:(BOOL)isCanceled
{
    if (animationController == self.naviAnimationController)
    {
        
    }
    else if (animationController == self.presentAnimationController)
    {
        
    }
}

@end
