//
//  ICCommonNavigationAnimationController.h
//  ICPageManager
//
//  Created by _ivanC on 3/11/16.
//  Copyright © 2016 _ivanC. All rights reserved.
//

#import <ICPageManager/ICCommonAnimationController.h>

@interface ICCommonNavigationAnimationController : ICCommonAnimationController

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController;

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC;

@end

