//
//  JLTextField.m
//  textFieldTag
//
//  Created by 16fan on 15/4/20.
//  Copyright (c) 2015年 16fan. All rights reserved.
//

#import "JLTextField.h"


@implementation JLTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (CGRect)editingRectForBounds:(CGRect)bounds{
    return CGRectMake(10, bounds.origin.y, bounds.size.width-20, bounds.size.height);
}

- (CGRect)textRectForBounds:(CGRect)bounds{
    return CGRectMake(10, bounds.origin.y, bounds.size.width-20, bounds.size.height);
}

@end
