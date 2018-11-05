//
//  slideMenuView.m
//  侧滑动画001
//
//  Created by Dean on 2018/7/12.
//  Copyright © 2018年 tz. All rights reserved.
//
/*
 1.添加模糊背景
 2.划入菜单栏
 3.思考：如何让view动起来？多次绘制（动画基于绘制）
 4.通过2个辅助view，求出它们的插值，获取到一组动态的数据
 5.CADisplayLink
 6.添加按钮
 */
#define menuBlankWidth 50
#define menuBtnHeight 40
#define buttonSpace 30

#import "slideMenuView.h"
#import "slideMenuBtn.h"
@implementation slideMenuView
{
    UIVisualEffectView *blurView;
    UIView *helperSideView;
    UIView *helperCenterView;
    UIWindow *keyWindow;
    BOOL swiched;
    CGFloat diff;
    UIColor *menuColor;
    CADisplayLink *displayLink;
    NSInteger animationCount;
}
#pragma mark - lifeCycle
-(id)initWithBtnTitle:(NSArray *)btnTitles{
    self = [super init];
    if (self) {
        menuColor = [UIColor colorWithRed:0 green:0.722 blue:1 alpha:1];
        keyWindow = [UIApplication sharedApplication].keyWindow;
        blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        blurView.frame = keyWindow.frame;
        blurView.alpha = 0.5;
        self.frame =CGRectMake(-(CGRectGetWidth(keyWindow.frame)/2 + menuBlankWidth), 0, CGRectGetWidth(keyWindow.frame)/2 + menuBlankWidth, CGRectGetHeight(keyWindow.frame));
        self.backgroundColor = [UIColor clearColor];
        
//        [keyWindow addSubview:self];
        helperSideView = [[UIView alloc] initWithFrame:CGRectMake(-40, 0, 40, 40)];;
//        helperSideView.backgroundColor = [UIColor redColor];
        helperCenterView = [[UIView alloc] initWithFrame:CGRectMake(-40, CGRectGetHeight(keyWindow.bounds)/2-20, 40, 40)];;
//        helperCenterView.backgroundColor = [UIColor orangeColor];
        
        [keyWindow addSubview:helperSideView];
        [keyWindow addSubview:helperCenterView];
        [keyWindow insertSubview:self belowSubview:helperSideView];
        
        //添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)];
        [blurView addGestureRecognizer:tap];
        
        //添加按钮
        [self addBtnTitles:btnTitles];
        
    }
    return self;
   
}

- (void)drawRect:(CGRect)rect{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(keyWindow.frame)/2, 0)];
    [path addQuadCurveToPoint:CGPointMake(CGRectGetWidth(keyWindow.frame)/2, CGRectGetHeight(keyWindow.frame)) controlPoint:CGPointMake(CGRectGetWidth(keyWindow.frame)/2 + diff, CGRectGetHeight(keyWindow.frame)/2)];
    [path addLineToPoint:CGPointMake(0, CGRectGetHeight(keyWindow.frame))];
    [path closePath];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddPath(context, path.CGPath);
    [menuColor set];
    CGContextFillPath(context);
}

#pragma mark - func
- (void)addBtnAnim{
    for (int i = 0; i < self.subviews.count; i++) {
        UIView *btn = self.subviews[i];
        btn.transform = CGAffineTransformMakeTranslation(-100, 0);
        [UIView animateWithDuration:.7 delay:i*(0.3/self.subviews.count) usingSpringWithDamping:.6 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            btn.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
}
- (void)addBtnTitles:(NSArray *)titles{
    CGFloat space = (CGRectGetHeight(keyWindow.bounds) - titles.count*menuBtnHeight - (titles.count-1)*buttonSpace)/2;
    for (int i = 0; i < titles.count; i++) {
        slideMenuBtn *btn = [[slideMenuBtn alloc] initWithTitle:titles[i]];
        btn.center = CGPointMake(CGRectGetWidth(keyWindow.bounds)/4, space + menuBtnHeight*i + buttonSpace*i);
        btn.bounds = CGRectMake(0, 0, CGRectGetWidth(keyWindow.bounds)/2 - 20*2, menuBtnHeight);
        [self addSubview:btn];
    }
}
//添加定时器
- (void)getDiff{
    if (!displayLink) {
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction:)];
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
}
#pragma mark - Actions
//移除定时器
- (void)removeDisplayLink{
    [displayLink invalidate];
    displayLink = nil;
}
- (void)displayLinkAction:(CADisplayLink *)link{
//    NSLog(@"%@",NSStringFromCGRect(helperSideView.frame));
    CALayer *layer1 = helperSideView.layer.presentationLayer;
    CALayer *layer2 = helperCenterView.layer.presentationLayer;
    CGRect r1 = [[layer1 valueForKeyPath:@"frame"] CGRectValue];
    CGRect r2 = [[layer2 valueForKeyPath:@"frame"] CGRectValue];
    diff = r1.origin.x - r2.origin.x;
    NSLog(@"%f",diff);
    [self setNeedsDisplay];
    
    
  
}
//点击按钮
-(void)switchAcition{
    if (!swiched) {
        //1.添加模糊背景
        [keyWindow insertSubview:blurView belowSubview:self];
        //2.划入菜单栏
        [UIView animateWithDuration:.3 animations:^{
            self.frame = self.bounds;
            blurView.alpha = 1;
        }];
        //3.添加弹簧动画
        [UIView animateWithDuration:.7 delay:0 usingSpringWithDamping:.5 initialSpringVelocity:.9 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            helperSideView.center = CGPointMake(keyWindow.center.x, CGRectGetHeight(helperSideView.bounds)/2);
        } completion:nil];
        [UIView animateWithDuration:.7 delay:0 usingSpringWithDamping:.8 initialSpringVelocity:2 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            helperCenterView.center = keyWindow.center;
        } completion:^(BOOL finished) {
            [self removeDisplayLink];
        }];
        //获取差值
        [self getDiff];
//        //添加按钮的动画
        [self addBtnAnim];
        swiched = YES;
    }else{
        [self dismissView];
    }
}

//消失
- (void)dismissView{
    swiched = NO;
    [UIView animateWithDuration:.3 animations:^{
        self.frame =CGRectMake(-(CGRectGetWidth(keyWindow.frame)/2 + menuBlankWidth), 0, CGRectGetWidth(keyWindow.frame)/2 + menuBlankWidth, CGRectGetHeight(keyWindow.frame));
        blurView.alpha = 0;
        helperSideView.center = CGPointMake(-20, 20);
        helperCenterView.center = CGPointMake(-20, CGRectGetHeight(keyWindow.bounds)/2);
    }];
}
@end
