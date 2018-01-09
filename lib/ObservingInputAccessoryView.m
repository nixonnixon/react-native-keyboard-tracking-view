//
//  ObservingInputAccessoryView.m
//  ReactNativeChat
//
//  Created by Artal Druk on 11/04/2016.
//  Copyright © 2016 Wix.com All rights reserved.
//

#import "ObservingInputAccessoryView.h"

NSUInteger const kTabbarHeight = 49;

@implementation ObservingInputAccessoryView
{
    CGFloat _previousKeyboardHeight;
}

+(ObservingInputAccessoryView*)sharedInstance
{
    static ObservingInputAccessoryView *instance = nil;
    static dispatch_once_t observingInputAccessoryViewOnceToken = 0;
    
    dispatch_once(&observingInputAccessoryViewOnceToken,^
    {
        if (instance == nil)
        {
            instance = [ObservingInputAccessoryView new];
        }
    });
    
    return instance;
}

- (instancetype)init
{
	self = [super init];
	
	if(self)
	{
        self.userInteractionEnabled = NO;
        self.translatesAutoresizingMaskIntoConstraints = NO;
		self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		
        [self registerForKeyboardNotifications];
	}
	
	return self;
}

- (void) registerForKeyboardNotifications
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(_keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(_keyboardDidShowNotification:) name:UIKeyboardDidShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(_keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(_keyboardDidHideNotification:) name:UIKeyboardDidHideNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(_keyboardWillChangeFrameNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
	if (self.superview)
	{
		[self.superview removeObserver:self forKeyPath:@"center"];
	}
	
	if (newSuperview != nil)
	{
		[newSuperview addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionNew context:nil];
	}
	
	[super willMoveToSuperview:newSuperview];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ((object == self.superview) && ([keyPath isEqualToString:@"center"]))
	{
        CGFloat centerY = self.superview.center.y;
        
        if([keyPath isEqualToString:@"center"])
        {
            centerY = [change[NSKeyValueChangeNewKey] CGPointValue].y;
        }
        
        CGFloat boundsH = self.superview.bounds.size.height;
        
        _previousKeyboardHeight = _keyboardHeight;
		_keyboardHeight = MAX(0, self.window.bounds.size.height - (centerY - boundsH / 2) - self.intrinsicContentSize.height);
        
        if (self.viewIsInsideTabBar) {
            _keyboardHeight = _keyboardHeight - kTabbarHeight;
        }
		
		[self.delegate observingInputAccessoryViewDidChangeFrame:self];
	}
}

-(void)dealloc
{
	[self.superview removeObserver:self forKeyPath:@"center"];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (CGSize)intrinsicContentSize
{
	return CGSizeMake(self.bounds.size.width, _keyboardState == KeyboardStateWillShow || _keyboardState == KeyboardStateWillHide ? 0 : _height);
}

- (void)setHeight:(CGFloat)height
{
	_height = height;
	
	[self invalidateIntrinsicContentSize];
}

- (void)_keyboardWillShowNotification:(NSNotification*)notification
{
	_keyboardState = KeyboardStateWillShow;
	
	[self invalidateIntrinsicContentSize];
    
    if([self.delegate respondsToSelector:@selector(observingInputAccessoryViewKeyboardWillAppear:keyboardDelta:)])
    {
        [self.delegate observingInputAccessoryViewKeyboardWillAppear:self keyboardDelta:_keyboardHeight - _previousKeyboardHeight];
    }
}

- (void)_keyboardDidShowNotification:(NSNotification*)notification
{
	_keyboardState = KeyboardStateShown;
	
	[self invalidateIntrinsicContentSize];
}

- (void)_keyboardWillHideNotification:(NSNotification*)notification
{
	_keyboardState = KeyboardStateWillHide;
	
	[self invalidateIntrinsicContentSize];
}

- (void)_keyboardDidHideNotification:(NSNotification*)notification
{
	_keyboardState = KeyboardStateHidden;
	
	[self invalidateIntrinsicContentSize];
}

- (void)_keyboardWillChangeFrameNotification:(NSNotification*)notification
{
    if(self.window)
    {
        return;
    }
    
    CGRect endFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyboardHeight = [UIScreen mainScreen].bounds.size.height - endFrame.origin.y;
    
    [self.delegate observingInputAccessoryViewDidChangeFrame:self];
	
	[self invalidateIntrinsicContentSize];
}

@end
