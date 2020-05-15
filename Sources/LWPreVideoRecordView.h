//
//  LWPreVideoRecordView.h
//  VideoRecord
//
//  Created by yanyu on 2020/5/15.
//  Copyright © 2020 yanyu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LWPreVideoRecordView : UIView
@property (nonatomic, strong) NSURL *playUrl;
@property (nonatomic, strong) void (^clickAction)(void);
@end

NS_ASSUME_NONNULL_END
