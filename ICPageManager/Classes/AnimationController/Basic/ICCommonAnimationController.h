//
//  ICCommonAnimationController.h
//  ICPageManager
//
//  Created by _ivanC on 03/11/2017.
//

#import <Foundation/Foundation.h>

#define IC_PAGEMANAGER_DEFAULT_BORDER_TRIGGER_WIDTH    60     ///< Default border trigger width

@protocol ICCommonAnimationControllerDelegate;
@interface ICCommonAnimationController : NSObject <UIGestureRecognizerDelegate>
{
@protected
    CGFloat _progressX;
    CGFloat _progressY;
}

@property (nonatomic, weak) id<ICCommonAnimationControllerDelegate> delegate;

@property (nonatomic, strong, readonly) UIViewController *targetViewController;
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *interactiveGestureRecognizer;
@property (nonatomic, strong, readonly) UIPercentDrivenInteractiveTransition *interactiveTransition;

@property (nonatomic, assign) BOOL enabledHorizontalMove;
@property (nonatomic, assign) BOOL enabledVerticalMove;
@property (nonatomic, assign) CGFloat finishThreshold;      // [0, 1], Default is 0.3


// Default is IC_ANIMATION_DEFAULT_BORDER_TRIGGER_WIDTH
@property (nonatomic, assign) CGFloat borderTriggerWidthHorizontal;
@property (nonatomic, assign) CGFloat borderTriggerWidthVertical;


- (void)setupWithTargetViewController:(UIViewController *)targetViewController;

- (void)handleTransitionGesture:(UIPanGestureRecognizer *)recognizer;

@end

@protocol ICCommonAnimationControllerDelegate <NSObject>

@optional
- (void)commonAnimationControllerDidFinishInteractiveTransition:(ICCommonAnimationController *)animationController
                                                     isCanceled:(BOOL)isCanceled;

@end
