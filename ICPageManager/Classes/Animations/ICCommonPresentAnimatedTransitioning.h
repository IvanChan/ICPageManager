//
//  ICCommonPresentAnimatedTransitioning.h
//  ICPageManager
//
//  Created by _ivanC on 3/4/16.
//  Copyright © 2016 _ivanC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ICPresentationOperation) {
    ICPresentationOperationNone = UINavigationControllerOperationNone,
    ICPresentationOperationPresent = UINavigationControllerOperationPush,
    ICPresentationOperationDismiss = UINavigationControllerOperationPop,
};

@interface ICCommonPresentAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>

- (instancetype)initWithOperation:(ICPresentationOperation)operation;

@end
