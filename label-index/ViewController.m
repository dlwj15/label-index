//
//  ViewController.m
//  label-index
//
//  Created by 冯文杰 on 2017/9/29.
//  Copyright © 2017年 冯文杰. All rights reserved.
//

#import "ViewController.h"
//#import "UILabel+AttributeTap.h"
#import "UILabel+AttributeTextAction.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 200, 100)];
    label.numberOfLines = 0;
    [self.view addSubview:label];
    
    NSMutableAttributedString *attstring = [[NSMutableAttributedString alloc] initWithString:@"“夙夜在公，勤勉工作，努力向历史、向人民交出一份合格的答卷”——脚踏实地，植根沃土，这是践行庄严承诺的足迹" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15.f]}];
    
    [attstring addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:[attstring.string rangeOfString:@"“夙夜在公，勤勉工作，努力向历史、向人民交出一份合格的答卷”"]];
    [attstring addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:[attstring.string rangeOfString:@"“夙夜在公，勤勉工作，努力向历史、向人民交出一份合格的答卷”"]];
    
    [attstring addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:[attstring.string rangeOfString:@"承诺"]];
    [attstring addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:[attstring.string rangeOfString:@"承诺"]];
    
    
    label.attributedText = attstring;
    label.userInteractionEnabled = YES;
    [label lw_addAttributeText:@"“夙夜在公，勤勉工作，努力向历史、向人民交出一份合格的答卷”" action:^(NSString *string) {
        NSLog(@"string %@", string);
    }];
    
    [label lw_addAttributeText:@"承诺" action:^(NSString *string) {
        NSLog(@"string %@", string);
    }];
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
