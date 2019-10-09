//
//  InputAltertView.m
//  iOSPerformanceKit
//
//  Created by Maggie on 2019/9/19.
//  Copyright © 2019 soul. All rights reserved.
//

#import "InputAltertView.h"

@implementation InputAltertView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _textField.frame = CGRectMake(0, 0, self.bounds.size.width, 20);
    _confirmButton.frame = CGRectMake(10, 20, 50, 30);
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _textField = [[UITextField alloc] init];
        _textField.placeholder = @"输入事件名称";
        _textField.accessibilityLabel = @"textView";
        _textField.font = [UIFont systemFontOfSize:12];
        _textField.backgroundColor = [UIColor whiteColor];
        [self addSubview:_textField];
        
        _confirmButton = [[UIButton alloc] init];
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_confirmButton setTitle:@"开始" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _confirmButton.accessibilityLabel = @"confirmButton";
        [self addSubview:_confirmButton];
        self.hidden = YES;
    }
    return self;
}

- (void)showInView:(UIView *)view
{
    self.hidden = NO;
    
}

@end
