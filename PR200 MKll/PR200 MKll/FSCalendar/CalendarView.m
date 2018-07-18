//
//  CalendarView.m
//  PR200 MKll
//
//  Created by 梅 on 2018/7/16.
//  Copyright © 2018年 mei. All rights reserved.
//

#import "CalendarView.h"

typedef enum : NSUInteger {
    HolidayEvents=0,
    HolidayAndPutEvents=1,
} EventsType;

@interface CalendarView()<FSCalendarDelegate,FSCalendarDataSource>
@property (nonatomic, strong)FSCalendar *calendar;
@property (nonatomic, strong)NSCalendar *chinaCalendar;
@property (nonatomic, strong)NSArray<NSString *>*ChinaStr_arr;
@property (nonatomic, strong)NSArray<NSString *>*ChinaMon_arr;

@property (nonatomic, strong)NSArray<EKEvent *>*events;
@property (nonatomic, strong)NSArray<EKEvent *>*putAllEvents;
@property (nonatomic, strong)NSArray<EKEvent *>*oneDayEvents;
@end

@implementation CalendarView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self initView];
    }
    return self;
}

- (void)initView
{
    UIColor *brownColor = [UIColor colorWithRed:0.55 green:0.79 blue:0.75 alpha:1];
    UIColor *blackColor = [UIColor colorWithRed:0.16 green:0.20 blue:0.22 alpha:1];
    
    self.backgroundColor = brownColor;
    _calendar = [[FSCalendar alloc]init];
    _calendar.delegate = self;
    _calendar.dataSource = self;
    _calendar.appearance.headerTitleColor = [UIColor darkGrayColor];
    _calendar.appearance.weekdayTextColor = [UIColor darkGrayColor];
    _calendar.appearance.headerMinimumDissolvedAlpha = 0;//不显示左右月份
    _calendar.appearance.caseOptions = FSCalendarCaseOptionsHeaderUsesDefaultCase|FSCalendarCaseOptionsWeekdayUsesDefaultCase;//月文字|周文字
    _calendar.appearance.headerDateFormat = @"yyyy年MM月";
    _calendar.placeholderType = FSCalendarPlaceholderTypeNone;//隐藏超过日期
    _calendar.appearance.headerTitleColor = blackColor;
    _calendar.appearance.weekdayTextColor = blackColor;
    _calendar.appearance.selectionColor = OrangeColor;
    
    ////////////范围一个月还是一周///////////
    _calendar.scope = FSCalendarScopeMonth;//FSCalendarScopeMonth||FSCalendarScopeWeek;
    _calendar.firstWeekday = 2;//周一为第一天
    [_calendar selectDate:[NSDate date]];//选中当天
    
//    self.translatesAutoresizingMaskIntoConstraints = YES;///自动创建约束
//    _calendar.translatesAutoresizingMaskIntoConstraints = YES;
    
    [self addSubview:_calendar];
    [_calendar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.mas_equalTo(self);
    }];
    
    [self addChinaCalendar];
}
- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    if(_block)
    {
        NSDateFormatter *dateFormate = [[NSDateFormatter alloc]init];
        [dateFormate setDateFormat:@"MM月dd日"];
        NSString *dateStr = [dateFormate stringFromDate:date];
        //加入农历信息
        NSInteger ChinaDay = [_chinaCalendar component:NSCalendarUnitDay fromDate:date];//date对象对应的农历日期，如1代表初一
        NSString *ChinaDayStr = self.ChinaStr_arr[ChinaDay-1];//初一、初二、三十
        NSInteger currentMonth = [_chinaCalendar component:NSCalendarUnitMonth fromDate:date];
        NSString *currentMonthStr = self.ChinaMon_arr[currentMonth-1];//一、二、三
        NSString *chinaDay = [NSString stringWithFormat:@"农历%@月%@",currentMonthStr,ChinaDayStr];
        NSLog(@"%@",chinaDay);///
        
        _oneDayEvents = [self eventsForDate:date withType:HolidayAndPutEvents];//一天的活动
        NSMutableArray *titleArr = [NSMutableArray array];
        [titleArr addObject:chinaDay];//第一个元素:农历
        if(_oneDayEvents.count!=0)
        {
            for (EKEvent *event in _oneDayEvents)
            {
                [titleArr addObject:event.title];
            }
        }else{
            [titleArr addObject:dateStr];
        }
        _block(titleArr);
    }
}
- (void)addChinaCalendar
{
    _chinaCalendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierChinese];//农历
    self.ChinaStr_arr = @[@"初一",@"初二",@"初三",@"初四",@"初五",@"初六",@"初七",@"初八",@"初九",@"初十",@"十一",@"十二",@"十三",@"十四",@"十五",@"十六",@"十七",@"十八",@"十九",@"二十",@"廿一",@"廿二",@"廿三",@"廿四",@"廿五",@"廿六",@"廿七",@"廿八",@"廿九",@"三十"];
    self.ChinaMon_arr = @[@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"十",@"十一",@"十二"];
    
    NSDate *oneYearBefore = [NSDate dateWithTimeIntervalSinceNow:(-12 *3600 *365*5)];
    NSDate *oneYearLater = [NSDate dateWithTimeIntervalSinceNow:(12 *3600 *365*5)];
    __weak typeof(self) weakSelf = self;
    EKEventStore *store = [[EKEventStore alloc]init];
    //日历权限
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
        if(granted)
        {
            NSDate *startDate = oneYearBefore;
            NSDate *endDate = oneYearLater;
            NSPredicate *fetchCalendarEvents = [store predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
            NSArray<EKEvent *>*eventList = [store eventsMatchingPredicate:fetchCalendarEvents];
            NSArray<EKEvent *>*events = [eventList filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(EKEvent * _Nullable event, NSDictionary<NSString *,id> * _Nullable bindings) {
                return event.calendar.subscribed;
            }]];
            weakSelf.events = events;//events
            weakSelf.putAllEvents = eventList;//eventList
        }
    }];
    /*
     此处eventList变量即为开始日期startDate到截止日期endDate之间的所有事件，而events变量只包含订阅事件，如春节、劳动节、圣诞节、夏至等，排除了用户在系统日历中自己添加的事件，如某某人的生日等。
     */
}
#pragma mark
#pragma mark - FSCalendarDataSource
- (NSString *)calendar:(FSCalendar *)calendar subtitleForDate:(NSDate *)date
{
    EKEvent *event = [self eventsForDate:date withType:HolidayAndPutEvents].firstObject;
    if(event)
    {
        return event.title;//春分、秋分、儿童节、植树节.....
    }
    NSInteger ChinaDay = [_chinaCalendar component:NSCalendarUnitDay fromDate:date];//date对象对应的农历日期，如1代表初一
    NSString *ChinaDayStr = self.ChinaStr_arr[ChinaDay-1];//初一、初二、三十
    return ChinaDayStr;
}
- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date
{
    NSInteger inte = [self eventsForDate:date withType:HolidayEvents].count;
    return inte;
}

//- (UIImage *)calendar:(FSCalendar *)calendar imageForDate:(NSDate *)date
//{
//    //返回标记图片
//}

// 某个日期的所有事件
- (NSArray<EKEvent *> *)eventsForDate:(NSDate *)date withType:(EventsType)type
{
    NSArray<EKEvent *> *filteredEvents;
    switch (type) {
        case HolidayEvents:
        {
            filteredEvents = [self.events filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(EKEvent * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                return [evaluatedObject.occurrenceDate isEqualToDate:date];
            }]];
        }
            break;
        case HolidayAndPutEvents:
        {
            filteredEvents = [self.putAllEvents filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(EKEvent * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                return [evaluatedObject.occurrenceDate isEqualToDate:date];
            }]];
        }
            break;
    }
     return filteredEvents;
}



@end
