//
//  LWVideoRecordViewController.m
//  VideoRecord
//
//  Created by luowei on 2020/5/14.
//  Copyright © 2020 luowei. All rights reserved.
//

#import "LWVideoRecordViewController.h"
#import <Masonry/Masonry.h>
#import "LWVideoRecordManager.h"
#import "LWCycleProgressView.h"
#import "LWPreVideoRecordView.h"
#import <MobileCoreServices/MobileCoreServices.h>

typedef NS_OPTIONS(NSUInteger, LWRecordStateType) {
    LWRecordStateTypeUnStart = 1 << 0,      //未开始
    LWRecordStateTypeStarting = 1 << 1,     //已开始
    LWRecordStateTypePause = 1 << 2,        //暂停
};

typedef NS_OPTIONS(NSUInteger, LWRecordSourceType) {
    LWRecordSourceTypeCamera = 1 << 0,            //拍摄
    LWRecordSourceTypePhoto = 1 << 1,            //相册
};

@interface LWVideoRecordViewController ()<LWVideoRecordManagerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic, strong) UIButton                  *btnClose;
@property (nonatomic, strong) UIButton                  *btnCamera;
@property (nonatomic, strong) UIView                    *vCycle;
@property (nonatomic, strong) UIButton                  *btnRecord;
@property (strong, nonatomic) LWVideoRecordManager      *recordEngine;
@property (nonatomic, strong) LWCycleProgressView       *progressView;
@property (nonatomic, assign) LWRecordStateType          state;
@property (nonatomic, strong) UILabel                   *lbTips;

//录制完成按钮
@property (nonatomic, strong) UIButton                  *btnCancel;
@property (nonatomic, strong) UIButton                  *btnOK;
@property (nonatomic, strong) LWPreVideoRecordView      *vPlayer;
@property (nonatomic, strong) UIImage                   *image;
@property (nonatomic, strong) UIButton                  *btnLocal;
@property (nonatomic, strong) UIImagePickerController   *moviePicker;
@property (nonatomic, assign) LWRecordSourceType         sourceType;
@property (nonatomic, strong) NSString                  *locUrl;
@end

@implementation LWVideoRecordViewController


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_recordEngine == nil) {
        [self.recordEngine previewLayer].frame = self.view.bounds;
        [self.view.layer insertSublayer:[self.recordEngine previewLayer] atIndex:0];
    }
    self.lbTips.hidden = TRUE;
    [self.recordEngine startUp];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.lbTips.hidden = FALSE;
    [self.recordEngine shutdown];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.lbTips];
    [self.view addSubview:self.btnClose];
    [self.view addSubview:self.btnCamera];
    [self.view addSubview:self.btnCancel];
    [self.view addSubview:self.btnOK];
    [self.view addSubview:self.progressView];
    [self.view addSubview:self.vCycle];
    [self.vCycle addSubview:self.btnRecord];
    [self.view addSubview:self.btnLocal];
    [self.view addSubview:self.vPlayer];
    
    self.state = LWRecordStateTypeUnStart;
    self.sourceType = LWRecordSourceTypeCamera;
    
    [self.lbTips mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    
    [self.btnClose mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(23);
        make.top.mas_equalTo(50);
        make.left.mas_equalTo(20);
    }];
    
    [self.btnCamera mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(23);
        make.top.mas_equalTo(50);
        make.right.equalTo(self.view).offset(-20);
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(90);
        make.centerX.equalTo(self.view);
        make.bottom.mas_equalTo(-100);
    }];
    
    [self.vCycle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(90);
        make.centerX.equalTo(self.view);
        make.bottom.mas_equalTo(-100);
    }];
    
    [self.btnRecord mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(75);
        make.center.equalTo(self.vCycle);
    }];
    
    
    [self.btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(60);
        make.centerY.equalTo(self.vCycle);
        make.right.equalTo(self.progressView.mas_left).offset(-50);
    }];
    
    
    [self.btnOK mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(60);
        make.centerY.equalTo(self.vCycle);
        make.left.equalTo(self.progressView.mas_right).offset(50);
    }];
    
    [self.vPlayer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(0);
        make.height.mas_offset([UIScreen mainScreen].bounds.size.height);
    }];
    
    [self.btnLocal mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.vCycle.mas_bottom).offset(15);
    }];
}

- (void)clickAction:(UIButton*)sender{
    //切换前后相机
    if (sender.tag == 100) {
        sender.selected = !sender.selected;
        [self.recordEngine changeCameraInputDeviceisFront:sender.selected];
    }
    //拍摄
    else if(sender.tag == 101){
        self.sourceType = LWRecordSourceTypeCamera;
        if (self.state == LWRecordStateTypeUnStart) {
            self.state = LWRecordStateTypeStarting;
            [self.recordEngine startCapture];
            [self toggleFinished:TRUE];
        }else if(self.state == LWRecordStateTypeStarting){
            self.state = LWRecordStateTypePause;
            [self.recordEngine pauseCapture];
            [self toggleFinished:FALSE];
        }else if(self.state == LWRecordStateTypePause){
            self.state = LWRecordStateTypeStarting;
            [self.recordEngine resumeCapture];
            [self toggleFinished:TRUE];
        }
    }
    //取消重拍
    else if(sender.tag == 102){
        self.state = LWRecordStateTypeUnStart;
        [self.recordEngine cancelCapture];
        [self.recordEngine startUp];
        [self toggleFinished:TRUE];
    }
    //拍摄完成
    else if(sender.tag == 103){
        self.state = LWRecordStateTypeUnStart;
        [self.recordEngine stopCaptureHandler:^(UIImage *movieImage) {
            self.image = movieImage;
            [self.recordEngine cancelCapture];
            [self.recordEngine startUp];
            [self toggleFinished:TRUE];
            NSURL* url = [NSURL fileURLWithPath:self.recordEngine.videoPath];
            [self playVideo:url];
        }];
    }
    //关闭
    else if(sender.tag == 104){
        [self dismissViewControllerAnimated:TRUE completion:^{
            
        }];
    }
    //本地视频
    else if(sender.tag == 105){
        self.sourceType = LWRecordSourceTypePhoto;
        [self.recordEngine shutdown];
        [self presentViewController:self.moviePicker animated:YES completion:nil];
    }
}


/// 播放录完成播放
/// @param url 播放地址
- (void)playVideo:(NSURL*)url{
    self.vPlayer.hidden = FALSE;
    self.vPlayer.playUrl = url;
}

- (void)toggleFinished:(BOOL)show{
    self.btnCancel.hidden = show;
    self.btnOK.hidden = show;
}

#pragma mark LWVideoRecordManagerDelegate
- (void)recordProgress:(CGFloat)progress{
    self.progressView.progressValue = progress;
    if (progress >= 1) {
        [self toggleFinished:FALSE];
    }
}

#pragma mark - UIImagePickerControllerDelegate
//选择了某个照片的回调函数/代理回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeMovie]) {
        //获取视频的名称
        NSString * videoPath=[NSString stringWithFormat:@"%@",[info objectForKey:UIImagePickerControllerMediaURL]];
        NSRange range =[videoPath rangeOfString:@"trim."];//匹配得到的下标
        NSString *content=[videoPath substringFromIndex:range.location+5];
        //视频的后缀
        NSRange rangeSuffix=[content rangeOfString:@"."];
        NSString * suffixName=[content substringFromIndex:rangeSuffix.location+1];
        //如果视频是mov格式的则转为MP4的
        if ([suffixName isEqualToString:@"MOV"]) {
            NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
            __weak typeof(self) weakSelf = self;
            [self.recordEngine changeMovToMp4:videoUrl dataBlock:^(UIImage *movieImage) {
                weakSelf.image = movieImage;
                weakSelf.locUrl = weakSelf.recordEngine.videoPath;
                [weakSelf.moviePicker dismissViewControllerAnimated:YES completion:^{
                    [weakSelf playVideo:[NSURL fileURLWithPath:weakSelf.recordEngine.videoPath]];
                }];
            }];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    self.state = LWRecordStateTypeUnStart;
    [self.recordEngine cancelCapture];
    [self.recordEngine startUp];
    [self toggleFinished:TRUE];
    self.sourceType = LWRecordSourceTypeCamera;
    
    [picker dismissViewControllerAnimated:TRUE completion:^{
        
    }];
}

#pragma mark - set、get方法

- (UILabel*)lbTips{
    if(!_lbTips){
        _lbTips = [[UILabel alloc]init];
        _lbTips.text = @"相机启动中...";
        _lbTips.textColor = [UIColor whiteColor];
        _lbTips.font = [UIFont systemFontOfSize:14];
    }
    return _lbTips;
}

- (UIButton*)btnClose{
    if(!_btnClose){
        _btnClose = [[UIButton alloc]initWithFrame:CGRectZero];
        [_btnClose setImage:[UIImage imageNamed:@"LWVideoRecord.bundle/record_video_close"] forState:UIControlStateNormal];
        [_btnClose setImage:[UIImage imageNamed:@"LWVideoRecord.bundle/record_video_close"] forState:UIControlStateHighlighted];
        [_btnClose setImage:[UIImage imageNamed:@"LWVideoRecord.bundle/record_video_close"] forState:UIControlStateSelected];
        [_btnClose addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
        _btnClose.tag = 104;
        
    }
    return _btnClose;
}

- (UIButton*)btnCamera{
    if(!_btnCamera){
        _btnCamera = [[UIButton alloc]initWithFrame:CGRectZero];
        [_btnCamera setImage:[UIImage imageNamed:@"LWVideoRecord.bundle/record_video_camera"] forState:UIControlStateNormal];
        [_btnCamera setImage:[UIImage imageNamed:@"LWVideoRecord.bundle/record_video_camera"] forState:UIControlStateHighlighted];
        [_btnCamera setImage:[UIImage imageNamed:@"LWVideoRecord.bundle/record_video_camera"] forState:UIControlStateSelected];
        [_btnCamera addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
        _btnCamera.tag = 100;
        
    }
    return _btnCamera;
}

- (UIView*)vCycle{
    if(!_vCycle){
        _vCycle = [[UIView alloc]init];
    }
    return _vCycle;
}

- (UIButton*)btnRecord{
    if(!_btnRecord){
        _btnRecord = [[UIButton alloc]initWithFrame:CGRectZero];
        _btnRecord.tag = 101;
        _btnRecord.backgroundColor = [UIColor redColor];
        [_btnRecord addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
        _btnRecord.layer.cornerRadius = 75*0.5;
        
    }
    return _btnRecord;
}

- (LWVideoRecordManager *)recordEngine {
    if (_recordEngine == nil) {
        _recordEngine = [[LWVideoRecordManager alloc] init];
        _recordEngine.delegate = self;
        _recordEngine.maxRecordTime = self.maxRecordTime == 0?10.0:self.maxRecordTime;
    }
    return _recordEngine;
}


- (LWCycleProgressView*)progressView{
    if(!_progressView){
        _progressView = [[LWCycleProgressView alloc]init];
    }
    return _progressView;
}


- (UIButton*)btnCancel{
    if(!_btnCancel){
        _btnCancel = [[UIButton alloc]initWithFrame:CGRectZero];
        [_btnCancel setImage:[UIImage imageNamed:@"LWVideoRecord.bundle/record_video_cancel"] forState:UIControlStateNormal];
        [_btnCancel setImage:[UIImage imageNamed:@"LWVideoRecord.bundle/record_video_cancel"] forState:UIControlStateHighlighted];
        [_btnCancel setImage:[UIImage imageNamed:@"LWVideoRecord.bundle/record_video_cancel"] forState:UIControlStateSelected];
        [_btnCancel addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
        _btnCancel.tag = 102;
        _btnCancel.hidden = TRUE;
        
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
        _btnOK.tag = 103;
        _btnOK.hidden = TRUE;
    }
    return _btnOK;
}

- (LWPreVideoRecordView*)vPlayer{
    if(!_vPlayer){
        _vPlayer = [[LWPreVideoRecordView alloc]init];
        _vPlayer.hidden = TRUE;
        __weak typeof(self) weakSelf = self;
        _vPlayer.clickAction = ^{
            if (weakSelf.recordFinished) {
                if (weakSelf.sourceType == LWRecordSourceTypeCamera) {
                    weakSelf.recordFinished(weakSelf.recordEngine.videoPath,weakSelf.image);
                }else{
                    weakSelf.recordFinished(weakSelf.locUrl,weakSelf.image);
                }
            }
            [weakSelf dismissViewControllerAnimated:TRUE completion:^{
                
            }];
        };
    }
    return _vPlayer;
}

#pragma mark - 本地视频选择

- (UIImagePickerController *)moviePicker {
    if (_moviePicker == nil) {
        _moviePicker = [[UIImagePickerController alloc] init];
        _moviePicker.delegate = self;
        _moviePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _moviePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
        _moviePicker.allowsEditing = YES;
        _moviePicker.videoMaximumDuration = self.maxRecordTime == 0?10.0:self.maxRecordTime;
    }
    return _moviePicker;
}

- (UIButton*)btnLocal{
    if(!_btnLocal){
        _btnLocal = [[UIButton alloc]initWithFrame:CGRectZero];
        [_btnLocal setTitle:@"本地视频" forState:UIControlStateNormal];
        [_btnLocal setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnLocal addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
        _btnLocal.titleLabel.font = [UIFont systemFontOfSize:14];
        _btnLocal.tag = 105;
    }
    return _btnLocal;
}


@end
