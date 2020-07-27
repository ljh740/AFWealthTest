#line 1 "/Users/darkedge/Desktop/es/AFWealth/AFWealth/AFWealthDylib/Logos/AFWealthDylib.xm"


#import <UIKit/UIKit.h>
#import "InjectOperation.h"


#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class DTRpcOperation; 
static void (*_logos_orig$_ungrouped$DTRpcOperation$finish)(_LOGOS_SELF_TYPE_NORMAL DTRpcOperation* _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$DTRpcOperation$finish(_LOGOS_SELF_TYPE_NORMAL DTRpcOperation* _LOGOS_SELF_CONST, SEL); 

#line 6 "/Users/darkedge/Desktop/es/AFWealth/AFWealth/AFWealthDylib/Logos/AFWealthDylib.xm"










static void _logos_method$_ungrouped$DTRpcOperation$finish(_LOGOS_SELF_TYPE_NORMAL DTRpcOperation* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    HBLogDebug(@"-[<DTRpcOperation: %p> finish]", self);
    [InjectOperation injectOperation:self];
    return _logos_orig$_ungrouped$DTRpcOperation$finish(self, _cmd);
}



static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$DTRpcOperation = objc_getClass("DTRpcOperation"); MSHookMessageEx(_logos_class$_ungrouped$DTRpcOperation, @selector(finish), (IMP)&_logos_method$_ungrouped$DTRpcOperation$finish, (IMP*)&_logos_orig$_ungrouped$DTRpcOperation$finish);} }
#line 24 "/Users/darkedge/Desktop/es/AFWealth/AFWealth/AFWealthDylib/Logos/AFWealthDylib.xm"
