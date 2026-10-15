#import <UIKit/UIKit.h>
#include <string.h>
#include <math.h>

// WxHideBar - hide WeChat keyboard toolbar buttons (WeType logo + rightmost tool icon)
// No %hook of private classes: pure geometric + color heuristics via keyboard notifications.

static BOOL WHBIsGreenish(UIView *view) {
    if (![view isKindOfClass:[UIButton class]]) return NO;
    UIButton *btn = (UIButton *)view;
    UIImage *img = btn.currentImage ?: btn.imageView.image;
    if (!img) return NO;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), NO, 1.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (!ctx) {
        UIGraphicsEndImageContext();
        return NO;
    }
    [img drawInRect:CGRectMake(0, 0, 1, 1)];
    unsigned char px[4] = {0, 0, 0, 0};
    void *data = CGBitmapContextGetData(ctx);
    if (data) memcpy(px, data, 4);
    UIGraphicsEndImageContext();
    // iOS default bitmap is BGRA byte order
    int b = px[0], g = px[1], r = px[2];
    if (g < 80) return NO;
    if (g <= (int)(r * 1.2)) return NO;
    if (g <= (int)(b * 1.2)) return NO;
    return YES;
}

static void WHBScanView(UIView *view, NSInteger depth) {
    if (depth > 9 || view.hidden || view.alpha < 0.05) return;

    // Rule 1: green logo button at far-left of keyboard area
    if ([view isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)view;
        CGRect f = btn.frame;
        UIWindow *w = btn.window;
        if (w && !btn.hidden && btn.alpha > 0.1) {
            CGRect sf = [w convertRect:[btn convertRect:btn.bounds toView:nil] fromView:nil];
            CGFloat winH = w.bounds.size.height;
            BOOL bottomArea = (sf.origin.y + sf.size.height * 0.5) > winH * 0.55;
            if (bottomArea && f.size.width <= 64.0 && f.size.height <= 64.0 && f.origin.x <= 16.0) {
                if (WHBIsGreenish(btn)) {
                    btn.alpha = 0.0;
                    btn.userInteractionEnabled = NO;
                    NSLog(@"[WxHideBar] hid green logo button at %@",
                          NSStringFromCGRect([btn convertRect:btn.bounds toView:nil]));
                    return;
                }
            }
        }
    }

    // Rule 2: toolbar row of >=6 aligned buttons -> hide the last one
    NSArray *sub = view.subviews;
    if (sub.count >= 6 && view.bounds.size.width > 200.0) {
        BOOL allBtn = YES;
        CGFloat y0 = 0.0;
        BOOL first = YES;
        for (UIView *s in sub) {
            if (![s isKindOfClass:[UIButton class]] || s.hidden || s.alpha < 0.1 ||
                s.frame.size.width < 20.0 || s.frame.size.height < 20.0) {
                allBtn = NO;
                break;
            }
            if (first) {
                y0 = s.frame.origin.y;
                first = NO;
            } else if (fabs(s.frame.origin.y - y0) > 6.0) {
                allBtn = NO;
                break;
            }
        }
        if (allBtn) {
            UIView *last = sub.lastObject;
            if (!last.hidden) {
                last.alpha = 0.0;
                last.userInteractionEnabled = NO;
                NSLog(@"[WxHideBar] hid last toolbar button in row of %lu", (unsigned long)sub.count);
            }
        }
    }

    for (UIView *s in sub) WHBScanView(s, depth + 1);
}

static void WHBScanNow(void) {
    for (UIWindow *w in [UIApplication sharedApplication].windows) {
        WHBScanView(w, 0);
    }
}

static void WHBSchedule(NSTimeInterval delay) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        WHBScanNow();
    });
}

static void WHBInstallObservers(void) {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    for (NSString *name in @[UIKeyboardWillShowNotification,
                             UIKeyboardDidShowNotification,
                             UIKeyboardDidChangeFrameNotification]) {
        [nc addObserverForName:name object:nil queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *note) {
            WHBSchedule(0.4);
            WHBSchedule(1.2);
        }];
    }
    NSLog(@"[WxHideBar] loaded");
}

%ctor {
    WHBInstallObservers();
}

