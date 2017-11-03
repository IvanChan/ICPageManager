//
//  ICPagePresentAnimationController.m
//  ICPageManager
//
//  Created by _ivanC on 03/11/2017.
//

#import "ICPagePresentAnimationController.h"
#import "ICAnimatedPage.h"

@implementation ICPagePresentAnimationController

- (void)setupWithTargetViewController:(UIViewController *)targetViewController
{
    [super setupWithTargetViewController:targetViewController];
    
    UIViewController<ICAnimatedPage> *responsablePageAnimationController = nil;
    if ([targetViewController conformsToProtocol:@protocol(ICAnimatedPage)])
    {
        responsablePageAnimationController = (UIViewController<ICAnimatedPage> *)targetViewController;
    }
    
    if ([responsablePageAnimationController respondsToSelector:@selector(borderTriggerWidthHorizontal)])
    {
        self.borderTriggerWidthHorizontal = [responsablePageAnimationController borderTriggerWidthHorizontal];
    }

    
    if ([responsablePageAnimationController respondsToSelector:@selector(borderTriggerWidthVertical)])
    {
        self.borderTriggerWidthVertical = [responsablePageAnimationController borderTriggerWidthVertical];
    }
    
    // Update Gesture direction
    if ([responsablePageAnimationController respondsToSelector:@selector(supportedPageGestureDirection)])
    {
        PageGestureDirection supportedPageGestureDirection = [responsablePageAnimationController supportedPageGestureDirection];
        
        self.enabledHorizontalMove = (supportedPageGestureDirection & PageGestureDirectionHorizontal);
        self.enabledVerticalMove = (supportedPageGestureDirection & PageGestureDirectionVertical);
    }

}

@end
