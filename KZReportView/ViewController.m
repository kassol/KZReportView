//
//  ViewController.m
//  KZReportView
//
//  Created by Kassol on 15/7/16.
//  Copyright (c) 2015年 Kassol. All rights reserved.
//

#import "ViewController.h"
#import "KZReportView.h"

@interface ViewController () <KZReportViewDelegate, KZReportViewDataSource>
@property (nonatomic, strong) KZReportView *report;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _report = [[KZReportView alloc] initWithFrame:CGRectMake(5, 25, self.view.frame.size.width-10, self.view.frame.size.height-50)];
    [self.view addSubview:_report];
    _report.delegate = self;
    _report.datasource = self;
    [_report startShow];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - KZReportViewDelegate

- (UIColor *)borderLineColor {
    return [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];
}

- (UIColor *)headerBackgroundColor {
    return [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
}

- (UIColor *)headerTextColor {
    return [UIColor blackColor];
}

#pragma mark -KZReportViewDatasource;

- (NSArray *)rowDataforKZReportView:(KZReportView *)view forIndex:(NSInteger)index {
    return @[
             [[NSString alloc] initWithFormat:@"第0列第%li行tttttttttmmmmmmmmmmmmmmmmmmmmmmmmmmm", (long)index+1],
             [[NSString alloc] initWithFormat:@"第1列第%li行", (long)index+1],
             [[NSString alloc] initWithFormat:@"第2列第%li行", (long)index+1],
             [[NSString alloc] initWithFormat:@"第3列第%li行ttttttttt", (long)index+1],
             [[NSString alloc] initWithFormat:@"第4列第%li行", (long)index+1],
             [[NSString alloc] initWithFormat:@"第5列第%li行", (long)index+1],
             [[NSString alloc] initWithFormat:@"第6列第%li行", (long)index+1],
             [[NSString alloc] initWithFormat:@"第7列第%li行", (long)index+1],
             [[NSString alloc] initWithFormat:@"第8列第%li行", (long)index+1],
             [[NSString alloc] initWithFormat:@"第9列第%li行", (long)index+1],
             [[NSString alloc] initWithFormat:@"第10列第%li行", (long)index+1],
             [[NSString alloc] initWithFormat:@"第11列第%li行", (long)index+1]
             ];
}

- (NSArray *)headerDataforKZReportView:(KZReportView *)view {
    return @[@"", @"第1列ttttttttt", @"第2列", @"第3列", @"第4列", @"第5列", @"第6列", @"第7列", @"第8列", @"第9列", @"第10列", @"第11列"];
}

- (NSInteger)bodyRowCountInReport {
    return 20;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    _report.frame = CGRectMake(5, 25, size.width-10, size.height-50);
    [_report reload];
}

@end
