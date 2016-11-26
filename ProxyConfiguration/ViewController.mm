//
//  ViewController.m
//  ProxyConfiguration
//
//  Created by wangqianzhou on 26/11/2016.
//  Copyright © 2016 alibaba-inc. All rights reserved.
//

#import "ViewController.h"
#import "ProxyConfiguration.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return 0;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)onSetBtnClick:(id)sender
{
    NSString* host = @"100.84.251.216";
    NSUInteger port = 8888;
    
    [ProxyConfigurationUtils setProxyWithHost:host port:port];
}

- (IBAction)onResetBtnClick:(id)sender
{
    [ProxyConfigurationUtils disableProxy];
}
@end
