//
//  ICAViewController.m
//  ICPageManager_Example
//
//  Created by _ivanC on 17/10/2017.
//  Copyright © 2017 _ivanC. All rights reserved.
//

#import "ICAViewController.h"
#import "ICBViewController.h"

#import <ICPageManager/ICPageManager.h>

@interface ICAViewController ()

@property (nonatomic, strong) IBOutlet UIButton *pushButton;
@property (nonatomic, strong) IBOutlet UIButton *popButton;
@property (nonatomic, strong) IBOutlet UIButton *popToRootButton;

@end

@implementation ICAViewController

static int count = 1;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.view.backgroundColor = [UIColor colorWithRed:(arc4random()%255)/255.0 green:(arc4random()%255)/255.0 blue:(arc4random()%255)/255.0 alpha:1];
    
    self.textLabel.text = [NSString stringWithFormat:@"Sub-%@", @(count++)];
}

- (IBAction)pushClicked:(id)sender
{
    [[ICPageManager sharedManager] pushPageViewController:[ICAViewController new] animated:YES completion:^(UINavigationController *navigationController) {
        
        NSLog(@"pushPageViewController finished");
    }];
}

- (IBAction)popClicked:(id)sender
{
    [[ICPageManager sharedManager] popPageViewController:YES completion:^(UINavigationController *navigationController) {
        
        NSLog(@"popPageViewController finished");
    }];
}

- (IBAction)popToRootClicked:(id)sender
{
    [[ICPageManager sharedManager] popToRootPageViewController:YES completion:^(UINavigationController *navigationController) {
        
        NSLog(@"popToRootPageViewController finished");
    }];
}

- (IBAction)presentClicked:(id)sender
{
    [[ICPageManager sharedManager] presentPageViewController:[ICBViewController new] animated:YES completion:^{
        
        NSLog(@"presentViewController finished");
    }];
}

@end
