//
//  JLTextFieldTagView.m
//  textFieldTag
//
//  Created by 16fan on 15/4/17.
//  Copyright (c) 2015年 16fan. All rights reserved.
//

#import "JLTextFieldTagView.h"
#import "JLTextField.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]  

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface JLTextFieldTagView ()<UITextFieldDelegate>{
    int Row;
    BOOL isInput;
}

@property (nonatomic, strong) UITextField *showField;
@property (nonatomic, strong) UILabel *showLabel;
@property (nonatomic, strong) UIButton *keyButton;
@property (nonatomic, strong) JLTextField *inputField;
@property (nonatomic, strong) UIButton *tagDeleteButton;

@property (nonatomic, strong) NSMutableArray *tagViews;
@property (nonatomic, strong) NSMutableArray *tagsMade;

@end

@implementation JLTextFieldTagView

#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initProperties];
        [self initControls];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initProperties];
    [self initControls];
}
#pragma mark - Property Get / Set

- (NSArray *)tags
{
    return _tagsMade;
}

#pragma mark - Interfaces

- (void)clear
{
    _inputField.text = @"\u200B";
    [_tagsMade removeAllObjects];
    [self changeArrangeSubViews];
}

- (void)setTextToInputSlot:(NSString *)text
{
    _inputField.text = text;
}

- (void)addTagToLast:(NSString *)tagTitle{
    if (tagTitle.length>19) {
        NSLog(@"最多18个字!");
        return;
    }
    
    tagTitle = [tagTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (tagTitle.length==0) {
        NSLog(@"不能输入空白标签!");
        return;
    }
    for (NSString *title in _tagsMade)
    {
        if ([tagTitle isEqualToString:title])
        {
            NSLog(@"已存在相同标签!");
            _inputField.text=@"\u200B";
            [self layoutInitial];
            return;
        }
    }
    
    _inputField.text=@"\u200B";
    
    [self addTagViewToLast:tagTitle];
    [self layoutInputAndView];
    
    if ([_delegate respondsToSelector:@selector(tagWriteView:didMakeTag:)])
    {
        [_delegate tagWriteView:self didMakeTag:tagTitle];
    }
}

- (void)removeTagToLast:(NSString *)tagTitle
{
    NSInteger foundedIndex = -1;
    for (NSString *t in _tagsMade)
    {
        if ([tagTitle isEqualToString:t])
        {
            NSLog(@"FOUND!");
            foundedIndex = (NSInteger)[_tagsMade indexOfObject:t];
            break;
        }
    }
    
    if (foundedIndex == -1)
    {
        return;
    }
    
    [_tagsMade removeObjectAtIndex:foundedIndex];
    
    [self removeTagViewWithIndex:foundedIndex];
    [self layoutInputAndView];
    
    if ([_delegate respondsToSelector:@selector(tagWriteView:didRemoveTag:)])
    {
        [_delegate tagWriteView:self didRemoveTag:tagTitle];
    }
}

- (void)addTags:(NSArray *)tags
{
    for (NSString *tag in tags)
    {
        NSArray *result = [_tagsMade filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF == %@", tag]];
        if (result.count == 0)
        {
            [_tagsMade addObject:tag];
        }
    }
    
    [self changeArrangeSubViews];
}

- (void)removeTags:(NSArray *)tags
{
    for (NSString *tag in tags)
    {
        NSArray *result = [_tagsMade filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF == %@", tag]];
        if (result)
        {
            [_tagsMade removeObjectsInArray:result];
        }
    }
    [self changeArrangeSubViews];
}

- (void)setOpenWordCount:(BOOL)openWordCount {
    if (openWordCount) {
        UIView *inputAccessoryView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        inputAccessoryView.backgroundColor=[UIColor whiteColor];
        
        UIView *fenggeV=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
        fenggeV.backgroundColor= UIColorFromRGB(0xdedede);
        [inputAccessoryView addSubview:fenggeV];
        
        _inputField.inputAccessoryView=inputAccessoryView;
        _showLabel=[[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-155-30, 0, 140, 40)];
        _showLabel.textAlignment=NSTextAlignmentRight;
        _showLabel.text=[NSString stringWithFormat:@"%d",_maxTagLength];
        _showLabel.textColor=UIColorFromRGB(0x848484);
        [inputAccessoryView addSubview:_showLabel];
        
        _keyButton=[UIButton buttonWithType:UIButtonTypeSystem];
        _keyButton.frame=CGRectMake(SCREEN_WIDTH-53,0,60,40);
        [_keyButton setImage:[UIImage imageNamed:@"下拉.png"] forState:UIControlStateNormal];
        [_keyButton setTintColor:UIColorFromRGB(0xaaa9a9)];
        _keyButton.enabled=YES;
        [_keyButton addTarget:self action:@selector(exitKeyboard:) forControlEvents:UIControlEventTouchUpInside];
        [inputAccessoryView addSubview:_keyButton];
    }
    _openWordCount=openWordCount;
}

#pragma mark - Internals

- (void)initProperties
{
    _font = [UIFont systemFontOfSize:14.0f];
    _tagBackgroundColor = [UIColor whiteColor];
    _tagTextgroundColor = [UIColor blackColor];
    //max 18 Chinese
    _maxTagLength = 18;
    _tagGap = 10;
    
    _tagsMade = [NSMutableArray array];
    _tagViews = [NSMutableArray array];
}

- (void)initControls
{
    self.backgroundColor=[UIColor whiteColor];
    
    _showField=[[UITextField alloc] initWithFrame:CGRectMake(_tagGap+10, Row*44, SCREEN_WIDTH, 44)];
    _showField.placeholder=@"添加目的地";
    _showField.userInteractionEnabled=NO;
    _showField.font=_font;
    [self addSubview:_showField];
    
    _inputField = [[JLTextField alloc] initWithFrame:CGRectMake(_tagGap, 8+Row*44, SCREEN_WIDTH-2*_tagGap, 28)];
    _inputField.font = _font;
    //TODO:add Zero width space
    _inputField.text=@"\u200B";
    _inputField.backgroundColor=[UIColor clearColor];
    _inputField.autocapitalizationType=UITextAutocapitalizationTypeWords;
    _inputField.returnKeyType = UIReturnKeyDone;
    [_inputField textRectForBounds:_inputField.bounds];
    _inputField.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    _inputField.delegate = self;
    [_inputField addTarget:self action:@selector(checkTextField:) forControlEvents:UIControlEventEditingChanged];
    [self addSubview:_inputField];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WillShowMenu:) name:UIMenuControllerWillShowMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HideMenu:) name:UIMenuControllerDidHideMenuNotification object:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillShowMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
}

- (void)exitKeyboard:(id)sender
{
    [_inputField resignFirstResponder];
}

- (void)changeArrangeSubViews{
    
    NSMutableArray *newTags = [[NSMutableArray alloc] initWithCapacity:_tagsMade.count];
    CGFloat posX = _tagGap;
    int row = 0;
    for (NSString *tagTitle in _tagsMade)
    {
        UIButton *tagBtn = [self tagButtonWithTag:tagTitle];
        [newTags addObject:tagBtn];
        tagBtn.tag = [newTags indexOfObject:tagBtn];
        
        CGRect viewFrame = tagBtn.frame;
        if (SCREEN_WIDTH-posX-10<viewFrame.size.width) {
            row++;
            posX = _tagGap;
        }
        viewFrame.origin.x = posX;
        viewFrame.origin.y = row*44+8;
        tagBtn.frame=viewFrame;

        posX += tagBtn.frame.size.width + _tagGap;
        [self addSubview:tagBtn];
    }
    Row=row;
    
    for (UIView *oldTagView in _tagViews)
    {
        [oldTagView removeFromSuperview];
    }
    _tagViews = newTags;
    
    [self layoutInputAndView];
}

- (void)layoutInput
{
    _showField.hidden=YES;
    _inputField.layer.borderColor = isInput?[UIColor redColor].CGColor:[UIColor grayColor].CGColor;
    _inputField.layer.borderWidth = 0.5f;
    _inputField.layer.cornerRadius = _inputField.frame.size.height * 0.2f;
}

- (void)layoutInitial{
    _showField.hidden=NO;
    _inputField.layer.borderColor = [UIColor clearColor].CGColor;
}

- (CGFloat)widthForInputViewWithText:(NSString *)text{
    return MAX(70.0, [text sizeWithAttributes:@{NSFontAttributeName:_font}].width + 30.0f);
}

- (CGFloat)posXForObjectNextToLastTagView
{
    CGFloat accumX = _tagGap;
    if (_tagViews.count)
    {
        UIView *last = _tagViews.lastObject;
        accumX = last.frame.origin.x + last.frame.size.width + _tagGap;
    }
    return accumX;
}

- (void)addTagViewToLast:(NSString *)tagTitle{
    [_tagsMade addObject:tagTitle];
    UIButton *tagBtn = [self tagButtonWithTag:tagTitle];
    [_tagViews addObject:tagBtn];
    tagBtn.tag = [_tagViews indexOfObject:tagBtn];
    [self addSubview:tagBtn];
}

- (UIButton *)tagButtonWithTag:(NSString *)tagTitle
{
    UIButton *tagBtn = [[UIButton alloc] init];
    [tagBtn.titleLabel setFont:_font];
    [tagBtn setBackgroundColor:UIColorFromRGB(0xf0f0f0)];
    [tagBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    
    [tagBtn addTarget:self action:@selector(tagButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    [tagBtn setTitle:tagTitle forState:UIControlStateNormal];
    CGRect btnFrame = tagBtn.frame;
    btnFrame.origin.x = _inputField.frame.origin.x;
    btnFrame.origin.y = _inputField.frame.origin.y;
    btnFrame.size.width = [tagBtn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:_font}].width  + 20.0f;
    btnFrame.size.height = _inputField.frame.size.height;
    
    tagBtn.layer.cornerRadius = 4;
    tagBtn.frame = CGRectIntegral(btnFrame);
    
    NSLog(@"btn frame [%@] = %@", tagTitle, NSStringFromCGRect(tagBtn.frame));
    
    return tagBtn;
}

- (void)layoutInputAndView
{
    CGFloat accumX = [self posXForObjectNextToLastTagView];
    
    CGRect newFrame=self.frame;
    newFrame.size.height=44+Row*44;
    self.frame=newFrame;
    
    CGRect inputRect = _inputField.frame;
    inputRect.origin.x = accumX;
    inputRect.origin.y = 8.0+Row*44;
    _inputField.frame = inputRect;
    
    CGRect showRect = _showField.frame;
    showRect.origin.x = _inputField.frame.origin.x+10;
    showRect.origin.y = Row*44;
    _showField.frame= showRect;
    
    [self layoutInitial];
    [self setRowToShowInputView:[self widthForInputViewWithText:_inputField.text]];
}

- (void)setRowToShowInputView:(CGFloat)width{
    if (_inputField.frame.origin.x+width+10>SCREEN_WIDTH) {
        CGRect inputRect = _inputField.frame;
        inputRect.size.width = SCREEN_WIDTH-_inputField.frame.origin.x-_tagGap;
        _inputField.frame = inputRect;
    }
    //Row++;
    if (_inputField.frame.origin.x>_tagGap+1&&_inputField.frame.origin.x+width+10>SCREEN_WIDTH) {
        Row++;
        CGRect newFrame=self.frame;
        newFrame.size.height=44+Row*44;
        self.frame=newFrame;
        
        CGRect inputFrame=_inputField.frame;
        inputFrame.origin.x=_tagGap;
        inputFrame.origin.y=8.0+Row*44;
        _inputField.frame=inputFrame;
        
        CGRect showRect = _showField.frame;
        showRect.origin.x = _inputField.frame.origin.x+10;
        showRect.origin.y = Row*44;
        _showField.frame= showRect;
    }
    //Row--;
    if (_inputField.frame.origin.x<_tagGap+1) {
        if (Row>0) {
            CGFloat accumX=[self posXForObjectNextToLastTagView];
            if (width<=SCREEN_WIDTH-accumX-10) {
                Row--;
                CGRect newFrame=self.frame;
                newFrame.size.height=44+Row*44;
                self.frame=newFrame;
                
                CGRect inputFrame=_inputField.frame;
                inputFrame.origin.x=accumX;
                inputFrame.origin.y=8.0+Row*44;
                _inputField.frame=inputFrame;
                
                CGRect showRect = _showField.frame;
                showRect.origin.x = _inputField.frame.origin.x+10;
                showRect.origin.y = Row*44;
                _showField.frame= showRect;
            }
        }
    }
    
    if ([_inputField.text isEqualToString:@"\u200B"]) {
        if (_inputField.frame.size.width<SCREEN_WIDTH-_inputField.frame.origin.x-_tagGap&&SCREEN_WIDTH-_inputField.frame.origin.x-_tagGap>70) {
            CGRect inputRect = _inputField.frame;
            inputRect.size.width = SCREEN_WIDTH-_inputField.frame.origin.x-_tagGap;
            _inputField.frame = inputRect;
        }
    }
    
    if ([_delegate respondsToSelector:@selector(tagWriteChangeView:)])
    {
        [_delegate tagWriteChangeView:self];
    }
}

- (void)removeTagViewWithIndex:(NSUInteger)index
{
    NSAssert(index < _tagViews.count, @"incorrected index");
    if (index >= _tagViews.count)
    {
        return;
    }
    
    UIView *deletedView = [_tagViews objectAtIndex:index];
    [deletedView removeFromSuperview];
    [_tagViews removeObject:deletedView];

    CGFloat posX = _tagGap;
    int row = 0;
    for (int idx = 0; idx < _tagViews.count; ++idx)
    {
        UIView *view = [_tagViews objectAtIndex:idx];
        CGRect viewFrame = view.frame;
        
        if (SCREEN_WIDTH-posX-10<viewFrame.size.width) {
            row++;
            posX = _tagGap;
        }
        viewFrame.origin.x = posX;
        viewFrame.origin.y = row*44+8;
        view.frame = viewFrame;
        
        posX += viewFrame.size.width + _tagGap;
        
        view.tag = idx;
    }
    Row=row;
}

#pragma mark - UI Actions

- (void)tagButtonSelected:(UIButton *)sender{
    [self becomeFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if (sender.selected) {
        [sender setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [sender setBackgroundColor:UIColorFromRGB(0xf0f0f0)];
        sender.selected=NO;
        [menu setMenuVisible:NO animated:YES];
    }else{
        [menu setMenuVisible:NO];
        [_tagDeleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_tagDeleteButton setBackgroundColor:UIColorFromRGB(0xf0f0f0)];
        _tagDeleteButton.selected=NO;
        _tagDeleteButton=sender;
        [menu setTargetRect:sender.frame inView:self];
        [menu setMenuVisible:YES animated:YES];
    }
}

- (void)deleteBackspace:(UIButton *)sender{
    if (sender.selected) {
        [self removeTagToLast:sender.currentTitle];
    }else{
        [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sender setBackgroundColor:[UIColor grayColor]];
        sender.selected=YES;
    }
}

#pragma mark - Custom Menu

- (void)HideMenu:(NSNotification *)notification{
    [_tagDeleteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_tagDeleteButton setBackgroundColor:UIColorFromRGB(0xf0f0f0)];
    _tagDeleteButton.selected=NO;
    _tagDeleteButton=nil;
}
- (void)WillShowMenu:(NSNotification *)notification{
    [_tagDeleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_tagDeleteButton setBackgroundColor:[UIColor grayColor]];
    _tagDeleteButton.selected=YES;
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (_tagDeleteButton) {
        return action == @selector(delete:);
    }
    return NO;
}

- (void)delete:(id)sender{
    [self removeTagToLast:_tagDeleteButton.currentTitle];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    if ([textField.text isEqualToString:@"\u200B"]&&([string isEqualToString:@""]||[string isEqualToString:@" "])) {
        [self layoutInitial];
        if (_tagViews.count > 0)
        {
            [self deleteBackspace:_tagViews.lastObject];
        }
        return NO;
    }
    return YES;
}

- (void)checkTextField:(UITextField *)sender{
    
    CGFloat newWidth = [self widthForInputViewWithText:sender.text];
    CGRect inputRect = _inputField.frame;
    inputRect.size.width = newWidth;
    _inputField.frame = inputRect;
    [self setRowToShowInputView:newWidth];
    
    sender.text.length>1?[self layoutInput]:[self layoutInitial];
    
    bool isChinese;//判断当前输入法是否是中文
    if ([_inputField.textInputMode.primaryLanguage isEqualToString: @"en-US"]) {
        isChinese = false;
    }
    else
    {
        isChinese = true;
    }

    // 18位
    if (isChinese) { //中文输入法下
        UITextRange *selectedRange = [_inputField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [_inputField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            NSLog(@"汉字");
            isInput=NO;
        }
        else
        {
            NSLog(@"输入的英文还没有转化为汉字的状态");
            return;
        }
    }else{
        NSLog(@"str=%@; 本次长度=%lu",_inputField.text,(unsigned long)_inputField.text.length);
    }
    
    _showLabel.text=[NSString stringWithFormat:@"%lu",19-sender.text.length];
    if (sender.text.length>19) {
        _showLabel.text=[NSString stringWithFormat:@"已超出%lu字",sender.text.length-19];
        _inputField.layer.borderColor = [UIColor redColor].CGColor;
        isInput=YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self addTagToLast:textField.text];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if ([_inputField.text isEqualToString:@"\u200B"]) {
        if (_inputField.frame.size.width<SCREEN_WIDTH-_inputField.frame.origin.x-_tagGap) {
            CGRect inputRect = _inputField.frame;
            inputRect.size.width = SCREEN_WIDTH-_inputField.frame.origin.x-_tagGap;
            _inputField.frame = inputRect;
        }
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([_delegate respondsToSelector:@selector(tagWriteViewDidBeginEditing:)])
    {
        [_delegate tagWriteViewDidBeginEditing:self];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([_delegate respondsToSelector:@selector(tagWriteViewDidEndEditing:)])
    {
        [_delegate tagWriteViewDidEndEditing:self];
    }
}

@end
