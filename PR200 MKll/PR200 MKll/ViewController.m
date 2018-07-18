//
//  ViewController.m
//  PR200 MKll
//
//  Created by 梅 on 2018/7/16.
//  Copyright © 2018年 mei. All rights reserved.
//

#import "ViewController.h"

static  CGFloat calendarH = 400;
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)CalendarView *calendarView;
@property (nonatomic, strong)UITableView *tableView;

@property (nonatomic, strong)NSArray *dataArr;
@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self addCalendar];
    [self addTableView];
}
- (void)addTableView
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 22+calendarH, self.view.py_width, self.view.py_height-22-calendarH) style:UITableViewStylePlain];
    _tableView.backgroundColor = OrangeColor;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc]init];//去除没有内容的cell
    _tableView.separatorColor = [UIColor blackColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.view addSubview:_tableView];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.backgroundColor = OrangeColor;
    cell.textLabel.text = _dataArr[indexPath.row];
    return cell;
}
- (void)addCalendar
{
    _calendarView = [[CalendarView alloc]initWithFrame:CGRectMake(0, 22, self.view.bounds.size.width, calendarH)];
    [self.view addSubview:_calendarView];
    
    __weak typeof(self) weakSelf = self;
    _calendarView.block = ^(id res) {
        _dataArr = [NSArray arrayWithArray:res];
        NSLog(@"选中日期 = %@",weakSelf.dataArr);
        [weakSelf.tableView reloadData];
    };
    
}


@end
