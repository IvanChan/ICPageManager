//
//  ICViewController.m
//  ICPageManager
//
//  Created by _ivanC on 10/17/2017.
//  Copyright (c) 2017 _ivanC. All rights reserved.
//

#import "ICViewController.h"
#import "ICAViewController.h"
#import <ICPageManager/ICPageManager.h>

@interface ICViewController ()

@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation ICViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    ICAViewController *rootVC = [ICAViewController new];
    [rootVC view];
    rootVC.textLabel.text = @"Root";
    [[ICPageManager sharedManager] setupWithRootViewController:rootVC];
    
    [self.view addSubview:[ICPageManager sharedManager].pageWindow];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
