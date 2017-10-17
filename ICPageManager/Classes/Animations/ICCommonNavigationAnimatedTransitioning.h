//
//  ICCommonNavigationAnimatedTransitioning.h
//  ICPageManager
//
//  Created by _ivanC on 3/4/16.
//  Copyright © 2016 _ivanC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICCommonNavigationAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>

- (instancetype)initWithOperation:(UINavigationControllerOperation)operation;

@end
