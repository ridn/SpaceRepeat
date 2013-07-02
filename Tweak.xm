#import <UIKit/UIKit.h>

@interface UIKeyboardLayoutStar
-(id)keyHitTest:(CGPoint)test;
-(void)addInputString:(NSString*)string;
@end
@interface UIKeyBoardImpl
+(id)sharedInstance;
@end

NSString* key;
static BOOL isSpaceKey = NO;
NSTimer* timerForSpace;

%hook UIKeyboardLayoutStar
- (void)longPressAction
{
	if(isSpaceKey && ![timerForSpace isValid])timerForSpace = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(spaceBarLongPress) userInfo:nil repeats:YES];
	%orig;
}
%new
- (void)spaceBarLongPress
{
	[[%c(UIKeyboardImpl) sharedInstance] addInputString:@" "];              
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	key = [[[self keyHitTest:[touch locationInView:touch.view]] name] lowercaseString];
	if ([key isEqualToString:@"space-key"]) {
		isSpaceKey = YES;
	}
	else {
		isSpaceKey = NO;
	}
	%orig;
}
-(void)touchesEnded:(NSSet*)touches  withEvent:(UIEvent*)event {

        if (timerForSpace != nil)
            [timerForSpace invalidate];
        timerForSpace = nil;
    		isSpaceKey = NO;
	%orig;
}

-(void)touchesMoved:(NSSet*)touches  withEvent:(UIEvent*)event {
    UITouch *touch = [touches anyObject];
	key = [[[self keyHitTest:[touch locationInView:touch.view]] name] lowercaseString];

	if ([key isEqualToString:@"space-key"]) {
    	isSpaceKey = YES;

    }else{
    	if (timerForSpace != nil) {
        	[timerForSpace invalidate];
            timerForSpace = nil;
        }
    	isSpaceKey = NO;
	}
    %orig;
}
-(void)touchesCanceled:(NSSet*)touches  withEvent:(UIEvent*)event {

        if (timerForSpace != nil)
            [timerForSpace invalidate];
        timerForSpace = nil;
    		isSpaceKey = NO;
    		
        %orig;
}
%end
