//
//  CalendarView.h
//  PR200 MKll
//
//  Created by 梅 on 2018/7/16.
//  Copyright © 2018年 mei. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ActionBlock)(void);
typedef void (^ActionBlock1)(id res);
@interface CalendarView : UIView
@property (nonatomic, strong)ActionBlock1 block;
@end
