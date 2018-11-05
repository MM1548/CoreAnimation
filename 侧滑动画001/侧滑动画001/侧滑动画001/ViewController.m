//
//  ViewController.m
//  侧滑动画001
//
//  Created by Dean on 2018/7/12.
//  Copyright © 2018年 tz. All rights reserved.
//

#import "ViewController.h"
#import "slideMenuView.h"
@interface ViewController ()
@property (nonatomic, strong) slideMenuView *menuView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _menuView = [[slideMenuView alloc] initWithBtnTitle:@[@"1", @"2", @"3", @"4", @"5"]];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)switchAction:(id)sender {
    [_menuView switchAcition];
}


@end
