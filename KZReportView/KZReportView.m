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

@interface KZReportView ()
@property (nonatomic, strong) UIView *topLeftView;
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

@property (nonatomic, strong) NSMutableDictionary *visibleCells;
@property (nonatomic, strong) NSMutableDictionary *visibleCellsBackup;
@property (nonatomic, strong) NSMutableArray *cellPool;

@end

@implementation KZReportView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
        _visibleCells = [[NSMutableDictionary alloc] init];
        _visibleCellsBackup = [[NSMutableDictionary alloc] init];
        _cellPool = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self reloadViews];
}

- (void)reload {
    [_visibleCells removeAllObjects];
    [self setStyle];
    [self setContent];
    [self reloadViews];
}

- (void)setDatasource:(id<KZReportViewDataSource>)datasource {
    if (_datasource != datasource) {
        _datasource = datasource;
        [self setStyle];
        [self setContent];
    }
}

- (void)setDelegate:(id<KZReportViewDelegate>)delegate {
    if (_delegate != delegate) {
        _delegate = delegate;
        [self setStyle];
    }
}

- (void)setContent {
    _colCount = [[_datasource headerDataforKZReportView:self] count];
    _rowCount = [_datasource bodyRowCountInReport];
    [self sizeToFit];
    CGFloat rightWidth = - _verticalLineWidth;
    for (NSInteger i = 1; i < _colCount; ++i) {
        rightWidth += _cellWidth+_verticalLineWidth;
    }
    
    _topRightScroll.frame = CGRectMake(_leftBorderLineWidth+_verticalLineWidth+_leftWidth, _topBorderLineWidth, self.frame.size.width-(_leftBorderLineWidth+_leftWidth+_verticalLineWidth+ _rightBorderLineWidth), _headerHeight);
    _topRightScroll.contentSize = CGSizeMake(rightWidth, 0);
    
    _bottomLeftScroll.frame = CGRectMake(_leftBorderLineWidth, _topBorderLineWidth+_horizonLineWidth+_headerHeight, _leftWidth, self.frame.size.height-(_topBorderLineWidth+_headerHeight+_horizonLineWidth+_bottomBorderLineWidth));
    _bottomLeftScroll.contentSize = CGSizeMake(0, _bodyHeight);
    
    _bottomRightScroll.frame = CGRectMake(_leftBorderLineWidth+_verticalLineWidth+_leftWidth, _topBorderLineWidth+_horizonLineWidth+_headerHeight, self.frame.size.width-(_leftBorderLineWidth+_leftWidth+_verticalLineWidth+_rightBorderLineWidth), self.frame.size.height-(_topBorderLineWidth+_headerHeight+_horizonLineWidth+_bottomBorderLineWidth));
    _bottomRightScroll.contentSize = CGSizeMake(rightWidth, _bodyHeight);
    
    _topLeftView.frame = CGRectMake(_leftBorderLineWidth, _topBorderLineWidth, _leftWidth, _headerHeight);
    self.backgroundColor = _borderLineColor;
}

- (void)initSubViews {
    _topRightScroll = [[UIScrollView alloc] init];
    _topRightScroll.backgroundColor = [UIColor clearColor];
    _topRightScroll.scrollEnabled = YES;
    _topRightScroll.showsHorizontalScrollIndicator = NO;
    _topRightScroll.delegate = self;
    
    _bottomLeftScroll = [[UIScrollView alloc] init];
    _bottomLeftScroll.backgroundColor = [UIColor clearColor];
    _bottomLeftScroll.scrollEnabled = YES;
    _bottomLeftScroll.showsVerticalScrollIndicator = NO;
    _bottomLeftScroll.delegate = self;
    
    _bottomRightScroll = [[UIScrollView alloc] init];
    _bottomRightScroll.backgroundColor = [UIColor clearColor];
    _bottomRightScroll.scrollEnabled = YES;
    _bottomRightScroll.bounces = NO;
    _bottomRightScroll.delegate = self;
    
    _topLeftView = [[UIView alloc] init];
    _topLeftView.backgroundColor = [UIColor clearColor];
    
    
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
        if (_autoFitHeaderHeight && _heightSizeFitType == KZReportHeightSizeFitTypeAll) {
            _heightSizeFitType = KZReportHeightSizeFitTypeWithoutFirst;
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
    
}

- (void)addCellWithIndexPath:(NSIndexPath *)indexPath {
    KZReportCell *cell = [self dequeReusableCellWithIndexPath:indexPath];
    if (cell.superview == nil) {
        cell.lineBreakMode = NSLineBreakByWordWrapping;
        cell.numberOfLines = 0;
        if (indexPath.section == 0) {
            if (indexPath.row == -1) {
                //topleft
                cell.frame = CGRectMake(0, 0, _leftWidth, _headerHeight);
                cell.text = [[_datasource headerDataforKZReportView:self] objectAtIndex:0];
                cell.backgroundColor = _headerBackgroundColor;
                UIFont *font = [UIFont systemFontOfSize:_headerFontSize];
                cell.font = font;
                cell.textColor = _headerTextColor;
                cell.textAlignment = _headerTextAlignment;
                [_topLeftView addSubview:cell];
            } else {
                //bottomleft
                cell.frame = CGRectMake(0, indexPath.row*(_cellHeight+_horizonLineWidth), _leftWidth, _cellHeight);
                cell.text = [[_datasource rowDataforKZReportView:self forIndex:indexPath.row] objectAtIndex:0];
                cell.backgroundColor = _bodyBackgroundColor;
                UIFont *font = [UIFont systemFontOfSize:_bodyFontSize];
                cell.font = font;
                cell.textColor = _bodyTextColor;
                cell.textAlignment = _bodyTextAlignment;
                [_bottomLeftScroll addSubview:cell];
            }
        } else {
            if (indexPath.row == -1) {
                //topright
                cell.frame = CGRectMake((indexPath.section-1)*(_cellWidth+_verticalLineWidth), 0, _cellWidth, _headerHeight);
                cell.text = [[_datasource headerDataforKZReportView:self] objectAtIndex:indexPath.section];
                cell.backgroundColor = _headerBackgroundColor;
                UIFont *font = [UIFont systemFontOfSize:_headerFontSize];
                cell.font = font;
                cell.textColor = _headerTextColor;
                cell.textAlignment = _headerTextAlignment;
                [_topRightScroll addSubview:cell];
            } else {
                //bottomright
                cell.frame = CGRectMake((indexPath.section-1)*(_cellWidth+_verticalLineWidth), indexPath.row*(_cellHeight+_horizonLineWidth), _cellWidth, _cellHeight);
                cell.text = [[_datasource rowDataforKZReportView:self forIndex:indexPath.row] objectAtIndex:indexPath.section];
                cell.backgroundColor = _bodyBackgroundColor;
                UIFont *font = [UIFont systemFontOfSize:_bodyFontSize];
                cell.font = font;
                cell.textColor = _bodyTextColor;
                cell.textAlignment = _bodyTextAlignment;
                [_bottomRightScroll addSubview:cell];
            }
        }
    }
    [_visibleCellsBackup setObject:cell forKey:indexPath];
}

- (void)CleanCellsBackup {
    for (NSIndexPath *indexPath in _visibleCellsBackup.keyEnumerator) {
        KZReportCell *cell = [_visibleCellsBackup objectForKey:indexPath];
        if (!cell.isOccupied) {
            [cell removeFromSuperview];
            [_cellPool addObject:cell];
        } else {
            cell.isOccupied = NO;
        }
    }
    [_visibleCellsBackup removeAllObjects];
}

- (KZReportCell *)dequeReusableCellWithIndexPath:(NSIndexPath*)indexPath{
    KZReportCell *cell = [_visibleCells objectForKey:indexPath];
    if (cell) {
        cell.isOccupied = YES;
    } else {
        if ([_cellPool count] > 0) {
            cell = [_cellPool objectAtIndex:0];
            [_cellPool removeObjectAtIndex:0];
        } else {
            cell = [[KZReportCell alloc] init];
        }
    }
    return cell;
}

- (void)reloadViews {
    NSInteger currentLeftCol = (NSInteger)(_bottomRightScroll.contentOffset.x+1e-6)/(NSInteger)(_cellWidth+_verticalLineWidth+1e-6)-5;
    NSInteger currentTopRow = (NSInteger)(_bottomRightScroll.contentOffset.y+1e-6)/(NSInteger)(_cellHeight+_horizonLineWidth+1e-6)-5;
    NSInteger currentRightCol = (NSInteger)(_bottomRightScroll.contentOffset.x+_bottomRightScroll.frame.size.width+1e-6)/(NSInteger)(_cellWidth+_verticalLineWidth+1e-6)+5;
    NSInteger currentBottomRow = (NSInteger)(_bottomRightScroll.contentOffset.y+_bottomRightScroll.frame.size.height+1e-6)/(NSInteger)(_cellHeight+_horizonLineWidth+1e-6)+5;
    currentLeftCol = MAX(0, currentLeftCol);
    currentTopRow = MAX(0, currentTopRow);
    currentRightCol = MIN([[_datasource headerDataforKZReportView:self] count]-2, currentRightCol);
    currentBottomRow = MIN([_datasource bodyRowCountInReport]-1, currentBottomRow);
    [self addCellWithIndexPath:[NSIndexPath indexPathForRow:-1 inSection:0]];
    for (NSInteger row = currentTopRow; row <= currentBottomRow; ++row) {
        for (NSInteger col = currentLeftCol; col <= currentRightCol; ++col) {
            [self addCellWithIndexPath:[NSIndexPath indexPathForRow:row inSection:col+1]];
        }
    }
    for (NSInteger row = currentTopRow; row <= currentBottomRow; ++row) {
        [self addCellWithIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    }
    for (NSInteger col = currentLeftCol; col <= currentRightCol; ++col) {
        [self addCellWithIndexPath:[NSIndexPath indexPathForRow:-1 inSection:col+1]];
    }
    NSMutableDictionary *temp = _visibleCellsBackup;
    _visibleCellsBackup = _visibleCells;
    _visibleCells = temp;
    [self CleanCellsBackup];
}


#pragma mark - scrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:_bottomRightScroll]) {
        _topRightScroll.contentOffset = CGPointMake(_bottomRightScroll.contentOffset.x, 0);
        _bottomLeftScroll.contentOffset = CGPointMake(0, _bottomRightScroll.contentOffset.y);
    } else if ([scrollView isEqual:_topRightScroll]) {
        _bottomLeftScroll.contentOffset = CGPointMake(0, _bottomRightScroll.contentOffset.y);
        _bottomRightScroll.contentOffset = CGPointMake(_topRightScroll.contentOffset.x, _bottomRightScroll.contentOffset.y);
    } else if ([scrollView isEqual:_bottomLeftScroll]) {
        _topRightScroll.contentOffset = CGPointMake(_bottomRightScroll.contentOffset.x, 0);
        _bottomRightScroll.contentOffset = CGPointMake(_bottomRightScroll.contentOffset.x, _bottomLeftScroll.contentOffset.y);
    }
    [self reloadViews];
}

- (void)scrollViewDidEndDecelerating:(nonnull UIScrollView *)scrollView {
    [self reloadViews];
}

@end
