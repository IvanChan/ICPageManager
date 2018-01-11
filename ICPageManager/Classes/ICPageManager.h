//
//  ICPageManager.h
//  ICPageManager
//
//  Created by _ivanC on 4/15/16.
//  Copyright © 2016 _ivanC. All rights reserved.
//


#import <UIKit/UIKit.h>

typedef void(^ICPageManagerCompletionBlock)(UINavigationController *navigationController);

@interface ICPageManager : NSObject

+ (instancetype)sharedManager;
- (void)setupWithRootViewController:(UIViewController *)rootViewController;

- (UIView *)pageWindow;
- (UIViewController *)pageWindowController;

- (UIViewController *)topViewController;
- (NSArray<__kindof UIViewController *> *)viewControllers;

- (void)pushPageViewController:(UIViewController *)pageViewController animated:(BOOL)animated completion:(void (^)(UINavigationController *navigationController))completion;
- (void)popPageViewController:(BOOL)animated completion:(ICPageManagerCompletionBlock)completion;
- (void)popToRootPageViewController:(BOOL)animated completion:(ICPageManagerCompletionBlock)completion;
- (void)popToViewController:(UIViewController *)pageViewController animated:(BOOL)animated completion:(ICPageManagerCompletionBlock)completion;

- (void)presentPageViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)animated completion:(void (^)(void))completion;

@end
