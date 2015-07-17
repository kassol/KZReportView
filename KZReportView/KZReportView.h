//
//  KZReportView.h
//  KZReportView
//
//  Created by Kassol on 15/7/16.
//  Copyright (c) 2015年 Kassol. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - kMNReportDefault

#define KZReportDefaultHeaderRowHeight 50.0
#define KZReportDefaultCellHeight 30.0
#define KZReportDefaultLeftWidth 80.0
#define KZReportDefaultCellWidth 76.0

#define KZReportDefaultFontSize 13.0

#define KZReportDefaultHeaderBackgroundColor [UIColor colorWithRed:0.70 green:0.80 blue:0.90 alpha:1]
#define KZReportDefaultBodyBackgroundColor [UIColor whiteColor]
#define KZReportDefaultHeaderTextColor [UIColor whiteColor]
#define KZReportDefaultBodyTextColor [UIColor blackColor]

#define KZReportDefaultHeaderTextAlignment NSTextAlignmentCenter
#define KZReportDefaultBodyTextAlignment NSTextAlignmentCenter

#define KZReportDefaultBorderlineColor [UIColor colorWithRed:160/255.0 green:190/255.0 blue:210/255.0 alpha:1.0]
#define KZReportDefaultHorizonLineWidth 1.0
#define KZReportDefaultVerticalLineWidth  1.0

#define KZReportDefaultTopBorderLineWidth 2.0
#define KZReportDefaultBottomBorderLineWidth 2.0
#define KZReportDefaultLeftBorderLineWidth 2.0
#define KZReportDefaultRightBorderLineWidth 2.0

#define KZReportDefaultWidthSizeFitType KZReportWidthSizeFitTypeNone
#define KZReportDefaultHeightSizeFitType KZReportHeightSizeFitTypeNone

typedef NS_ENUM(NSInteger, KZReportWidthSizeFitType) {
    KZReportWidthSizeFitTypeNone,           //Don't handle
    KZReportWidthSizeFitTypeAll,            //Divided into equal part
    KZReportWidthSizeFitTypeWithoutFirst           //Divided into equal part except first column
};

typedef NS_ENUM(NSInteger, KZReportHeightSizeFitType) {
    KZReportHeightSizeFitTypeNone,           //Don't handle
    KZReportHeightSizeFitTypeAll,            //Divided into equal part
    KZReportHeightSizeFitTypeWithoutFirst           //Divided into equal part except first row
};


#pragma mark - KZReportLabel

@interface KZReportLabel : UILabel

@property (nonatomic, readonly) NSUInteger col;
@property (nonatomic, readonly) NSUInteger row;

@end

#pragma mark - KZReportGrid

@interface KZReportCell : NSObject

@property (nonatomic, copy) NSString *text;

@end

@class KZReportView;

@protocol KZReportViewDataSource <NSObject>

@required
- (NSArray *)headerDataforKZReportView:(KZReportView *)view;
- (NSArray *)rowDataforKZReportView:(KZReportView *)view forIndex:(NSInteger)index;
- (NSInteger)bodyRowCountInReport;

@optional

@end

@protocol KZReportViewDelegate <NSObject>

@optional
- (CGFloat)headerRowHeight;
- (CGFloat)cellHeight;
- (CGFloat)leftWidth;
- (CGFloat)cellWidth;
- (UIColor *)headerBackgroundColor;
- (UIColor *)bodyBackgroundColor;
- (UIColor *)headerTextColor;
- (UIColor *)bodyTextColor;
- (CGFloat)headerFontSize;
- (CGFloat)bodyFontSize;
- (NSTextAlignment)headerTextAlignment;
- (NSTextAlignment)bodyTextAlignment;
- (UIColor *)borderLineColor;
- (CGFloat)horizonLineWidth;
- (CGFloat)verticalLineWidth;
- (CGFloat)topBorderLinenWidth;
- (CGFloat)bottomBorderLineWidth;
- (CGFloat)leftBorderLineWidth;
- (CGFloat)rightBorderLineWidth;
- (KZReportHeightSizeFitType)heightSizeFitType;
- (KZReportWidthSizeFitType)widthSizeFitType;
- (BOOL)autoFitHeaderHeight;
- (BOOL)autoFitBodyHeight;

@end

@interface KZReportView : UIView <UIScrollViewDelegate>

@property (nonatomic, weak) id<KZReportViewDataSource> datasource;
@property (nonatomic, weak) id<KZReportViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)startShow;
- (void)reload;

@end
