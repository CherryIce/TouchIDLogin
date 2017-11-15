//
//  ViewController.m
//  TouchIDLogin
//
//  Created by Macx on 2017/11/15.
//  Copyright © 2017年 Macx. All rights reserved.
//

#import "ViewController.h"

#import "LonginViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loginAuthentication];
}

/**
 登录认证
 */
- (void) loginAuthentication
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"token"] isEqualToString:@"no"]) {
        LonginViewController* loginControll = [[LonginViewController alloc] initWithNibName:@"LonginViewController" bundle:nil];
        [self presentViewController:loginControll animated:YES completion:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"登录成功!";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
