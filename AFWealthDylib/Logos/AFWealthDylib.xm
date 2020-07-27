// See http://iphonedevwiki.net/index.php/Logos

#import <UIKit/UIKit.h>
#import "InjectOperation.h"

%hook DTRpcOperation
//- (id)initWithURL:(id)arg1 method:(id)arg2 params:(id)arg3 headerFields:(id)arg4 amrpc:(_Bool)arg5 cdn:(_Bool)arg6 {
//    %log;
//    return %orig;
//}
//- (id)requestWithURL:(id)arg1 method:(id)arg2 params:(id)arg3 amrpc:(BOOL)arg4 cdn:(BOOL)arg5 {
//    %log;
//    return %orig;
//}

- (void)finish {
    %log;
    [InjectOperation injectOperation:self];
    return %orig;
}

%end

