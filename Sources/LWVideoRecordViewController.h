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
@property (nonatomic, strong) void (^recordFinished)(NSString *url,UIImage *image);
@end

NS_ASSUME_NONNULL_END
