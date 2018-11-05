//
//  slideMenuBtn.h
//  侧滑动画001
//
//  Created by Dean on 2018/7/12.
//  Copyright © 2018年 tz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface slideMenuBtn : UIView

- (id)initWithTitle:(NSString *)title;

@property (nonatomic, copy) void (^btnClickBlock)(void);
@end
