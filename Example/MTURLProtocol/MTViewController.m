//
//  MTViewController.m
//  MTURLProtocol
//
//  Created by duyu1010@gmail.com on 08/21/2018.
//  Copyright (c) 2018 duyu1010@gmail.com. All rights reserved.
//

@import MTURLProtocol;

#import "MTViewController.h"
#import "MTTestRequestHandler.h"
#import "MTTestLocalRequestHandler.h"
#import "MTTestResponseHandler.h"

static NSString *RemoteRequest = @"Remote Request";
static NSString *LocalRequest = @"Local Request";

@interface MTViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *rows;

@end

@implementation MTViewController

- (instancetype)init
{
  if (self = [super init]) {
    self.title = @"MTURLProtocol Demo";

    // Request handler
    [MTURLProtocol addRequestHandler:MTTestRequestHandler.class];
    [MTURLProtocol addRequestHandler:MTTestLocalRequestHandler.class];

    // Response handler
    // Note: you can also delete the line below to use default response handling logic in MTURLProtocl.
    // MTTestResponseHandler dose nothing more than MTURLProtocol.
    [MTURLProtocol addResponseHandler:MTTestResponseHandler.class];

    // Task handler
    // Add task handler if needed.
    // ...

    _rows = @[RemoteRequest, LocalRequest];
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

  if ([_rows[indexPath.row] isEqualToString:RemoteRequest]) {
    [self _mt_testRemoteRequest];
  }
  else if ([_rows[indexPath.row] isEqualToString:LocalRequest]) {
    [self _mt_testLocalRequest];
  }
}

#pragma mark - Test Logic

- (void)_mt_testRemoteRequest
{
  // Will be decorated by `MTTestRequestHandler`
  [self _mt_sentRequestWithURL:[NSURL URLWithString:@"https://jsonplaceholder.typicode.com/"]];
}

- (void)_mt_testLocalRequest
{
  // Will be decorated by `MTTestLocalRequestHandler`
  [self _mt_sentRequestWithURL:[NSURL URLWithString:@"https://mtdemo.com/local-api"]];
}

- (void)_mt_sentRequestWithURL:(NSURL *)url
{
  NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
  [configuration mt_registerProtocolClass:MTURLProtocol.class];
  NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];

  NSURLSessionDataTask *task = [session dataTaskWithURL:url
                                      completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                        if (!error) {
                                          NSLog(@"success");
                                          NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                          UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reponse"
                                                                                                         message:json
                                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                                          UIAlertAction *action = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:nil];
                                          [alert addAction:action];
                                          [self presentViewController:alert animated:YES completion:nil];
                                        }
                                      }];
  [task resume];
}

@end
