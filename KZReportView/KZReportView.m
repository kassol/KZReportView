//
//  KZReportView.m
//  KZReportView
//
//  Created by Kassol on 15/7/16.
//  Copyright (c) 2015年 Kassol. All rights reserved.
//

#import "KZReportView.h"

typedef NS_ENUM(NSInteger, KZReportViewPart) {
    KZReportViewPartTopLeft,
    KZReportViewPartTopRight,
    KZReportViewPartBottomLeft,
    KZReportViewPartBottomRight
};

@interface KZReportLabel ()
@property (nonatomic, assign) NSUInteger col;
@property (nonatomic, assign) NSUInteger row;

@end

@implementation KZReportLabel

@end

@interface KZReportView ()
@property (nonatomic, strong) UIView *topLeftView;
@property (nonatomic, strong) UIView *topRightView;
@property (nonatomic, strong) UIView *bottomLeftView;
@property (nonatomic, strong) UIView *bottomRightView;
@property (nonatomic, strong) UIScrollView *topRightScroll;
@property (nonatomic, strong) UIScrollView *bottomLeftScroll;
@property (nonatomic, strong) UIScrollView *bottomRightScroll;

@property (nonatomic, assign) NSInteger colCount;
@property (nonatomic, assign) NSInteger rowCount;

@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) CGFloat headerRowHeight;
@property (nonatomic, assign) CGFloat bodyHeight;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, assign) CGFloat leftWidth;

@property (nonatomic, strong) UIColor *headerBackgroundColor;
@property (nonatomic, strong) UIColor *bodyBackgroundColor;

@property (nonatomic, strong) UIColor *headerTextColor;
@property (nonatomic, strong) UIColor *bodyTextColor;

@property (nonatomic, assign) CGFloat headerFontSize;
@property (nonatomic, assign) CGFloat bodyFontSize;

@property (nonatomic, assign) NSTextAlignment headerTextAlignment;
@property (nonatomic, assign) NSTextAlignment bodyTextAlignment;

@property (nonatomic, strong) UIColor *borderLineColor;
@property (nonatomic, assign) CGFloat horizonLineWidth;
@property (nonatomic, assign) CGFloat verticalLineWidth;

@property (nonatomic, assign) CGFloat topBorderLineWidth;
@property (nonatomic, assign) CGFloat bottomBorderLineWidth;
@property (nonatomic, assign) CGFloat leftBorderLineWidth;
@property (nonatomic, assign) CGFloat rightBorderLineWidth;

@property (nonatomic, assign) KZReportHeightSizeFitType heightSizeFitType;
@property (nonatomic, assign) KZReportWidthSizeFitType widthSizeFitType;

@property (nonatomic, assign) BOOL autoFitHeaderHeight;
@property (nonatomic, assign) BOOL autoFitBodyHeight;

@property (nonatomic, strong) NSMutableArray *bodyRowHeightArray;
@property (nonatomic, strong) NSArray *colWidthArray;

@property (nonatomic, strong) NSArray *yOffsetArray;

@end

@implementation KZReportView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    return self;
}

- (void)startShow {
    [self initSubViews];
    [self loadSubViews];
}

- (void)reload {
    _bottomRightScroll.contentOffset = CGPointMake(0, 0);
    [self loadSubViews];
}

- (void)loadSubViews {
    _colCount = [[_datasource headerDataforKZReportView:self] count];
    _rowCount = [_datasource bodyRowCountInReport];
    
    [self setStyle];
    [self sizeToFit];
    [self layoutAllSubViews];
    [self loadReport];
}

- (void)loadReport {
    CGFloat rightWidth = - _verticalLineWidth;
    for (NSInteger i = 1; i < _colCount; ++i) {
        rightWidth += ((NSNumber *)_colWidthArray[i]).floatValue + _verticalLineWidth;
    }
    
    _topRightScroll.frame = CGRectMake(_leftBorderLineWidth+_verticalLineWidth+_leftWidth, _topBorderLineWidth, self.frame.size.width-(_leftBorderLineWidth+_leftWidth+_verticalLineWidth+ _rightBorderLineWidth), _headerHeight);
    _topRightScroll.contentSize = CGSizeMake(rightWidth, 0);
    
    _bottomLeftScroll.frame = CGRectMake(_leftBorderLineWidth, _topBorderLineWidth+_horizonLineWidth+_headerHeight, _leftWidth, self.frame.size.height-(_topBorderLineWidth+_headerHeight+_horizonLineWidth+_bottomBorderLineWidth));
    _bottomLeftScroll.contentSize = CGSizeMake(0, _bodyHeight);
    
    _bottomRightScroll.frame = CGRectMake(_leftBorderLineWidth+_verticalLineWidth+_leftWidth, _topBorderLineWidth+_horizonLineWidth+_headerHeight, self.frame.size.width-(_leftBorderLineWidth+_leftWidth+_verticalLineWidth+_rightBorderLineWidth), self.frame.size.height-(_topBorderLineWidth+_headerHeight+_horizonLineWidth+_bottomBorderLineWidth));
    _bottomRightScroll.contentSize = CGSizeMake(rightWidth, _bodyHeight);
    
    _topLeftView.frame = CGRectMake(_leftBorderLineWidth, _topBorderLineWidth, _leftWidth, _headerHeight);
    _bottomLeftView.frame = CGRectMake(0, 0, _leftWidth, _bodyHeight);
    _topRightView.frame = CGRectMake(0, 0, rightWidth, _headerHeight);
    _bottomRightView.frame = CGRectMake(0, 0, rightWidth, _bodyHeight);
    
    [self loadTopLeft];
    [self loadTopRight];
    [self loadBottomLeft];
    [self loadBottomRight];
    [self setNeedsDisplay];

    [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]];
    
    self.backgroundColor = _borderLineColor;
}

- (void)loadTopLeft {
    NSInteger index = 0;
    
    CGRect labelFrame = CGRectMake(0, 0, _leftWidth, _headerRowHeight);
    KZReportLabel *l = [self labelWithFrame:labelFrame text:[[_datasource headerDataforKZReportView:self] objectAtIndex:0] inPart:KZReportViewPartTopLeft index:index];
    l.row = 0;
    l.col = 0;
}

- (void)loadTopRight {
    NSInteger index = 0;
    
    CGFloat xOffset = 0;
    
    NSArray *headerRow = [_datasource headerDataforKZReportView:self];
    
    for (NSInteger i = 1; i < [headerRow count]; ++i) {
        NSString *text = [headerRow objectAtIndex:i];
        CGRect labelFrame = CGRectMake(xOffset, 0, ((NSNumber*)_colWidthArray[i]).floatValue, _headerRowHeight);
        KZReportLabel *l = [self labelWithFrame:labelFrame text:text inPart:KZReportViewPartTopRight index:index];
        l.row = 0;
        l.col = i;
        
        ++index;
        xOffset += ((NSNumber*)_colWidthArray[i]).floatValue+_verticalLineWidth;
    }
}

- (void)loadBottomLeft {
    CGFloat yOffset = 0;
    NSInteger index = 0;
    
    NSMutableArray *tempYOffsetArray = [NSMutableArray array];
    
    for (NSInteger i = 1; i < _rowCount+1; ++i) {
        NSString *text = [[_datasource rowDataforKZReportView:self forIndex:i-1] objectAtIndex:0];
        
        CGFloat height = ((NSNumber *)_bodyRowHeightArray[i-1]).floatValue;
        
        CGRect labelFrame = CGRectMake(0, yOffset, _leftWidth, height);
        
        KZReportLabel *l = [self labelWithFrame:labelFrame text:text inPart:KZReportViewPartBottomLeft index:index];
        l.row = i;
        l.col = 0;
        
        ++index;
        
        [tempYOffsetArray addObject:[NSNumber numberWithFloat:yOffset]];
        yOffset += height+_horizonLineWidth;
    }
    
    _yOffsetArray = tempYOffsetArray;
}

- (void)loadBottomRight {
    CGFloat yOffset = 0;
    NSInteger index = 0;
    
    for (NSInteger i = 1; i < _rowCount+1; ++i) {
        CGFloat xOffset = 0;
        CGFloat height = ((NSNumber *)_bodyRowHeightArray[i-1]).floatValue;
        
        for (NSInteger j = 1; j < _colCount; ++j) {
            NSString *text = [[_datasource rowDataforKZReportView:self forIndex:i-1] objectAtIndex:j];
            
            CGFloat width = ((NSNumber *)_colWidthArray[j]).floatValue;
            
            CGRect labelFrame = CGRectMake(xOffset, yOffset, width, height);
            
            KZReportLabel *l = [self labelWithFrame:labelFrame text:text inPart:KZReportViewPartBottomRight index:index];
            l.row = i;
            l.col = j;
            xOffset += width+_verticalLineWidth;
            ++index;
        }
        yOffset += height+_horizonLineWidth;
    }
}

- (KZReportLabel *)labelWithFrame:(CGRect)frame text:(NSString *)text inPart:(KZReportViewPart)part index:(NSInteger)index {
    KZReportLabel *l;
    
    switch (part) {
        case KZReportViewPartTopLeft:
        case KZReportViewPartTopRight:
        {
            if (part == KZReportViewPartTopLeft) {
                
                l = _topLeftView.subviews[index];
            }
            else
            {
                l = _topRightView.subviews[index];
            }
            CGFloat fontSize = _headerFontSize;
            UIFont *font = [UIFont systemFontOfSize:fontSize];
            l.font = font;
            l.textColor = _headerTextColor;
            l.backgroundColor = _headerBackgroundColor;
            l.textAlignment = _headerTextAlignment;
            break;
        }
        case KZReportViewPartBottomLeft:
        case KZReportViewPartBottomRight:
        {
            if (part == KZReportViewPartBottomLeft) {
                
                l = _bottomLeftView.subviews[index];
            }
            else
            {
                l = _bottomRightView.subviews[index];
            }
            CGFloat fontSize = _bodyFontSize;
            UIFont *font = [UIFont systemFontOfSize:fontSize];
            l.font = font;
            l.textColor = _bodyTextColor;
            l.backgroundColor = _bodyBackgroundColor;
            l.textAlignment = _bodyTextAlignment;
            break;
        }
        default:
            break;
    }
    
    l.frame = frame;
    
    l.text = text;
    l.lineBreakMode = NSLineBreakByCharWrapping;
    l.numberOfLines = 0;
    
    return l;
}

- (void)layoutAllSubViews{
    [self layoutInPart:KZReportViewPartTopLeft];
    [self layoutInPart:KZReportViewPartTopRight];
    [self layoutInPart:KZReportViewPartBottomLeft];
    [self layoutInPart:KZReportViewPartBottomRight];
}

- (void)layoutInPart:(KZReportViewPart)part {
    UIView *superView;
    NSInteger countShouldAdd = 0;
    
    switch (part) {
        case KZReportViewPartTopLeft:
            superView = _topLeftView;
            countShouldAdd = 1;
            break;
        case KZReportViewPartTopRight:
            superView = _topRightView;
            countShouldAdd = _colCount-1;
            break;
        case KZReportViewPartBottomLeft:
            superView = _bottomLeftView;
            countShouldAdd = _rowCount;
            break;
        case KZReportViewPartBottomRight:
            superView = _bottomRightView;
            countShouldAdd = _rowCount * (_colCount - 1);
            break;
        default:
            break;
    }
    NSInteger labelCountNeedAdd = countShouldAdd - superView.subviews.count;
    
    if (labelCountNeedAdd < 0) {
        while (labelCountNeedAdd < 0) {
            KZReportLabel *l = [superView.subviews lastObject];
            [l removeFromSuperview];
            l = nil;
            ++labelCountNeedAdd;
        }
    }
    else
    {
        while (labelCountNeedAdd > 0) {
            
            KZReportLabel *l = [[KZReportLabel alloc] init];
            [superView addSubview:l];
            --labelCountNeedAdd;
        }
    }
}


- (void)initSubViews {
    _topRightScroll = [[UIScrollView alloc] init];
    _topRightScroll.backgroundColor = [UIColor clearColor];
    _topRightScroll.scrollEnabled = NO;
    
    _bottomLeftScroll = [[UIScrollView alloc] init];
    _bottomLeftScroll.backgroundColor = [UIColor clearColor];
    _bottomLeftScroll.scrollEnabled = NO;
    
    _bottomRightScroll = [[UIScrollView alloc] init];
    _bottomRightScroll.backgroundColor = [UIColor clearColor];
    _bottomRightScroll.scrollEnabled = YES;
    _bottomRightScroll.delegate = self;
    
    _topLeftView = [[UIView alloc] init];
    _topLeftView.backgroundColor = [UIColor clearColor];
    
    _topRightView = [[UIView alloc] init];
    _topRightView.backgroundColor = [UIColor clearColor];
    
    _bottomLeftView = [[UIView alloc] init];
    _bottomLeftView.backgroundColor = [UIColor clearColor];
    
    _bottomRightView = [[UIView alloc] init];
    _bottomRightView.backgroundColor = [UIColor clearColor];
    
    [_topRightScroll addSubview:_topRightView];
    [_bottomLeftScroll addSubview:_bottomLeftView];
    [_bottomRightScroll addSubview:_bottomRightView];
    
    [self addSubview:_topLeftView];
    [self addSubview:_topRightScroll];
    [self addSubview:_bottomLeftScroll];
    [self addSubview:_bottomRightScroll];
    
    
}

- (void)setStyle {
    if ([_delegate respondsToSelector:@selector(headerRowHeight)]) {
        _headerRowHeight = [_delegate headerRowHeight];
    } else {
        _headerRowHeight = KZReportDefaultHeaderRowHeight;
    }
    if ([_delegate respondsToSelector:@selector(cellHeight)]) {
        _cellHeight = [_delegate cellHeight];
    } else {
        _cellHeight = KZReportDefaultCellHeight;
    }
    if ([_delegate respondsToSelector:@selector(cellWidth)]) {
        _cellWidth = [_delegate cellWidth];
    } else {
        _cellWidth = KZReportDefaultCellWidth;
    }
    if ([_delegate respondsToSelector:@selector(leftWidth)]) {
        _leftWidth = [_delegate leftWidth];
    } else {
        _leftWidth = KZReportDefaultLeftWidth;
    }
    if ([_delegate respondsToSelector:@selector(headerBackgroundColor)]) {
        _headerBackgroundColor = [_delegate headerBackgroundColor];
    } else {
        _headerBackgroundColor = KZReportDefaultHeaderBackgroundColor;
    }
    if ([_delegate respondsToSelector:@selector(bodyBackgroundColor)]) {
        _bodyBackgroundColor = [_delegate bodyBackgroundColor];
    } else {
        _bodyBackgroundColor = KZReportDefaultBodyBackgroundColor;
    }
    if ([_delegate respondsToSelector:@selector(headerTextColor)]) {
        _headerTextColor = [_delegate headerTextColor];
    } else {
        _headerTextColor = KZReportDefaultHeaderTextColor;
    }
    if ([_delegate respondsToSelector:@selector(bodyTextColor)]) {
        _bodyTextColor = [_delegate bodyTextColor];
    } else {
        _bodyTextColor = KZReportDefaultBodyTextColor;
    }
    if ([_delegate respondsToSelector:@selector(headerFontSize)]) {
        _headerFontSize = [_delegate headerFontSize];
    } else {
        _headerFontSize = KZReportDefaultFontSize;
    }
    if ([_delegate respondsToSelector:@selector(bodyFontSize)]) {
        _bodyFontSize = [_delegate bodyFontSize];
    } else {
        _bodyFontSize = KZReportDefaultFontSize;
    }
    if ([_delegate respondsToSelector:@selector(headerTextAlignment)]) {
        _headerTextAlignment = [_delegate headerTextAlignment];
    } else {
        _headerTextAlignment = KZReportDefaultHeaderTextAlignment;
    }
    if ([_delegate respondsToSelector:@selector(bodyTextAlignment)]) {
        _bodyTextAlignment = [_delegate bodyTextAlignment];
    } else {
        _bodyTextAlignment = KZReportDefaultBodyTextAlignment;
    }
    if ([_delegate respondsToSelector:@selector(borderLineColor)]) {
        _borderLineColor = [_delegate borderLineColor];
    } else {
        _borderLineColor = KZReportDefaultBorderlineColor;
    }
    if ([_delegate respondsToSelector:@selector(horizonLineWidth)]) {
        _horizonLineWidth = [_delegate horizonLineWidth];
    } else {
        _horizonLineWidth = KZReportDefaultHorizonLineWidth;
    }
    if ([_delegate respondsToSelector:@selector(verticalLineWidth)]) {
        _verticalLineWidth = [_delegate verticalLineWidth];
    } else {
        _verticalLineWidth = KZReportDefaultVerticalLineWidth;
    }
    if ([_delegate respondsToSelector:@selector(topBorderLineWidth)]) {
        _topBorderLineWidth = [_delegate topBorderLinenWidth];
    } else {
        _topBorderLineWidth = KZReportDefaultTopBorderLineWidth;
    }
    if ([_delegate respondsToSelector:@selector(bottomBorderLineWidth)]) {
        _bottomBorderLineWidth = [_delegate bottomBorderLineWidth];
    } else {
        _bottomBorderLineWidth = KZReportDefaultBottomBorderLineWidth;
    }
    if ([_delegate respondsToSelector:@selector(leftBorderLineWidth)]) {
        _leftBorderLineWidth = [_delegate leftBorderLineWidth];
    } else {
        _leftBorderLineWidth = KZReportDefaultLeftBorderLineWidth;
    }
    if ([_delegate respondsToSelector:@selector(rightBorderLineWidth)]) {
        _rightBorderLineWidth = [_delegate rightBorderLineWidth];
    } else {
        _rightBorderLineWidth = KZReportDefaultRightBorderLineWidth;
    }
    if ([_delegate respondsToSelector:@selector(heightSizeFitType)]) {
        _heightSizeFitType = [_delegate heightSizeFitType];
    } else {
        _heightSizeFitType = KZReportDefaultHeightSizeFitType;
    }
    if ([_delegate respondsToSelector:@selector(widthSizeFitType)]) {
        _widthSizeFitType = [_delegate widthSizeFitType];
    } else {
        _widthSizeFitType = KZReportDefaultWidthSizeFitType;
    }
    if ([_delegate respondsToSelector:@selector(autoFitHeaderHeight)]) {
        _autoFitHeaderHeight = [_delegate autoFitHeaderHeight];
    } else {
        _autoFitHeaderHeight = YES;
    }
    if ([_delegate respondsToSelector:@selector(autoFitBodyHeight)]) {
        _autoFitBodyHeight = [_delegate autoFitBodyHeight];
    } else {
        _autoFitBodyHeight = YES;
    }
}

- (void)sizeToFit {
    CGFloat reportWidth = _leftBorderLineWidth+_leftWidth+(_cellWidth+_horizonLineWidth)*(_colCount-1)+_rightBorderLineWidth;
    
    _headerHeight = _headerRowHeight;
    
    if (_autoFitHeaderHeight) {
        CGFloat maxHeight = _headerRowHeight;
        for (NSString *text in [_datasource headerDataforKZReportView:self]) {
            NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:_headerFontSize]};
            CGSize textSize = [text boundingRectWithSize:CGSizeMake(_cellWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
            NSInteger textRowCount = (NSInteger)(textSize.height/_headerFontSize);
            CGFloat currentHeight = textRowCount*(_headerFontSize+3);
            
            maxHeight = MAX(currentHeight, maxHeight);
        }
        _headerHeight += maxHeight-_headerRowHeight;
    }
    
    _bodyHeight = _cellHeight*_rowCount+_horizonLineWidth*(_rowCount-1);
    
    if (_autoFitBodyHeight) {
        _bodyRowHeightArray = [[NSMutableArray alloc] init];
        
        for (NSInteger i = 0; i < [_datasource bodyRowCountInReport]; ++i) {
            CGFloat maxHeight = _cellHeight;
            for (NSString *text in [_datasource rowDataforKZReportView:self forIndex:i]) {
                NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:_bodyFontSize]};
                CGSize textSize = [text boundingRectWithSize:CGSizeMake(_cellWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
                NSInteger textRowCount = (NSInteger)(textSize.height/_bodyFontSize);
                CGFloat currentHeight = textRowCount*(_bodyFontSize+3);
                
                maxHeight = MAX(currentHeight, maxHeight);
            }
            [_bodyRowHeightArray addObject:[NSNumber numberWithFloat:maxHeight]];
            _bodyHeight += maxHeight-_cellHeight;
        }
    }
    
    CGFloat reportHeight = _topBorderLineWidth+_headerHeight+_horizonLineWidth+_bodyHeight+_bottomBorderLineWidth;
    
    CGFloat frameWidth = self.frame.size.width;
    CGFloat frameHeight = self.frame.size.height;
    
    if (frameHeight == 0) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, frameWidth, reportHeight);
    }
    
    if (reportWidth < frameWidth) {
        switch (_widthSizeFitType) {
            case KZReportWidthSizeFitTypeNone:
                self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, reportWidth, self.frame.size.height);
                break;
            case KZReportWidthSizeFitTypeAll:
                _cellWidth = (frameWidth-((_colCount-1)*_verticalLineWidth+_leftBorderLineWidth+_rightBorderLineWidth))/(float)_colCount;
                _leftWidth = _cellWidth;
                break;
            case KZReportWidthSizeFitTypeWithoutFirst:
                _cellWidth = (frameWidth-((_colCount-1)*_verticalLineWidth+_leftBorderLineWidth+_rightBorderLineWidth)-_leftWidth)/(float)(_colCount-1);
            default:
                break;
        }
    }
    
    if (reportHeight < frameHeight) {
        if ([_delegate autoFitHeaderHeight] && _heightSizeFitType == KZReportWidthSizeFitTypeAll) {
            _heightSizeFitType = KZReportHeightSizeFitTypeWithoutFirst;
        }
        if ([_delegate autoFitBodyHeight]) {
            _heightSizeFitType = KZReportHeightSizeFitTypeNone;
        }
        
        switch (_heightSizeFitType) {
            case KZReportHeightSizeFitTypeNone:
                self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, reportHeight);
                break;
            case KZReportHeightSizeFitTypeAll:
                _cellHeight = (frameHeight-(_rowCount*_horizonLineWidth+_topBorderLineWidth+_bottomBorderLineWidth))/(float)(_rowCount+1);
                _bodyHeight = _cellHeight*_rowCount+_horizonLineWidth*(_rowCount-1);
                _headerRowHeight = _cellHeight;
                _headerHeight = _headerRowHeight;
                break;
            case KZReportHeightSizeFitTypeWithoutFirst:
                _cellHeight = (frameHeight-(_rowCount*_horizonLineWidth+_topBorderLineWidth+_bottomBorderLineWidth)-_headerHeight)/(float)_rowCount;
                _bodyHeight = _cellHeight*_rowCount+_horizonLineWidth*(_rowCount-1);
                break;
            default:
                break;
        }
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    [array addObject:[NSNumber numberWithFloat:_leftWidth]];
    for (NSInteger i = 1; i < _colCount; ++i) {
        
        [array addObject:[NSNumber numberWithFloat:_cellWidth]];
    }
    
    _colWidthArray = array;
    
    if (!_autoFitBodyHeight) {
        _bodyRowHeightArray = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < _rowCount; ++i) {
            [_bodyRowHeightArray addObject:[NSNumber numberWithFloat:_cellHeight]];
        }
    }
    
}


#pragma mark - scrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _bottomRightScroll) {
        _topRightScroll.contentOffset = CGPointMake(_bottomRightScroll.contentOffset.x, 0);
        _bottomLeftScroll.contentOffset = CGPointMake(0, _bottomRightScroll.contentOffset.y);
    }
}

@end
