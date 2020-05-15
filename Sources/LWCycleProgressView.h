//
//  LWCycleProgressView.h
//  VideoRecord
//
//  Created by yanyu on 2020/5/15.
//  Copyright © 2020 yanyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LWCycleProgressView;
@protocol LWCycleProgressViewDelegate <NSObject>

-(void)progressView:(LWCycleProgressView *)progressView;

@end

@interface LWCycleProgressView : UIView

//进度值0-1.0之间
@property (nonatomic,assign)CGFloat progressValue;
//内部label文字
@property(nonatomic,strong)NSString *contentText;
//value等于1的时候的代理
@property(nonatomic,weak)id<LWCycleProgressViewDelegate>delegate;

@end
