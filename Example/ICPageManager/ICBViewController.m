//
//  ICBViewController.m
//  ICPageManager_Example
//
//  Created by _ivanC on 17/10/2017.
//  Copyright © 2017 _ivanC. All rights reserved.
//

#import "ICBViewController.h"

@interface ICBViewController ()

@property (nonatomic, strong) IBOutlet UIButton *dismissButton;

@end

@implementation ICBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor colorWithRed:(arc4random()%255)/255.0 green:(arc4random()%255)/255.0 blue:(arc4random()%255)/255.0 alpha:1];
}

- (IBAction)dismissClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
        NSLog(@"dismissViewControllerAnimated finished");
    }];
}

@end
