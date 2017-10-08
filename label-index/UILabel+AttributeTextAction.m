//
//  UILabel+AttributeTextAction.m
//  label-index
//
//  Created by 冯文杰 on 2017/9/29.
//  Copyright © 2017年 冯文杰. All rights reserved.
//

#import "UILabel+AttributeTextAction.h"
#import <CoreText/CoreText.h>
#import <objc/runtime.h>

@interface LWAttributeActionModel : NSObject

@property (nonatomic, assign) NSRange range;

@property (nonatomic, copy) NSString *string;

@end

@implementation UILabel (AttributeTextAction)

- (BOOL)isTouch
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setIsTouch:(BOOL)isTouch
{
    objc_setAssociatedObject(self, @selector(isTouch), @(isTouch), OBJC_ASSOCIATION_ASSIGN);
}

- (NSMutableDictionary *)actionBlockDict
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setActionBlockDict:(NSMutableDictionary *)actionBlockDict
{
    objc_setAssociatedObject(self, @selector(actionBlockDict), actionBlockDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (self.isTouch) {
        [self lw_getTapActionWithTouchPoint:point];
    }
}



#pragma mark - 获取点击位置对应的文本文字index
- (BOOL)lw_getTapActionWithTouchPoint:(CGPoint)point
{
    if (self.attributedText == nil) {
        return NO;
    }
    // 初始化framesetter
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.attributedText);
    // 创建path
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    // 绘制frame range：传长度为0也可以。如果是0，会一直增加行数，直到text最后或者没有空间才停止。(numberOfLines)
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    // 获得CTLine数组
    CFArrayRef lines = CTFrameGetLines(frame);
    NSInteger numberOfLines =CFArrayGetCount(lines);
    
    CGPoint lineOrigins[numberOfLines];
    // 获取每一行的origin range同上所述(numberOfLines)
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), lineOrigins);
    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        // 获取行对应的origin
        CGPoint lineOrigin = lineOrigins[lineIndex];
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        
        // 获取每行的 rect
        CGFloat ascent, descent, leading, width;
        width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        
        // 获取富文本的行间距，默认0
        NSParagraphStyle *style = [self.attributedText attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:nil];
        CGFloat lineSpace = 0;
        if (style) {
            lineSpace = style.lineSpacing;
        }
        
        CGFloat lineH = ascent + fabs(descent) + leading;// 行高
        CGFloat textH = lineH * numberOfLines + lineSpace * (numberOfLines - 1);// 文本总高度
        CGFloat textY = (self.bounds.size.height - textH) * 0.5;// 文本开始的 y
        CGFloat lineY = textY + lineIndex * (lineH + lineSpace);// 当前行的开始 y
        CGFloat yMax = lineH + lineY; // 当前行最大 y
        
        if (point.y > yMax) {
            continue; // 点击的位置不在该行文本中
        }
        if (point.y >= lineY) {
            if (point.x >= lineOrigin.x && point.x <= lineOrigin.x + width) {
                // 相对位置
                CGPoint relativePoint = CGPointMake(point.x - lineOrigin.x, point.y - lineOrigin.y);
                // 获取当前点击的文本位置
                NSUInteger idx = CTLineGetStringIndexForPosition(line, relativePoint);
                idx--; // 文本起始位置1 range起始位置0
                __block BOOL include = NO;
                [self.actionBlockDict enumerateKeysAndObjectsUsingBlock:^(AttributeActionBlock actionBlock, LWAttributeActionModel *model, BOOL * _Nonnull stop) {
                    if (NSLocationInRange(idx, model.range)) {
                        include = YES;
                        actionBlock(model.string);
                    }
                }];
                return include;
            }
        }
    }
    return NO;
}

- (void)lw_addAttributeText:(NSString *)string action:(AttributeActionBlock)actionBlock
{
    if (self.attributedText == nil || string.length == 0 || actionBlock == nil) {
        return;
    }
    if (self.actionBlockDict == nil) {
        self.actionBlockDict = [NSMutableDictionary dictionary];
    }
    // 判断是否已经存在
    [self.actionBlockDict enumerateKeysAndObjectsUsingBlock:^(AttributeActionBlock actionBlock, LWAttributeActionModel *model, BOOL * _Nonnull stop) {
        if ([model.string isEqualToString:string]) {
            NSAssert(NO, ([NSString stringWithFormat:@"The string you are about to add already exists：\"%@\"", string]));
        }
    }];
    
    NSString *labelText = self.attributedText.string;
    NSRange range = [labelText rangeOfString:string];
    if (range.length != 0) {
        self.isTouch = YES;
        LWAttributeActionModel *model = [[LWAttributeActionModel alloc] init];
        model.string = string;
        model.range = range;
        [self.actionBlockDict setObject:model forKey:actionBlock];
    } else {
        NSLog(@"self-attributeText doesn't contain the string：\"%@\"", string);
    }
}

@end

@implementation LWAttributeActionModel

@end



