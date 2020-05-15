
//
//  LWPreVideoRecordView.m
//  VideoRecord
//
//  Created by yanyu on 2020/5/14.
//  Copyright © 2020 yanyu. All rights reserved.
//

#import "LWPreVideoRecordView.h"
#import <AVFoundation/AVFoundation.h>
#import <Masonry/Masonry.h>

@interface LWPreVideoRecordView()
@property (nonatomic, strong) CALayer                   *playerLayer;
@property (nonatomic, strong) AVPlayer                  *player;
@property (nonatomic, strong) UIView                    *vCycle;
@property (nonatomic, strong) UIButton                  *btnCancel;
@property (nonatomic, strong) UIButton                  *btnOK;
@end
@implementation LWPreVideoRecordView

- (instancetype)init{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self addSubview:self.vCycle];
        [self addSubview:self.btnCancel];
        [self addSubview:self.btnOK];

        
        [self.vCycle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(90);
            make.centerX.equalTo(self);
            make.bottom.mas_equalTo(-100);
        }];
        
        [self.btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(60);
            make.centerY.equalTo(self.vCycle);
            make.right.equalTo(self.vCycle.mas_left).offset(-50);
        }];
        
        
        [self.btnOK mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(60);
            make.centerY.equalTo(self.vCycle);
            make.left.equalTo(self.vCycle.mas_right).offset(50);
        }];
    }
    return self;
}

- (void)clickAction:(UIButton*)sender{
    [self.player pause];
    if (sender.tag == 100) {
        self.hidden = TRUE;
    }else{
        if (self.clickAction) {
            self.clickAction();
        }
    }
}

- (void)setPlayUrl:(NSURL *)playUrl{
    _playUrl = playUrl;
    if (!self.player) {
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:self.playUrl];
        _player = [AVPlayer playerWithPlayerItem:playerItem];
        [self addObserverToPlayerItem:playerItem];
    }
    [self.layer insertSublayer:self.playerLayer atIndex:0];
//    if (!_confirmButton) {
//        [self playerButtons];
//    }
//    [self showPlayerButtons];
    [self.player play];
}

- (void)playbackFinished:(NSNotification *)notification{
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
}

- (void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
}

- (CALayer *)playerLayer{
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.frame = self.bounds;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    return playerLayer;
}


- (UIView*)vCycle{
    if(!_vCycle){
        _vCycle = [[UIView alloc]init];
    }
    return _vCycle;
}

- (UIButton*)btnCancel{
    if(!_btnCancel){
        _btnCancel = [[UIButton alloc]initWithFrame:CGRectZero];
        [_btnCancel setImage:[UIImage imageNamed:@"LWVideoRecord.bundle/record_video_cancel"] forState:UIControlStateNormal];
        [_btnCancel setImage:[UIImage imageNamed:@"LWVideoRecord.bundle/record_video_cancel"] forState:UIControlStateHighlighted];
        [_btnCancel setImage:[UIImage imageNamed:@"LWVideoRecord.bundle/record_video_cancel"] forState:UIControlStateSelected];
        [_btnCancel addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
        _btnCancel.tag = 100;
        
    }
    return _btnCancel;
}

- (UIButton*)btnOK{
    if(!_btnOK){
        _btnOK = [[UIButton alloc]initWithFrame:CGRectZero];
        [_btnOK setImage:[UIImage imageNamed:@"LWVideoRecord.bundle/record_video_confirm"] forState:UIControlStateNormal];
        [_btnOK setImage:[UIImage imageNamed:@"LWVideoRecord.bundle/record_video_confirm"] forState:UIControlStateHighlighted];
        [_btnOK setImage:[UIImage imageNamed:@"LWVideoRecord.bundle/record_video_confirm"] forState:UIControlStateSelected];
        [_btnOK addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
        _btnOK.tag = 101;
    }
    return _btnOK;
}


- (void)dealloc{
    [self.player pause];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
