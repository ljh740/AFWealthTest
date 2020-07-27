//
//  InjectOperation.m
//  AFWealthDylib
//
//  Created by darkedgeMBP on 2020/7/25.
//  Copyright © 2020 darkedge. All rights reserved.
//

#import "InjectOperation.h"
#import "DTRpcOperation.h"
#import "MBProgressHUD.h"
#import <UIKit/UIKit.h>

@implementation InjectOperation
static NSMutableDictionary *holdingMap;

+ (void)injectOperation:(DTRpcOperation *)operation {
    @try {
        NSDictionary *allHTTPHeaderFields = operation.request.allHTTPHeaderFields;
        NSString *oType = allHTTPHeaderFields[@"Operation-Type"];

        NSString *selStr = self.handleTypeMap[oType];
        if (selStr.length) {
            SEL sel = NSSelectorFromString(selStr);
            if ([self respondsToSelector:sel]) {
                [self performSelector:sel withObject:operation];
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"some error:%@", exception);
    }

//        operation.responseData = NSData.new;
//        BLockWithObject oldBlock = operation.responseBlock;
//        NSLog(@"%s:%@",__func__,oType);
//        operation.responseBlock = nil;
//        operation.responseBlock = ^(NSObject *object) {
//            NSLog(@"result :%@,%@",object.class,object);
//            oldBlock(object);
//        };
}

#pragma mark - holdingMap
+ (NSString *)holdingMapPath {
    static NSString *path;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        path = [documentsDirectory stringByAppendingPathComponent:@"hm.plist"];
    });
    return path;
}

+ (void)loadHoldingMap {
    NSMutableDictionary *map = [NSMutableDictionary dictionaryWithContentsOfFile:self.holdingMapPath];
    if (!map) {
        map = NSMutableDictionary.dictionary;
    }
    holdingMap = map;
}

+ (void)saveHoldingMap {
    if (!holdingMap) {
        [self loadHoldingMap];
    }

    [holdingMap writeToFile:self.holdingMapPath atomically:YES];
}

/// 获取份额
/// @param fundCode 基金代码
+ (NSString *)getHoldQuantityWithFundCode:(NSString *)fundCode {
    if (holdingMap == nil) {
        [self loadHoldingMap];
    }
    return holdingMap[fundCode];
}

+ (void)setHoldQuantityWithFundCode:(NSString *)fundCode quantity:(NSString *)quantity {
    if (holdingMap == nil) {
        [self loadHoldingMap];
    }
    holdingMap[fundCode] = quantity;
    [self saveHoldingMap];
}

#pragma mark - handle
+ (void)handleQueryV3:(DTRpcOperation *)operation {
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
    if (json && [json isKindOfClass:NSDictionary.class]) {
        // 解析数据
        NSMutableDictionary *m_json = [json mutableCopy];
        NSMutableDictionary *result = [m_json[@"result"] mutableCopy];
        NSArray *optionalList = result[@"optionalList"];
        NSMutableArray *modifyList = NSMutableArray.array;
        NSMutableArray *incomes = NSMutableArray.array;

        for (NSDictionary *obj in optionalList) {
            NSMutableDictionary *model = [obj mutableCopy];
            BOOL holdingPosition = [model[@"holdingPosition"] boolValue];
            if (holdingPosition) {
                // 获取份额
                NSString *value = [self getHoldQuantityWithFundCode:model[@"fundCode"]];

                // 获取时间
                NSString *netValueReportDate = model[@"netValueReportDate"];
                NSString *estimateDate = model[@"estimateDate"];

                // 有效份额 才参与统计
                if (value.doubleValue > 0) {
                    NSMutableArray *contentTags = NSMutableArray.array;

                    // 预估时间不等于网络净值时间时 统计收益
                    if ([netValueReportDate isKindOfClass:NSString.class] &&
                        [estimateDate isKindOfClass:NSString.class] &&
                        ![netValueReportDate isEqualToString:estimateDate]) {
                        NSString *netValue = model[@"netValue"];
                        NSString *estimateNetValue = model[@"estimateNetValue"];
                        // 没有预估时 忽略收益
                        if (estimateNetValue.doubleValue && netValue.doubleValue) {
                            double income = (estimateNetValue.doubleValue - netValue.doubleValue) * value.doubleValue;
                            [incomes addObject:@(income)];
                            [contentTags addObject:@{
                                 @"visible": @YES,
                                 @"text": [NSString stringWithFormat:@"收益:%0.2f", income],
                                 @"type": @"BULL_FUND",
                            }];
                        }
                    } else {
                        [contentTags addObject:@{
                             @"visible": @YES,
                             @"text": [NSString stringWithFormat:@"份额:%@", value],
                             @"type": @"BULL_FUND",
                        }];
                    }
                    model[@"contentTags"] = contentTags;
                } else {
                    model[@"contentTags"] = @[
                        @{
                            @"visible": @YES,
                            @"text": @"点击读取份额",
                            @"type": @"BULL_FUND",
                        },
                    ];
                }
            }
            [modifyList addObject:model];
        }

        result[@"optionalList"] = modifyList;
        m_json[@"result"] = result;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:m_json options:NSJSONWritingPrettyPrinted error:nil];
        operation.responseData = jsonData;

        if (incomes.count) {
            NSDecimalNumber *sum = [incomes valueForKeyPath:@"@sum.doubleValue"];
            NSString *desc = [NSString stringWithFormat:@"有效统计%ld只,收益%0.2f", incomes.count, sum.doubleValue];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                UILabel *label = UILabel.new;
                UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
                label.frame = CGRectMake(20, CGRectGetMaxY(keyWindow.frame) - 118, CGRectGetMaxX(keyWindow.frame) - 40, 30);
                label.layer.cornerRadius = 7.f;
                label.layer.masksToBounds = YES;
//                label.backgroundColor = [UIColor colorWithRed:252/255.f green:173/255.f blue:122/255.f alpha:1.f];
                label.backgroundColor = [UIColor colorWithRed:0x99/255.f green:0xbb/255.f blue:0xff/255.f alpha:1.f];
                label.text = desc;
                label.textAlignment = NSTextAlignmentCenter;
                label.textColor = UIColor.whiteColor;
                [keyWindow addSubview:label];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [label removeFromSuperview];
                });
            });
        }
    }
}

+ (void)handleQueryAssetDetail:(DTRpcOperation *)operation {
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
    if (json && [json isKindOfClass:NSDictionary.class]) {
        // 解析数据
        NSMutableDictionary *result = json[@"result"];
        NSString *availableShare = result[@"availableShare"];
        if (availableShare.doubleValue > 0) {
            NSString *fundCode = result[@"fundCode"];
            [self setHoldQuantityWithFundCode:fundCode quantity:availableShare];
        }
    }
}

#pragma mark - map
+ (NSDictionary *)handleTypeMap {
    static NSDictionary *handleMap;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handleMap = @{
            @"com.alipay.wealthbffweb.fund.optional.queryV3": @"handleQueryV3:",
            @"com.alipay.wealthbffweb.fund.commonAsset.queryAssetDetail": @"handleQueryAssetDetail:",
        };
    });
    return handleMap;
}

@end
