#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "ICCommonAnimationController.h"
#import "ICCommonNavigationAnimationController.h"
#import "ICCommonPresentAnimationController.h"
#import "ICPageNaviAnimationController.h"
#import "ICPagePresentAnimationController.h"
#import "ICCommonNavigationAnimatedTransitioning.h"
#import "ICCommonPresentAnimatedTransitioning.h"
#import "ICAnimatedPage.h"
#import "ICPageManager.h"

FOUNDATION_EXPORT double ICPageManagerVersionNumber;
FOUNDATION_EXPORT const unsigned char ICPageManagerVersionString[];

