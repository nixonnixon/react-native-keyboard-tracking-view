//
//  ObservingInputAccessoryView.h
//  ReactNativeChat
//
//  Created by Artal Druk on 11/04/2016.
//  Copyright © 2016 Wix.com All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, KeyboardState) {
	KeyboardStateHidden,
	KeyboardStateWillShow,
	KeyboardStateShown,
	KeyboardStateWillHide
};

@class ObservingInputAccessoryView;

@protocol ObservingInputAccessoryViewDelegate <NSObject>

- (void)observingInputAccessoryViewDidChangeFrame:(ObservingInputAccessoryView*)observingInputAccessoryView;

@optional

- (void)observingInputAccessoryViewKeyboardWillAppear:(ObservingInputAccessoryView*)observingInputAccessoryView keyboardDelta:(CGFloat)delta;

@end

@interface ObservingInputAccessoryView : UIView

+(ObservingInputAccessoryView*)sharedInstance;

@property (nonatomic) BOOL viewIsInsideTabBar;
@property (nonatomic, weak) id<ObservingInputAccessoryViewDelegate> delegate;
@property (nonatomic) CGFloat height;
@property (nonatomic, readonly) CGFloat keyboardHeight;
@property (nonatomic, readonly) KeyboardState keyboardState;

@end
