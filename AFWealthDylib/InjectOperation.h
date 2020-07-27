//
//  InjectOperation.h
//  AFWealthDylib
//
//  Created by darkedgeMBP on 2020/7/25.
//  Copyright © 2020 darkedge. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class DTRpcOperation;

/// 注入请求类
@interface InjectOperation : NSObject

/// 注入修改
/// @param operation operation description
+ (void)injectOperation:(DTRpcOperation *)operation;
@end

NS_ASSUME_NONNULL_END
