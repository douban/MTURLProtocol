//
//  MTViewController.m
//  MTURLProtocol
//
//  Created by duyu1010@gmail.com on 08/21/2018.
//  Copyright (c) 2018 duyu1010@gmail.com. All rights reserved.
//

@import MTURLProtocol;

#import "MTViewController.h"

static NSString *DNS = @"DNS";

@interface MTViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *rows;

@end

@implementation MTViewController

- (instancetype)init
{
  if (self = [super init]) {
    self.title = @"MTURLProtocol Demo";

    _rows = @[DNS];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  self.view.backgroundColor = UIColor.whiteColor;
  [self.view addSubview:self.tableView];
}

- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];
  self.tableView.frame = self.view.bounds;
}

- (UITableView *)tableView
{
  if (!_tableView) {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
  }
  return _tableView;
}

#pragma mark - TableView Delegate and Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return _rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class)
                                                          forIndexPath:indexPath];
  cell.textLabel.text = _rows[indexPath.row];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:NO];

  if ([_rows[indexPath.row] isEqualToString:DNS]) {
    [self _mt_testDNS];
  }
}

#pragma mark - Test Logic

- (void)_mt_testDNS
{
  
}

@end
