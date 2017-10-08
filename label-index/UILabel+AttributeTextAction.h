//
//  UILabel+AttributeTextAction.h
//  label-index
//
//  Created by 冯文杰 on 2017/9/29.
//  Copyright © 2017年 冯文杰. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 * 1、需要设置Label.userInteractionEnabled = YES
 * 2、AttributeText必须设置字体大小
 */

typedef void(^AttributeActionBlock)(NSString *string);

@interface UILabel (AttributeTextAction)

/**
 给字符串添加点击事件

 @param string 添加事件的字符串
 @param actionBlock 执行回调
 */
- (void)lw_addAttributeText:(NSString *)string action:(AttributeActionBlock)actionBlock;



@end
