//
//  SouFangNormalViewModel.m
//  SouFun
//
//  Created by fcs on 2019/8/6.
//  Copyright © 2019 房天下 Fang.com. All rights reserved.
//

#import "SouFangNormalViewModel.h"
#import "FangLocationManager.h"
//#import "FangChatHelper.h"
#import "MBProgressHUD.h"
//#import "FangHelper.h"
#import "FangImageUploadModel.h"
#import "UIImage+FangImage.h"
#import "SouFunUploadImageAPI.h"
#import "FangGroupRequest.h"
#import "TZImagePickerController.h"
#import "PHAsset+FangAsset.h"
#import "SouFunShareService.h"
//#import "SouFunUserBasicInfo.h"
#import "KFYTool.h"


//前端/OC交互标识
static NSString *const openView = @"openView";//打开新的web
static NSString *const openView2 = @"openView2";//打开新的web
static NSString *const productDetailGoBack = @"productDetailGoBack";//
static NSString *const invokePay = @"invokePay";//
static NSString *const gotoMine = @"gotoMine";//
static NSString *const toBuyTxqk = @"toBuyTxqk";//
static NSString *const toSettingPromotePage = @"toSettingPromotePage";//
static NSString *const closeLoading = @"closeLoading";//
static NSString *const uploadImageToServer = @"uploadImageToServer";//
static NSString *const selectCityConfirm = @"selectCityConfirm";//
static NSString *const sendAppShareInfo = @"sendAppShareInfo";//分享

static NSString *const getLocationInfo = @"getLocationInfo";// 定位
static NSString *const finishBrowser = @"finishBrowser";//关闭网页
static NSString *const scanQRCode = @"scanQRCode";//扫码
static NSString *const openLoading = @"openLoading";//
static NSString *const goback = @"goBack";//
static NSString *const logoutCreisApp = @"logoutCreisApp";//
static NSString *const setCreisData = @"setCreisData";//设置数据
static NSString *const getCreisData = @"getCreisData";//获取数据
static NSString *const setRequestedOrientation = @"setRequestedOrientation";//横竖屏切换，app是竖屏的时候就设置横屏，横屏的时候就设置竖屏
static NSString *const setCreisData2 = @"setCreisData2";//设置数据
static NSString *const getCreisData2 = @"getCreisData2";//获取数据
static NSString *const creisCallTel = @"creisCallTel";//打电话

static NSString *const openMapAppNav = @"openMapAppNav";//打开第三方导航
static NSString *const sendIMHouseDetailCard = @"sendIMHouseDetailCard";//im发送房源卡片
static NSString *const openIMChatList = @"openIMChatList";//跳转到im列表
static NSString *const reload = @"reload";//刷新网页
static NSString *const clearH5Cache = @"clearH5Cache";//清除缓存
static NSString *const clearH5CacheAndReload = @"clearH5CacheAndReload";//清除缓存并刷新网页

@interface SouFangNormalViewModel ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,TZImagePickerControllerDelegate,FangGroupRequestDelegate>

{
    WebViewManager *_webViewManager;
    SouFangNormalWKViewController *_controller;

}
@property (nonatomic, strong) FangLocationManager *locationManager;
@property (nonatomic, assign) NSInteger canUploadImageCount; //允许上传的图片数量
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSMutableArray *uploadImageModelArray;
@property (nonatomic, assign) NSInteger uploadCompleteErrorImageCount;   //上传失败的图片数量
@property (nonatomic, strong) NSMutableArray *uploadCompleteImageModels; //已上传的图片model
@property (nonatomic, strong) NSMutableArray *uploadCompleteImageUrls;   //已上传的图片链接


@end


@implementation SouFangNormalViewModel

-(void)addScriptMessageHandler:(WebViewManager *)webViewManager controller:(id <WKScriptMessageHandler>)controller{
    
    [webViewManager webViewAddScriptMessageHandler:controller name:openView];
    [webViewManager webViewAddScriptMessageHandler:controller name:productDetailGoBack];
    [webViewManager webViewAddScriptMessageHandler:controller name:invokePay];
    [webViewManager webViewAddScriptMessageHandler:controller name:gotoMine];
    [webViewManager webViewAddScriptMessageHandler:controller name:toBuyTxqk];
    [webViewManager webViewAddScriptMessageHandler:controller name:toSettingPromotePage];
    [webViewManager webViewAddScriptMessageHandler:controller name:getLocationInfo];
    [webViewManager webViewAddScriptMessageHandler:controller name:closeLoading];
    [webViewManager webViewAddScriptMessageHandler:controller name:uploadImageToServer];
    [webViewManager webViewAddScriptMessageHandler:controller name:selectCityConfirm];
    [webViewManager webViewAddScriptMessageHandler:controller name:sendAppShareInfo];
    
    [webViewManager webViewAddScriptMessageHandler:controller name:finishBrowser];
    [webViewManager webViewAddScriptMessageHandler:controller name:scanQRCode];
    [webViewManager webViewAddScriptMessageHandler:controller name:openLoading];
    [webViewManager webViewAddScriptMessageHandler:controller name:goback];
    [webViewManager webViewAddScriptMessageHandler:controller name:logoutCreisApp];
    [webViewManager webViewAddScriptMessageHandler:controller name:setCreisData];
    [webViewManager webViewAddScriptMessageHandler:controller name:getCreisData];
    [webViewManager webViewAddScriptMessageHandler:controller name:setRequestedOrientation];
    [webViewManager webViewAddScriptMessageHandler:controller name:setCreisData2];
    [webViewManager webViewAddScriptMessageHandler:controller name:getCreisData2];
    [webViewManager webViewAddScriptMessageHandler:controller name:creisCallTel];
    [webViewManager webViewAddScriptMessageHandler:controller name:openMapAppNav];
    [webViewManager webViewAddScriptMessageHandler:controller name:sendIMHouseDetailCard];
    [webViewManager webViewAddScriptMessageHandler:controller name:openIMChatList];
    [webViewManager webViewAddScriptMessageHandler:controller name:reload];
    [webViewManager webViewAddScriptMessageHandler:controller name:clearH5Cache];
    [webViewManager webViewAddScriptMessageHandler:controller name:clearH5CacheAndReload];

}
-(void)removeScriptMessageHandler:(WebViewManager *)webViewManager{
    [webViewManager webViewRemoveScriptMessageHandlerForName:openView];
    [webViewManager webViewRemoveScriptMessageHandlerForName:openView2];

    [webViewManager webViewRemoveScriptMessageHandlerForName:productDetailGoBack];
    [webViewManager webViewRemoveScriptMessageHandlerForName:invokePay];
    [webViewManager webViewRemoveScriptMessageHandlerForName:gotoMine];
    [webViewManager webViewRemoveScriptMessageHandlerForName:toBuyTxqk];
    [webViewManager webViewRemoveScriptMessageHandlerForName:toSettingPromotePage];
    [webViewManager webViewRemoveScriptMessageHandlerForName:getLocationInfo];
    [webViewManager webViewRemoveScriptMessageHandlerForName:closeLoading];
    [webViewManager webViewRemoveScriptMessageHandlerForName:uploadImageToServer];
    [webViewManager webViewRemoveScriptMessageHandlerForName:selectCityConfirm];
    [webViewManager webViewRemoveScriptMessageHandlerForName:sendAppShareInfo];
    
    [webViewManager webViewRemoveScriptMessageHandlerForName:finishBrowser];
    [webViewManager webViewRemoveScriptMessageHandlerForName:scanQRCode];
    [webViewManager webViewRemoveScriptMessageHandlerForName:openLoading];
    [webViewManager webViewRemoveScriptMessageHandlerForName:goback];
    [webViewManager webViewRemoveScriptMessageHandlerForName:logoutCreisApp];
    [webViewManager webViewRemoveScriptMessageHandlerForName:setCreisData];
    [webViewManager webViewRemoveScriptMessageHandlerForName:getCreisData];
    [webViewManager webViewRemoveScriptMessageHandlerForName:setCreisData2];
    [webViewManager webViewRemoveScriptMessageHandlerForName:getCreisData2];
    [webViewManager webViewRemoveScriptMessageHandlerForName:setRequestedOrientation];
    [webViewManager webViewRemoveScriptMessageHandlerForName:creisCallTel];
    [webViewManager webViewRemoveScriptMessageHandlerForName:openMapAppNav];
    [webViewManager webViewRemoveScriptMessageHandlerForName:sendIMHouseDetailCard];
    [webViewManager webViewRemoveScriptMessageHandlerForName:openIMChatList];
    [webViewManager webViewRemoveScriptMessageHandlerForName:reload];
    [webViewManager webViewRemoveScriptMessageHandlerForName:clearH5Cache];
    [webViewManager webViewRemoveScriptMessageHandlerForName:clearH5CacheAndReload];

}
- (void)share:(NSDictionary *)body controller:(SouFangNormalWKViewController *)controller{
    
    NSString *title = [KFYTool safeString:body[@"title"]]; //标题
    NSString *content = [KFYTool safeString:body[@"content"]]; //摘要
    NSString *shareUrl = [KFYTool safeString: body[@"shareUrl"]]; //要分享的链接地址
    NSString *imageUrl = [KFYTool safeString:body[@"imageUrl"]]; //缩略图地址
    NSString *imgShareUrl = [KFYTool safeString:body[@"imgShareUrl"]]; //图片分享地址
    imgShareUrl = [imgShareUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSInteger showImgShare = [[NSString stringWithFormat:@"%@",[KFYTool safeString:body[@"showImgShare"]]] intValue]; //是否展示图片分享按钮
    
    
    UIImage *shareimag=[UIImage imageNamed:@"jjyIcon.png"];
    NSData *shareimagdata=UIImageJPEGRepresentation(shareimag, 1);
    SouFunShareService * shareService = [SouFunShareService sharedSouFunShareService];
    
    if (showImgShare && showImgShare == 1) {
        //显示微信，朋友圈,美图分享
        shareService.shareOrigin = FangShareOriginalDiZhu;
    } else {
        //显示显示微信，朋友圈分享
        shareService.shareOrigin = FangShareOriginalWebPage;
    }

    ShareDataModel * shareData = [[ShareDataModel alloc] init];
    shareData.shareOrigin = FINANCE_LOAN_PLAN;
    shareData.shareTitle = title;         //微信好友\QQ好友 - 主标题
    shareData.shareShortContent = content;  //短信文字
    shareData.shareContent = content;
    shareData.wechatContent = content;      //微信好友\QQ好友 - 副标题
    shareData.wechatCirleTitle = title;   //微信朋友圈 - 标题
    shareData.shareImage = shareimag;
    shareData.shareImageData = shareimagdata;
    shareData.meituLink = imgShareUrl;
    shareData.webURL = shareUrl;  //分享链接
    [shareService showPanelInViewController:controller andShareModel:shareData];
}

- (void)startLocationAction:(WebViewManager *)webViewManager{
    WS(weakSelf)
    self.locationManager.reverseGeocoderLocation = ^(FangPlacemark *mark, NSError *error) {
        CLLocationCoordinate2D baiduCoordinate = mark.result.location;
        if(baiduCoordinate.longitude > 0 && baiduCoordinate.latitude > 0) {
//                SouFunUserBasicInfo *userInfo = [SouFunUserBasicInfo sharedSouFunUserBasicInfo];
                NSString *coordX = [NSString stringWithFormat:@"%f", baiduCoordinate.longitude];
                NSString *coordY = [NSString stringWithFormat:@"%f", baiduCoordinate.latitude];

                if (!coordX) {
                    coordX = @"";
                }
                if (!coordY) {
                    coordY = @"";
                }

                NSString *city = mark.city;
//                if (userInfo.tdyLocationCity.length > 0) {
//                    city = userInfo.tdyLocationCity;
//                }

                NSDictionary *locationDict = @{
                                               @"xLocation":coordX,
                                               @"yLocation":coordY,
                                               @"city":city
                                               };
                NSString *paraJson  = [KFYTool dicTOjsonString:locationDict];
                NSString * evaluatStr = [NSString stringWithFormat:@"setLocation(\'%@\')",paraJson];
                [webViewManager evaluateJavaScript:evaluatStr];
                NSLog(@"myLocation:%@",locationDict);
            }
    };
//    self.locationManager.didUpdateLocations = ^(CLLocationCoordinate2D baiduCoordinate, FangLocationResultCode locationResultCode) {
//        if (locationResultCode == FangLocationResultCode_Success) {
//            if(baiduCoordinate.longitude > 0 && baiduCoordinate.latitude > 0) {
////                SouFunUserBasicInfo *userInfo = [SouFunUserBasicInfo sharedSouFunUserBasicInfo];
//                NSString *coordX = [NSString stringWithFormat:@"%f", baiduCoordinate.longitude];
//                NSString *coordY = [NSString stringWithFormat:@"%f", baiduCoordinate.latitude];
//
//                if (!coordX) {
//                    coordX = @"";
//                }
//                if (!coordY) {
//                    coordY = @"";
//                }
//
//                NSString *city = @"";
////                if (userInfo.tdyLocationCity.length > 0) {
////                    city = userInfo.tdyLocationCity;
////                }
//
//                NSDictionary *locationDict = @{
//                                               @"xLocation":coordX,
//                                               @"yLocation":coordY,
//                                               @"city":city
//                                               };
//                NSString *paraJson  = [KFYTool dicTOjsonString:locationDict];
//                NSString * evaluatStr = [NSString stringWithFormat:@"WEB.setLocation('%@')",paraJson];
//                [webViewManager evaluateJavaScript:evaluatStr];
//                NSLog(@"myLocation:%@",locationDict);
//            }
//        } else {
//            //@"定位失败 请重试";
//        }
//    };
    [self.locationManager startUpdatingLocation];
}
- (void)chooseImage:(SouFangNormalWKViewController *)controller webViewManager:(WebViewManager *)webViewManager imageCount:(NSString *)imageCount{
    _controller = controller;
    _webViewManager = webViewManager;
    [self showAddActionSheet];
}
- (void)showAddActionSheet {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak __typeof(self)weakSelf = self;
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"拍照上传" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"拍照上传");
        [weakSelf startCameraController];
    }];
    [alertController addAction:cameraAction];
    
    
    UIAlertAction *photoLibraryAction = [UIAlertAction actionWithTitle:@"手机相册上传" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [weakSelf presentImagePickerController];
    }];
    [alertController addAction:photoLibraryAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"取消");
    }];
    [alertController addAction:cancelAction];
    
    [_controller presentViewController:alertController animated:YES completion:nil];
}
//多选图片选择器
- (void)presentImagePickerController {
    TZImagePickerController * image = [[TZImagePickerController alloc] initWithMaxImagesCount:[self maximumNumberOfSelection] delegate:self];
    image.allowPickingOriginalPhoto = NO;
    image.allowTakePicture = NO;
    [_controller presentViewController:image animated:YES completion:nil];
}
//最多还可以选择的图片数
- (NSInteger)maximumNumberOfSelection {
    if (self.canUploadImageCount) {
        return self.canUploadImageCount;
    } else {
        return 9;
    }
}
#pragma mark - TZImagePickerControllerDelegate
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
{
//    SFun_Log(@"isMain=%d", [NSThread isMainThread]);
    
    self.hud = [MBProgressHUD showHUDAddedTo:_controller.navigationController.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.labelText = @"处理中...";
    
    self.uploadImageModelArray= [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        for (PHAsset *asset in assets) {
            
            FangImageUploadModel *resultModel =  [self uploadModelFromPHAsset:asset];
            [self.uploadImageModelArray addObject:resultModel];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self->_controller.navigationController.view animated:YES];
            [self batchUploadImage];
        });
    });
}
//根据PHAsset创建模型
- (FangImageUploadModel *)uploadModelFromPHAsset:(PHAsset *)asset {
    @autoreleasepool {
//        FangImageUploadModel *model = [[FangImageUploadModel alloc] init];
//        UIImage *fullResolutionImage = [asset originImage];
//        NSData *imageData = [FangHelper compressedDataFromOriginalImage:fullResolutionImage];
//        model.imageData = imageData;
//        model.thumbnailImage = [asset thumbnailWithSize:CGSizeMake(200/2.0, 155/2.0)];
//        return model;
    }
}
//批量上传图片
- (void)batchUploadImage {
    NSMutableArray *requestArray = [NSMutableArray array];
    NSMutableArray *uploadArray = [self.uploadImageModelArray mutableCopy];
    if (uploadArray && uploadArray.count > 0 ) {
        for (FangImageUploadModel *photoModel in uploadArray) {
            if (!photoModel.imageURL) {
                SouFunUploadImageAPI *api = [[SouFunUploadImageAPI alloc] initWithUploadType:SFBUploadImageChannelType_Dizhu];
                api.imageData = photoModel.imageData;
                [requestArray addObject:api];
            }
        }
    }
    FangGroupRequest *groupRequest = [[FangGroupRequest alloc] initWithRequestArray:requestArray];
    groupRequest.delegate = self;
    [groupRequest resume];
}
//启动相机。
- (void)startCameraController {
    
    [MBProgressHUD showHUDAddedTo:_controller.navigationController.view animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [FangHelper checkCameraAuthorization:^(BOOL authorized) {
//            if (authorized) {
//                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//                    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
//                    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
//                    cameraUI.modalPresentationStyle = UIModalPresentationCurrentContext;
//                    cameraUI.allowsEditing = NO;
//                    cameraUI.delegate = self;
//                    cameraUI.modalPresentationStyle = UIModalPresentationCurrentContext;
//                    [self->_controller presentViewController:cameraUI animated:YES completion:^{
//                        [MBProgressHUD hideHUDForView:self->_controller.navigationController.view animated:YES];
//                    }];
//                }
//            } else {
//                [MBProgressHUD hideHUDForView:self->_controller.navigationController.view animated:YES];
//                [self showUnauthorizedAlert];
//            }
//        }];
    });
}
//展示未授权警告弹框
- (void)showUnauthorizedAlert {
    NSString *title = @"无法使用相机";
    NSString *message = @"请在iPhone的\"设置-隐私-相机\"中允许访问相机。";
    NSString *cancelButtonTitle = @"取消";
    NSString *otherButtonTitle = @"去设置";
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:NULL];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    
    [_controller presentViewController:alertController animated:YES completion:NULL];
}
#pragma mark - FangGroupRequestDelegate

//组请求开始
- (void)groupRequestDidStart:(FangGroupRequest *)groupRequest {
    self.hud = [MBProgressHUD showHUDAddedTo:_controller.navigationController.view animated:YES];
    self.hud.mode = MBProgressHUDModeAnnularDeterminate;
    self.hud.progress = 0;
    self.hud.labelText = @"上传中...";
}

//组请求结束(包括成功和失败)
- (void)groupRequestDidCompletion:(FangGroupRequest *)groupRequest {
    
    [MBProgressHUD hideHUDForView:_controller.navigationController.view animated:YES];
    
    self.uploadCompleteErrorImageCount = 0;
    NSMutableArray *completeImageModels = [NSMutableArray array];
    NSMutableArray *completeImageUrls = [NSMutableArray array];
    for (SouFunUploadImageAPI *request in groupRequest.requestArray) {
        if ([request isKindOfClass:[SouFunUploadImageAPI class]]) {
            
            FangImageUploadModel *model = [[FangImageUploadModel alloc] init];
            if (request.error) {
                self.uploadCompleteErrorImageCount ++;
                model.error = YES;
            } else {
                if (request.errorNumber) {
                    self.uploadCompleteErrorImageCount ++;
                    model.error = YES;
                    model.illegal = YES;//图片大小不合法
                } else {
                    model.imageURL = request.responsePictureURL;
                    model.width = request.width;
                    model.height = request.height;
                    
                    [completeImageModels addObject:model];
                    if (model.imageURL) {
                        [completeImageUrls addObject:model.imageURL];
                    }
                }
            }
        }
    }
    self.uploadCompleteImageModels = completeImageModels;
    self.uploadCompleteImageUrls = completeImageUrls;
    
    if (self.uploadCompleteImageModels.count == 0) {
        [self showHudText:@"图片上传失败"];
    } else {
                [self showHudText:@"图片上传成功"];
        NSString *paraJson = [KFYTool dicTOjsonString:completeImageUrls];
        NSString * evaluatStr = [NSString stringWithFormat:@"WEB.uploadImageDownloadLinkToserver('%@')",paraJson];
        [_webViewManager evaluateJavaScript:evaluatStr];
        NSLog(@"paraJson:%@",evaluatStr);
    }
}
//展示提示文字
- (void)showHudText:(NSString *)text {
    MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:_controller.view animated:YES];
    progressHUD.mode = MBProgressHUDModeText;
    progressHUD.labelText = text;
    [progressHUD hide:YES afterDelay:3];
}
#pragma lazyLoad
- (FangLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [FangLocationManager sharedInstance];
    }
    return _locationManager;
}
@end
