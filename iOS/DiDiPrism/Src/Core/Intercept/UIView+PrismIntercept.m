//
//  UIView+PrismIntercept.m
//  DiDiPrism
//
//  Created by hulk on 2019/7/2.
//

#import "UIView+PrismIntercept.h"
// Dispatcher
#import "PrismEventDispatcher.h"
// Util
#import "PrismRuntimeUtil.h"

@implementation UIView (PrismIntercept)
#pragma mark - public method
+ (void)prism_swizzleMethodIMP {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [PrismRuntimeUtil hookClass:[self class] originalSelector:@selector(touchesEnded:withEvent:) swizzledSelector:@selector(prism_autoDot_touchesEnded:withEvent:)];
        [PrismRuntimeUtil hookClass:[self class] originalSelector:@selector(didMoveToSuperview) swizzledSelector:@selector(prism_autoDot_didMoveToSuperview)];
        [PrismRuntimeUtil hookClass:[self class] originalSelector:@selector(didMoveToWindow) swizzledSelector:@selector(prism_autoDot_didMoveToWindow)];
        [PrismRuntimeUtil hookClass:[self class] originalSelector:@selector(setFrame:) swizzledSelector:@selector(prism_autoDot_setFrame:)];
        [PrismRuntimeUtil hookClass:[self class] originalSelector:@selector(setHidden:) swizzledSelector:@selector(prism_autoDot_setHidden:)];
    });
}

#pragma mark - private method
// 考虑到可能的手势影响，选择hook touchesEnded:withEvent:更合理。
- (void)prism_autoDot_touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    UITouch *touch = [touches anyObject];
    if (touch) {
        [params setObject:touch forKey:@"touch"];
    }
    [[PrismEventDispatcher sharedInstance] dispatchEvent:PrismDispatchEventUIViewTouchesEnded_Start withSender:self params:[params copy]];
    
    //原始逻辑
    Method original_TouchesEnded = class_getInstanceMethod([UIView class], @selector(prism_autoDot_touchesEnded:withEvent:));
    IMP original_TouchesEnded_Method_Imp =  method_getImplementation(original_TouchesEnded);
    void (*functionPointer)(id, SEL, NSSet<UITouch *> *, UIEvent *) = (void (*)(id, SEL, NSSet<UITouch *> *, UIEvent *))original_TouchesEnded_Method_Imp;
    functionPointer(self, _cmd, touches, event);
    
    
    [[PrismEventDispatcher sharedInstance] dispatchEvent:PrismDispatchEventUIViewTouchesEnded_End withSender:self params:[params copy]];
}

- (void)prism_autoDot_didMoveToSuperview {
    [self prism_autoDot_didMoveToSuperview];
    
    [[PrismEventDispatcher sharedInstance] dispatchEvent:PrismDispatchEventUIViewDidMoveToSuperview withSender:self params:nil];
}

- (void)prism_autoDot_didMoveToWindow {
    [self prism_autoDot_didMoveToWindow];
    
    [[PrismEventDispatcher sharedInstance] dispatchEvent:PrismDispatchEventUIViewDidMoveToWindow withSender:self params:nil];
}

- (void)prism_autoDot_setFrame:(CGRect)frame {
    [self prism_autoDot_setFrame:frame];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"frame"] = [NSValue valueWithCGRect:frame];
    [[PrismEventDispatcher sharedInstance] dispatchEvent:PrismDispatchEventUIViewSetFrame withSender:self params:[params copy]];
}

- (void)prism_autoDot_setHidden:(BOOL)hidden {
    [self prism_autoDot_setHidden:hidden];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"hidden"] = [NSNumber numberWithBool:hidden];
    [[PrismEventDispatcher sharedInstance] dispatchEvent:PrismDispatchEventUIViewSetHidden withSender:self params:[params copy]];
}
@end
