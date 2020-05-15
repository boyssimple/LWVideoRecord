//
//  LWVideoRecordViewController.h
//  VideoRecord
//
//  Created by yanyu on 2020/5/15.
//  Copyright © 2020 yanyu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LWVideoRecordViewController : UIViewController
@property (atomic, assign) CGFloat maxRecordTime;                                   //录制最长时间
@property (nonatomic, strong) void (^recordFinished)(NSString *url,UIImage *image); //完成回调
@end

NS_ASSUME_NONNULL_END
