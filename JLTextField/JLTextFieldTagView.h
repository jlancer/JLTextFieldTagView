//
//  JLTextFieldTagView.h
//  textFieldTag
//
//  Created by 16fan on 15/4/17.
//  Copyright (c) 2015年 16fan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JLTagWriteViewDelegate;

@interface JLTextFieldTagView : UIView

//
// appearance
//
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *tagBackgroundColor;
@property (nonatomic, strong) UIColor *tagTextgroundColor;
@property (nonatomic, assign) int maxTagLength;
@property (nonatomic, assign) CGFloat tagGap;
@property (nonatomic, assign) BOOL openWordCount;

//
// data
//
@property (nonatomic, readonly) NSArray *tags;

//
// control
//

@property (nonatomic, weak) id<JLTagWriteViewDelegate> delegate;

- (void)clear;
- (void)setTextToInputSlot:(NSString *)text;

- (void)addTags:(NSArray *)tags;
- (void)removeTags:(NSArray *)tags;
- (void)addTagToLast:(NSString *)tag;
- (void)removeTagToLast:(NSString *)tag;

@end

@protocol JLTagWriteViewDelegate <NSObject>

@optional
- (void)tagWriteViewDidBeginEditing:(JLTextFieldTagView *)view;
- (void)tagWriteViewDidEndEditing:(JLTextFieldTagView *)view;
- (void)tagWriteChangeView:(JLTextFieldTagView *)view;

- (void)tagWriteView:(JLTextFieldTagView *)view didMakeTag:(NSString *)tag;
- (void)tagWriteView:(JLTextFieldTagView *)view didRemoveTag:(NSString *)tag;
@end
