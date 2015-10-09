//
//  PostActionBar.m
//  WordPressKit
//
//  Created by wuxueqian on 15/10/3.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "PostActionBar.h"
#import "PostActionBarItem.h"

static CGFloat ActionBarMinButtonWidth = 100.0;
static NSInteger ActionBarMoreButtonIndex = 999;
static const UIEdgeInsets BackButtonImageInsets = {1.0, 0.0, 0.0, 0.0};
static const UIEdgeInsets MoreButtonImageInsets = {3.0, 0.0, 0.0, 4.0};

@interface PostActionBar()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, assign) NSInteger currentBatch;
@property (nonatomic, assign) BOOL shouldShowMore;
@property (nonatomic, assign) BOOL needsSetupButtons;

@end

@implementation PostActionBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


#pragma mark - life cycle methods
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setupView];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setupButtonsIfNeeded];
}

/**
*  设置动作条的条目
*
*  @param items 动作条按钮对象
*/
- (void)setItems:(NSArray *)items
{
    _items = items;
    
    [self setupButtons];
    [self configureButtons];
}

/**
 *  初始化ActionBar的视图
 */
- (void)setupView
{
    _items = @[];
    _buttons = @[];
    
    self.contentView = [[UIView alloc] initWithFrame:self.bounds];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentView.backgroundColor = [UIColor colorWithRed:235/255.0 green:240/255.0 blue:243/255.0 alpha:1.0];
    [self addSubview:self.contentView];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_contentView);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_contentView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_contentView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    // Trap double taps to prevent touches from regstering in the parent cell while the bar is animating.
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    tgr.numberOfTapsRequired = 2;
    [self addGestureRecognizer:tgr];
    
}

/**
 *  初始化按钮
 */
- (void)setupButtons
{
    for (UIButton *button in self.buttons) {
        [button removeFromSuperview];
    }
    self.currentBatch = 0;
    self.shouldShowMore = [self checkIfShouldShowMoreButton];
    NSInteger numOfButtons = [self maxButtonsToDisplay];
    numOfButtons = MIN(numOfButtons, [self.items count]);
    
    NSMutableArray *buttons = [NSMutableArray array];
    for (NSInteger i = 0; i < numOfButtons; i++) {
        UIButton *button = [self newButton];
        [self.contentView addSubview:button];
        [buttons addObject:button];
    }
    self.buttons = buttons;
    
    [self setupConstraints];
}

/**
 *  初始化一个按钮
 *
 *  @return 按钮
 */
- (UIButton *)newButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.exclusiveTouch = YES;
    button.backgroundColor = [UIColor colorWithRed:243/255.0 green:246/255.0 blue:248/255.0 alpha:1.0];
    button.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [button setTitleColor:[UIColor colorWithRed:15/255.0 green:115/255.0 blue:176/255.0 alpha:1.0] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:1/255.0 green:36/255.0 blue:60/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(handleButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

#pragma mark - check conditions

/**
 *  根据情况显示更多按钮
 */
- (void)setupButtonsIfNeeded
{
    if ([self checkIfShouldShowMoreButton] != self.shouldShowMore) {
        [self setupButtons];
        [self configureButtons];
    }
}

/**
 *  检查是否需要显示更多按钮
 *
 *  @return 布尔值-是否该显示更多按钮
 */
- (BOOL)checkIfShouldShowMoreButton
{
    return [self maxButtonsToDisplay] < [self.items count];
}

/**
 *  计算最多能显示的按钮数
 *
 *  @return 最多能显示的按钮个数
 */
- (NSInteger)maxButtonsToDisplay
{
    return (NSInteger)floor(CGRectGetWidth(self.frame) / ActionBarMinButtonWidth);
}

/**
 *  获取当前按钮
 *
 *  @return 按钮对象数组
 */
- (NSArray *)currentBatchOfItems
{
    NSInteger batchSize = [self.buttons count];
    if (batchSize == 0) {
        return @[];
    }
    
    if (self.shouldShowMore) {
        batchSize--;
    }
    NSInteger index = self.currentBatch * batchSize;
    
    // Validate the index and batch size do not exceed the limits of the array
    if (index >= [self.items count]) {
        // Safety net. Currently at the end of the available items so reset to zero.
        index = 0;
        self.currentBatch = 0;
    }
    // Adjust the batch size if we have fewer items in the array.
    if ((index + batchSize) >= [self.items count]) {
        batchSize = [self.items count] - index;
    }
    
    NSRange rng = NSMakeRange(index, batchSize);
    return [self.items subarrayWithRange:rng];
}

/**
 *  返回数组对象的索引
 *
 *  @param item PostActionBarItem对象
 *
 *  @return 索引值
 */
- (NSInteger)indexOfItem:(PostActionBarItem *)item
{
    return [self.items indexOfObject:item];
}

/**
 *  显示更多的隐藏按钮
 *
 *  @param isLastBatch 是否是最后一组PostActionBarItem对象
 *
 *  @return 返回PostActionBarItem对象
 */
- (PostActionBarItem *)moreItem:(BOOL)isLastBatch;
{
    PostActionBarItem *item;
    if (isLastBatch) {
        item = [PostActionBarItem itemWithTitle:NSLocalizedString(@"返回", @"")
                                              image:[UIImage imageNamed:@"post_actionbar_icon_back"]
                                   highlightedImage:nil];
        item.imageInsets = BackButtonImageInsets;
    } else {
        item = [PostActionBarItem itemWithTitle:NSLocalizedString(@"更多", @"")
                                              image:[UIImage imageNamed:@"post_actionbar_icon_more"]
                                   highlightedImage:nil];
        item.imageInsets = MoreButtonImageInsets;
    }
    return item;
}

#pragma mark - configure

/**
 *  配置按钮
 */
- (void)configureButtons
{
    // Reset all buttons.
    for (UIButton *button in self.buttons) {
        [self configureButton:button forItem:nil atIndex:0];
    }
    
    NSArray *itemsToShow = [self currentBatchOfItems];
    for (NSInteger i = 0; i < [itemsToShow count]; i++) {
        PostActionBarItem *item = [itemsToShow objectAtIndex:i];
        UIButton *button =[self.buttons objectAtIndex:i];
        [self configureButton:button forItem:item atIndex:[self indexOfItem:item]];
    }
    
    if (self.shouldShowMore) {
        BOOL isLastBatch = [itemsToShow lastObject] == [self.items lastObject];
        PostActionBarItem *moreItem = [self moreItem:isLastBatch];
        [self configureButton:[self.buttons lastObject] forItem:moreItem atIndex:ActionBarMoreButtonIndex];
    }
}

- (void)configureButton:(UIButton *)button forItem:(PostActionBarItem *)item atIndex:(NSUInteger)index
{
    button.tag = index;
    [button setTitle:item.title forState:UIControlStateNormal];
    [button setTitle:item.title forState:UIControlStateHighlighted];
    [button setImage:item.image forState:UIControlStateNormal];
    [button setImageEdgeInsets:item.imageInsets];
    [button setImage:item.highlightedImage forState:UIControlStateHighlighted];
}

- (void)configureButtonsWithAnimation
{
    // Frames for transtion
    CGRect frame = self.contentView.frame;
    CGRect smallFrame = frame;
    smallFrame.origin.x += smallFrame.size.width / 2.0;
    smallFrame.origin.y += smallFrame.size.height / 2.0;
    smallFrame.size = CGSizeZero;
    
    // Get snapshot of current state
    UIView *viewOldState = [self.contentView snapshotViewAfterScreenUpdates:NO];
    viewOldState.frame = frame;
    [self addSubview:viewOldState];
    
    [self configureButtons];
    
    UIView *viewNewState = [self.contentView snapshotViewAfterScreenUpdates:YES];
    viewNewState.frame = smallFrame;
    viewNewState.alpha = 0;
    [self addSubview:viewNewState];
    self.contentView.hidden = YES;
    
    [UIView animateWithDuration:0.3 animations:^{
        viewOldState.frame = smallFrame;
        viewOldState.alpha = 0;
        viewNewState.frame = frame;
        viewNewState.alpha = 1;
        
    } completion:^(BOOL finished) {
        [viewOldState removeFromSuperview];
        [viewNewState removeFromSuperview];
        self.contentView.hidden = NO;
    }];
}

#pragma mark - constraint

/**
 *  设置约束
 */
- (void)setupConstraints
{
    if ([self.buttons count] == 0) {
        return;
    }
    
    UIButton *button;
    UIButton *previousButton;
    NSDictionary *views;
    
    // One button to rule them all...
    if ([self.buttons count] == 1) {
        button = [self.buttons firstObject];
        views = NSDictionaryOfVariableBindings(button);
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[button]|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button]|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:views]];
    }
    
    // left-most button
    button = [self.buttons firstObject];
    views = NSDictionaryOfVariableBindings(button);
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[button]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
    
    
    // in-between buttons
    for (NSInteger i = 1; i < [self.buttons count] - 1; i++) {
        previousButton = button;
        button = [self.buttons objectAtIndex:i];
        views = NSDictionaryOfVariableBindings(button, previousButton);
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[previousButton]-(1)-[button(==previousButton)]"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button]|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:views]];
    }
    
    previousButton = button;
    button = [self.buttons lastObject];
    views = NSDictionaryOfVariableBindings(button, previousButton);
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[previousButton]-(1)-[button(==previousButton)]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];
    [self setNeedsUpdateConstraints];
}

#pragma mark - selector

- (void)orientationDidChange:(NSNotification *)notification
{
    [self setupButtonsIfNeeded];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)sender
{
    // noop.
}

- (void)handleButtonTap:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger index = button.tag;
    if (index == ActionBarMoreButtonIndex) {
        self.currentBatch++;
        [self configureButtonsWithAnimation];
        return;
    }
    PostActionBarItem *item = [self.items objectAtIndex:index];
    if (item.callback) {
        item.callback();
    }
}

@end
