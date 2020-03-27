//
//  SYWebViewManager.m
//
//

#import "WebViewManager.h"
#import "WKProcessPool+WebCarProcessPool.h"
#import "UIColor+HexString.h"
#import "Masonry.h"
#import "KFYTool.h"
//#import "UIDevice+IdentifierAddition.h"
#import "SouFunUserBasicInfo.h"
#import "CustomURLSchemeHandler.h"

@interface WebViewManager ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@property (nonatomic,strong,readwrite) WKWebView *webView;
@property (nonatomic ,strong) UIView *progress;

@property (nonatomic ,strong) CAGradientLayer *gradientLayer;
/** 键盘弹起屏幕偏移量 */
@property (nonatomic, assign) CGPoint keyBoardPoint;
@end

@implementation WebViewManager

-(UIView *)lineView
{
    if (!_lineView) {
        _lineView =[UIView new];
        _lineView.backgroundColor =[UIColor clearColor];
    }
    return _lineView;
}

-(void)sendWebViewToSuperView:(UIView *)superView withFrame:(CGRect)frame controller:(id <WKScriptMessageHandler>)controller{
    [self addWebView:controller];
    [superView addSubview:self.webView];
    [self.webView addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.webView);
        make.width.equalTo(@15);
    }];
//    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
//        [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
//    //        make.edges.equalTo(superView);
//            make.top.equalTo(superView.mas_top).offset(statusBarFrame.size.height);
//            make.left.equalTo(superView.mas_left);
//            make.right.equalTo(superView.mas_right);
//            make.bottom.equalTo(superView.mas_bottom).offset(-FIT_BOTTOMSAFE_HEIGHT);
//        }];

//    self.webView.frame = frame;
    [self registerKVO];
}
- (void)resetFrame:(UIView *)superView{

    self.webView.frame = UIEdgeInsetsInsetRect(superView.bounds, UIEdgeInsetsMake(FIT_STATUSBAR_HEIGHT, 0,  FIT_BOTTOMSAFE_HEIGHT, 0));

}
-(void)webViewAddScriptMessageHandler:(id <WKScriptMessageHandler>)scriptMessageHandler name:(NSString *)name{
    if( self.webView.configuration.userContentController == nil ){
        self.webView.configuration.userContentController = [[WKUserContentController alloc] init];
    }
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:name];
    [self.webView.configuration.userContentController addScriptMessageHandler:scriptMessageHandler name:name];
    
}

-(void)webViewAddUserScriptSource:(NSString *)scriptSource atInjectionTime:(WKUserScriptInjectionTime)injectionTime{
    if( self.webView.configuration.userContentController == nil ){
        self.webView.configuration.userContentController = [[WKUserContentController alloc] init];
    }
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:scriptSource injectionTime:injectionTime forMainFrameOnly:YES];
    [self.webView.configuration.userContentController addUserScript:userScript];
    
}
-(void)evaluateJavaScript:(NSString *)scriptSource{
    [self.webView evaluateJavaScript:scriptSource completionHandler:^(id object, NSError * _Nullable error) {
        
    }];
}
//当wkwebview把html加载完之后，调用此方法(否则无效)
-(void)webViewRemoveAllUserScript{
    [self.webView.configuration.userContentController removeAllUserScripts];
}
-(void)webViewRemoveScriptMessageHandlerForName:(NSString *)name{
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:name];
}

-(void)reloadWebView{
    [self.webView reload];
}
- (NSString *)readCurrentCookieWithDomain:(NSString *)domainStr{
    NSHTTPCookieStorage*cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSMutableString * cookieString = [[NSMutableString alloc]init];
    for (NSHTTPCookie*cookie in [cookieJar cookies]) {
        [cookieString appendFormat:@"%@=%@;",cookie.name,cookie.value];
    }
    //删除最后一个“;”
    if ([cookieString hasSuffix:@";"]) {
        [cookieString deleteCharactersInRange:NSMakeRange(cookieString.length - 1, 1)];
    }
    return cookieString;
}
-(void)webViewLoadUrl:(NSString *)urlString{

    if ([urlString containsString:@"http://"] || [urlString containsString:@"https://"]) {
        dispatch_async(dispatch_get_main_queue(),^{
            
           
            [self addCookies];
            [self add3fangCookies];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
            [KFYTool setHeader:request];

            [request addValue: [self readCurrentCookieWithDomain:@""] forHTTPHeaderField:@"Cookie"];

//            [request addValue: @"chunked" forHTTPHeaderField:@"Transfer-Encoding"];

            [self.webView loadRequest:request];
        });
        
    }
}
- (void)webViewLoadFile:(NSString *)file accessFile:(NSString *)accessFile{
    if ([file containsString:@"file://"] || [accessFile containsString:@"file://"]) {
        dispatch_async(dispatch_get_main_queue(),^{
            
            [self.webView loadFileURL:[NSURL URLWithString:file] allowingReadAccessToURL:[NSURL URLWithString:accessFile]];
        });
        
    }
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if( [object isEqual:self.webView] ){
        if( [keyPath isEqualToString:@"title"] ){
            if( [self.delegate respondsToSelector:@selector(webViewManager:webViewTitleDidChange:)] ){
                [self.delegate webViewManager:self webViewTitleDidChange:self.webView.title];
            }
        }
        if( [keyPath isEqualToString:@"estimatedProgress"] ){
            if( !_progressHidden ){
//                self.progress.ly_width =self.webView.estimatedProgress*[UIScreen mainScreen].bounds.size.width;
                _gradientLayer.frame = self.progress.frame;
                if( self.webView.estimatedProgress==1 ){
                    [self removeProgressView];
                }
            }
            if( [self.delegate respondsToSelector:@selector(webViewManager:webViewLoadingWithProgress:)] ){
                [self.delegate webViewManager:self webViewLoadingWithProgress:self.webView.estimatedProgress];
            }
        }
//        if ([keyPath isEqualToString:@"contentSize"]) {
//            NSLog(@"self.webView.scrollView.contentSize %f %f,change:%@", self.webView.scrollView.contentSize.width, self.webView.scrollView.contentSize.height,change);
//
//
    }
//    if ([keyPath isEqualToString:@"contentSize"] || [keyPath isEqualToString:@"contentOffset"]) {
//       NSLog(@"self.webView.scrollView.contentSize %f %f,change:%@ contentOffset %f %f", self.webView.scrollView.contentSize.width, self.webView.scrollView.contentSize.height,change,self.webView.scrollView.contentOffset.x,self.webView.scrollView.contentOffset.y);
//    }
}
#pragma mark - webView navigation delegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    if( [self.delegate respondsToSelector:@selector(webViewManagerLoadingDidStart:)] ){
        [self.delegate webViewManagerLoadingDidStart:self];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if( [self.delegate respondsToSelector:@selector(webViewManagerLoadingDidFinished:)] ){
        [self.delegate webViewManagerLoadingDidFinished:self];
    }
}
-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    if ([self.delegate respondsToSelector:@selector(webViewManagerLoadingDidCommit:)]) {
        [self.delegate webViewManagerLoadingDidCommit:self];
    }
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
   
//    if (((NSHTTPURLResponse *)navigationResponse.response).statusCode == 200) {
//        decisionHandler (WKNavigationResponsePolicyAllow);
//    }else {
//        decisionHandler(WKNavigationResponsePolicyCancel);
//    }
    //允许跳转
        decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//    [self removeWebView];
    if( [self.delegate respondsToSelector:@selector(webViewManagerLoadingDidFailed: navigation:error:)] ){
        [self.delegate webViewManagerLoadingDidFailed:self navigation:navigation error:error];
    }
    if( !_progressHidden ){
        [self removeProgressView];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSMutableURLRequest *mutableRequest = [navigationAction.request mutableCopy];
    
    NSDictionary *requestHeaders = navigationAction.request.allHTTPHeaderFields;
    
    if (requestHeaders[@"Cookie"]) {
//        [self addCookies];
//        [self add3fangCookies];
        [KFYTool setHeader:mutableRequest];
        [mutableRequest addValue: [self readCurrentCookieWithDomain:@""] forHTTPHeaderField:@"Cookie"];
    }
    if ([self.delegate respondsToSelector:@selector(webViewManager:webView:decidePolicyForNavigationAction:decisionHandler:)]) {
        [self.delegate webViewManager:self webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    }
    decisionHandler(WKNavigationActionPolicyAllow);//允许跳转

//    NSURL *URL = navigationAction.request.URL;
//
//
//    NSString *scheme = [URL scheme];
//    if ([scheme isEqualToString:self.scheme]) {
//
//        decisionHandler(WKNavigationActionPolicyCancel);
//
//        NSString *absoluteString = URL.absoluteString;
//        if ([absoluteString containsString:@"https"]) {
//            absoluteString = [absoluteString stringByReplacingOccurrencesOfString:@"https//" withString:@"https://"];
//        }else{
//            absoluteString = [absoluteString stringByReplacingOccurrencesOfString:@"http//" withString:@"http://"];
//        }
//        if ([self.delegate respondsToSelector:@selector(webViewManager:pushWebViewController:)]) {
//            [self.delegate webViewManager:self pushWebViewController:absoluteString];
//        }
//        return;
//    }
//
//    if ([scheme isEqualToString:@"haleyaction"]) {
//
//        decisionHandler(WKNavigationActionPolicyCancel);
//        return;
//    }
//    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([self.delegate respondsToSelector:@selector(cyx_userContentController:didReceiveScriptMessage:)]) {
        [self.delegate cyx_userContentController:userContentController didReceiveScriptMessage:message];
    }
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
}
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView API_AVAILABLE(macos(10.11), ios(9.0)){
    //白屏reload
    [webView reload];
}

#pragma mark WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [[[UIApplication sharedApplication] delegate].window.rootViewController presentViewController:alertController animated:YES completion:nil];
    
}
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    //    DLOG(@"msg = %@ frmae = %@",message,frame);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [[[UIApplication sharedApplication] delegate].window.rootViewController presentViewController:alertController animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    
    [[[UIApplication sharedApplication] delegate].window.rootViewController presentViewController:alertController animated:YES completion:nil];
}
- (void)deleteWebCache:(BOOL )reload {
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
        
                    NSSet *websiteDataTypes
        
                    = [NSSet setWithArray:@[
        
                                            WKWebsiteDataTypeDiskCache,
        
                                            WKWebsiteDataTypeOfflineWebApplicationCache,
        
                                            WKWebsiteDataTypeMemoryCache,
        
                                            WKWebsiteDataTypeLocalStorage,
        
//                                            WKWebsiteDataTypeCookies,
        
                                            WKWebsiteDataTypeSessionStorage,
        
                                            WKWebsiteDataTypeIndexedDBDatabases,
        
                                            WKWebsiteDataTypeWebSQLDatabases
        
                                            ]];
        
        //// All kinds of data
        
//        NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        
        //// Date from
        
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        
        //// Execute
        
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            // Done
            if (reload) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.webView reload];

                });
            }
        }];
        
    } else {
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
        
        NSError *errors;
        
        [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
        if (reload) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.webView reload];

            });
        }
    }
}

-(void)removeProgressView{
    if( _progress ){
        [_progress removeFromSuperview];
        _progress = nil;
    }
}
-(void)removeWebView{
    if( self.webView){
        [self unRegisterKVO];
        [self.webView removeFromSuperview];
        self.webView = nil;
    }
}

-(void)setProgressHidden:(BOOL)progressHidden{
    _progressHidden = progressHidden;
    if( _progressHidden ){
        [self removeProgressView];
    }
}
#pragma WebViewJavascriptBridge

- (void)bridgeForWebView:(WKWebView*)webView{
    
//    [WebViewJavascriptBridge enableLogging];
//    _bridge = [WebViewJavascriptBridge bridgeForWebView:webView];
    
}
//js->native->js
//- (void)registerHandler:(NSString *)handlerName handler:(WVJBHandler)handler{
//
//
//    [_bridge registerHandler:handlerName handler:handler];
//
//}

//native->js
//- (void)callHandler:(NSString *)handlerName data:(id)data{
//    [_bridge callHandler:handlerName data:data];
//}

//native->js->native
//- (void)callHandler:(NSString *)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback{
//
//    [_bridge callHandler:handlerName data:data responseCallback:responseCallback];
//}
#pragma mark
-(void)registerKVO{
    if(self.webView ){
        [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
        [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
//        [self.webView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
//        [self.webView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:@"WebKitContext"];
//        [self.webView.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:@"WebKitContext"];



//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStateChange) name:kReachabilityChangedNotification object:nil];
//        Reachability *rea = [Reachability reachabilityForInternetConnection];
//        [rea startNotifier];
    }
}

//-(void)networkStateChange
//{
//    if ([WebSourceManager shareInstance].cutNet) {
//        if( [self.delegate respondsToSelector:@selector(webViewManagerNetWorkFailed:)]){
//            [self.delegate webViewManagerNetWorkFailed:self];
//        }
//    }
//}


-(void)unRegisterKVO{
    if( self.webView ){
        
        @try {
            
            [self.webView removeObserver:self forKeyPath:@"title"];
            [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
//            [self.webView removeObserver:self forKeyPath:@"contentSize"];
//            [self.webView.scrollView removeObserver:self forKeyPath:@"contentSize"];
//            [self.webView.scrollView removeObserver:self forKeyPath:@"contentOffset"];

            
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    }
}
- (void)addWebView:(id <WKScriptMessageHandler>)controller{
     _progressHidden = NO;
    //        NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    //        WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    //        WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    //        [wkUController addUserScript:wkUScript];
            
            WKUserContentController *userContentController = [[WKUserContentController alloc] init];
            [userContentController addScriptMessageHandler:controller  name:@"openView"];
            [userContentController addScriptMessageHandler:controller  name:@"openView2"];
            [userContentController addScriptMessageHandler:controller  name:@"productDetailGoBack"];
            [userContentController addScriptMessageHandler:controller  name:@"gotoMine"];
            [userContentController addScriptMessageHandler:controller  name:@"toBuyTxqk"];
            [userContentController addScriptMessageHandler:controller  name:@"toSettingPromotePage"];
            [userContentController addScriptMessageHandler:controller  name:@"closeLoading"];
            [userContentController addScriptMessageHandler:controller  name:@"uploadImageToServer"];
            [userContentController addScriptMessageHandler:controller  name:@"selectCityConfirm"];
            [userContentController addScriptMessageHandler:controller  name:@"sendAppShareInfo"];
            [userContentController addScriptMessageHandler:controller  name:@"getLocationInfo"];
            [userContentController addScriptMessageHandler:controller  name:@"finishBrowser"];
            [userContentController addScriptMessageHandler:controller  name:@"scanQRCode"];
            [userContentController addScriptMessageHandler:controller  name:@"openLoading"];
            [userContentController addScriptMessageHandler:controller  name:@"goBack"];
            [userContentController addScriptMessageHandler:controller  name:@"logoutCreisApp"];
            [userContentController addScriptMessageHandler:controller  name:@"setCreisData"];
            [userContentController addScriptMessageHandler:controller  name:@"getCreisData"];
            [userContentController addScriptMessageHandler:controller  name:@"setCreisData2"];
            [userContentController addScriptMessageHandler:controller  name:@"getCreisData2"];
            [userContentController addScriptMessageHandler:controller  name:@"setRequestedOrientation"];
            [userContentController addScriptMessageHandler:controller  name:@"creisCallTel"];
            [userContentController addScriptMessageHandler:controller  name:@"openMapAppNav"];
            [userContentController addScriptMessageHandler:controller  name:@"sendIMHouseDetailCard"];
            [userContentController addScriptMessageHandler:controller  name:@"openIMChatList"];
            [userContentController addScriptMessageHandler:controller  name:@"reload"];
            [userContentController addScriptMessageHandler:controller  name:@"clearH5Cache"];
            [userContentController addScriptMessageHandler:controller  name:@"clearH5CacheAndReload"];

            WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
            configuration.userContentController = userContentController;

            configuration.allowsInlineMediaPlayback = YES;
            configuration.processPool = [WKProcessPool sharedProcessPool];
            configuration.ignoresViewportScaleLimits = YES;
           if (@available(iOS 11.0, *)) {
                if ([[SouFunUserBasicInfo sharedSouFunUserBasicInfo].webIntercept isEqualToString:@"on"]) {
                    [configuration setURLSchemeHandler:[CustomURLSchemeHandler new] forURLScheme: @"creisScheme"];

                }
                if ([SouFunUserBasicInfo sharedSouFunUserBasicInfo].webBlackList.count) {
                    for (NSString *black in [SouFunUserBasicInfo sharedSouFunUserBasicInfo].webBlackList) {
                        if (black && black.length) {
                            [configuration setURLSchemeHandler:[CustomURLSchemeHandler new] forURLScheme: black];
                        }

                    }
                }
            } else {
                        // Fallback on earlier versions
            }
    //        configuration.preferences.javaScriptEnabled=YES;
    
           WKWebView * webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
            if (@available(iOS 10.0, *)) {
                configuration.mediaTypesRequiringUserActionForPlayback = false;
            } else {
                // Fallback on earlier versions
            }
            webView.navigationDelegate = self;
            webView.UIDelegate = self;
    //        [webView.configuration.preferences setValue:@(YES) forKey:@"allowFileAccessFromFileURLs"];
            webView.scrollView.showsVerticalScrollIndicator = NO;
            webView.scrollView.showsHorizontalScrollIndicator = NO;
            if(@available(iOS 11.0, *)) {
                webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
    //        webView.scrollView.scrollEnabled = NO;
    //        webView.opaque = NO;

            webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
           self.webView = webView;
    //        [self setUserAgent:webView];
            //iOS12 - 使用WKWebView出现input键盘将页面上顶不下移
            // 监听将要弹起
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardShow) name:UIKeyboardWillShowNotification object:nil];
            // 监听将要隐藏
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardHidden) name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark

- (void )setUserAgent:(WKWebView *)wkWebView{
    
    if (!wkWebView) {
        wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero];
    }
    [wkWebView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
//        NSLog(@"userAgent:%@", result);
        [self appendUserAgent:result webView:wkWebView];
    }];
    
}
-(void )appendUserAgent:(NSString *)userAgent webView:(WKWebView *)webView{
    
    if (userAgent) {
        NSString * header1 = @"ios_wyy";
        
        header1= [header1 stringByAppendingString:@"~"];
        header1=[header1 stringByAppendingString:[[UIDevice currentDevice] model]];
        header1= [header1 stringByAppendingString:@"~"];
        header1=[header1 stringByAppendingString:[[UIDevice currentDevice] systemVersion]];
//        if ([userAgent containsString:@" cheyixiao/"]) {
//            //会重复拼接 需要把上一次的删除
//            NSRange range = [userAgent rangeOfString:@" cheyixiao/"];
//            userAgent     = [userAgent substringToIndex:range.location];
//        }
//        NSString *customUserAgent = [userAgent stringByAppendingString:[NSString stringWithFormat:@" cheyixiao/%@",[self getAppVersion]]];
        NSString *customUserAgent = [userAgent stringByAppendingString:header1];

        [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent":customUserAgent}];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //        webView = [[WKWebView alloc] initWithFrame:CGRectZero];
    }else{
        [self setUserAgent:webView];
    }
    
}
- (NSString *)getAppVersion {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    CFShow((__bridge CFTypeRef)(infoDictionary));
    // app版本
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return app_Version;
}
/// 键盘将要弹起
- (void)keyBoardShow {
    CGPoint point = self.webView.scrollView.contentOffset;
    self.keyBoardPoint = point;
    
}
/// 键盘将要隐藏
- (void)keyBoardHidden {
    if (@available(iOS 12.0, *)) {
        WKWebView *webview = (WKWebView*)self.webView;
        for(UIView* v in webview.subviews){
            if([v isKindOfClass:NSClassFromString(@"WKScrollView")]){
                UIScrollView *scrollView = (UIScrollView*)v;
                [scrollView setContentOffset:CGPointMake(0, 0)];
            }
        }
    }
//    self.webView.scrollView.contentOffset = self.keyBoardPoint;
//    NSLog(@"%.2f %.2f", self.webView.width, self.webView.height);
}

-(UIView *)progress
{
    if (!_progress)
    {
        _progress = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 3)];
//        _progress.layer.cornerRadius = _progress.ly_height/2;
        _progress.layer.masksToBounds = YES;
        [self.webView addSubview:_progress];
        [self.webView bringSubviewToFront:_progress];
        
        _gradientLayer = [CAGradientLayer layer];
        
        //  设置 gradientLayer 的 Frame
        _gradientLayer.frame = _progress.frame;
        
        //  创建渐变色数组，需要转换为CGColor颜色
        _gradientLayer.colors = @[(id)[UIColor whiteColor].CGColor,
                                 
                                 (id)[UIColor  colorWithHexString:@"#FF4C4B"].CGColor];
        
        //  设置三种颜色变化点，取值范围 0.0~1.0
        _gradientLayer.locations = @[@(0.1f) ,@(1.0f)];
        //  设置渐变颜色方向，左上点为(0,0), 右下点为(1,1)
        _gradientLayer.startPoint = CGPointMake(0, 0);
        _gradientLayer.endPoint = CGPointMake(1, 0);
        //  添加渐变色到创建的 UIView 上去
        [_progress.layer addSublayer:_gradientLayer];

    }
    return _progress;
}
- (void)addCookies{
    [self writeSecurityAuthCookie];
    [self writeSecurityAuthSfytCookie];
//    [self writeSecurityAuthUserIdCookie];
//    [self writeSecurityAuthTokenCookie];
}
- (void)add3fangCookies{
    [self write3FangSecurityAuthCookie];
    [self write3fangSecurityAuthSfytCookie];
//    [self write3FangSecurityAuthUserIdCookie];
//    [self write3fangSecurityAuthTokenCookie];
}
//- (void)writeSecurityAuthUserIdCookie {
//
//    NSString *userId = [KFYTool safeString:[SouFunUserBasicInfo sharedSouFunUserBasicInfo].userid];
//
//    NSDictionary *cookieDic = [NSDictionary dictionaryWithObjectsAndKeys:
//                               @".fang.com", NSHTTPCookieDomain,
//                               @"/", NSHTTPCookiePath,
//                               @"userId",  NSHTTPCookieName,
//                               [NSDate dateWithTimeIntervalSinceNow:30*24*3600], NSHTTPCookieExpires,
//                               userId, NSHTTPCookieValue,
//                               nil];
//    NSHTTPCookie *userInfoCookie = [NSHTTPCookie cookieWithProperties:cookieDic];
//    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:userInfoCookie];
//}
//
//- (void)writeSecurityAuthTokenCookie {
//
//    NSString *token = [KFYTool safeString:[SouFunUserBasicInfo sharedSouFunUserBasicInfo].token];
//
//    NSDictionary *cookieDic = [NSDictionary dictionaryWithObjectsAndKeys:
//                               @".fang.com", NSHTTPCookieDomain,
//                               @"/", NSHTTPCookiePath,
//                               @"creis_apptoken",  NSHTTPCookieName,
//                               [NSDate dateWithTimeIntervalSinceNow:30*24*3600], NSHTTPCookieExpires,
//                               token, NSHTTPCookieValue,
//                               nil];
//    NSHTTPCookie *userInfoCookie = [NSHTTPCookie cookieWithProperties:cookieDic];
//    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:userInfoCookie];
//}
///**
// 3fang.com cookie
// */
//- (void)write3FangSecurityAuthUserIdCookie {
//
//    NSString *userId = [KFYTool safeString:[SouFunUserBasicInfo sharedSouFunUserBasicInfo].userid];
//
//    NSDictionary *cookieDic = [NSDictionary dictionaryWithObjectsAndKeys:
//                               @".3fang.com", NSHTTPCookieDomain,
//                               @"/", NSHTTPCookiePath,
//                               @"userId",  NSHTTPCookieName,
//                               [NSDate dateWithTimeIntervalSinceNow:30*24*3600], NSHTTPCookieExpires,
//                               userId, NSHTTPCookieValue,
//                               nil];
//    NSHTTPCookie *userInfoCookie = [NSHTTPCookie cookieWithProperties:cookieDic];
//    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:userInfoCookie];
//}
//
///**
// 3fang.com cookie
// */
//- (void)write3fangSecurityAuthTokenCookie {
//
//    NSString *token = [KFYTool safeString:[SouFunUserBasicInfo sharedSouFunUserBasicInfo].token];
//
//    NSDictionary *cookieDic = [NSDictionary dictionaryWithObjectsAndKeys:
//                               @".3fang.com", NSHTTPCookieDomain,
//                               @"/", NSHTTPCookiePath,
//                               @"creis_apptoken",  NSHTTPCookieName,
//                               [NSDate dateWithTimeIntervalSinceNow:30*24*3600], NSHTTPCookieExpires,
//                               token, NSHTTPCookieValue,
//                               nil];
//    NSHTTPCookie *userInfoCookie = [NSHTTPCookie cookieWithProperties:cookieDic];
//    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:userInfoCookie];
//}
- (void)writeSecurityAuthCookie {
    //    NSString *sft_cookie = @"958D79F2AB6529EB317888DAC40EB4226E6CA777BB50201DD306FDBC6F2B5C168838537FF0167A29595AC78F25E6EDE683FF1E9CCCA4496BF933FF1F74ABB15FB6DD48D2C516BFB63AB2B3DA61D2438596D4C9B26FC2EEA3DAC960FB4A7A1C4F";
    SouFunUserBasicInfo *userinfo = [SouFunUserBasicInfo sharedSouFunUserBasicInfo];
    NSString *sft_cookie = [KFYTool safeString:userinfo.sfut_cookie];

    NSDictionary *cookieDic = [NSDictionary dictionaryWithObjectsAndKeys:
                               @".fang.com", NSHTTPCookieDomain,
                               @"/", NSHTTPCookiePath,
                               @"sfut",  NSHTTPCookieName,
                               [NSDate dateWithTimeIntervalSinceNow:30*24*3600], NSHTTPCookieExpires,
                               sft_cookie, NSHTTPCookieValue,
                               nil];
    NSHTTPCookie *userInfoCookie = [NSHTTPCookie cookieWithProperties:cookieDic];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:userInfoCookie];
}

- (void)writeSecurityAuthSfytCookie {
    //    NSString *sfyt_cookie = @"hYTqh1GoibUXLtYobn_C3IHtonwg_hUsElkhnMlvE_JkwxzG9tYocsaOSVKRcjA7";
    SouFunUserBasicInfo *userinfo = [SouFunUserBasicInfo sharedSouFunUserBasicInfo];
    NSString *sfyt_cookie = [KFYTool safeString:userinfo.sfyt];
    NSDictionary *cookieDic = [NSDictionary dictionaryWithObjectsAndKeys:
                               @".fang.com", NSHTTPCookieDomain,
                               @"/", NSHTTPCookiePath,
                               @"sfyt",  NSHTTPCookieName,
                               [NSDate dateWithTimeIntervalSinceNow:30*24*3600], NSHTTPCookieExpires,
                               sfyt_cookie, NSHTTPCookieValue,
                               nil];
    NSHTTPCookie *userInfoCookie = [NSHTTPCookie cookieWithProperties:cookieDic];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:userInfoCookie];
}
/**
 3fang.com cookie
 */
- (void)write3FangSecurityAuthCookie {
    //    NSString *sft_cookie = @"152A452CE99AECD6A0786C2094F2CC08D6E72FA0B1293E8A30F653C83CD024808F6C1853F1168A09C4E12D978300390CFB7C1087022829177C26CCAFCE0D1F3B3B4483C6337B3A6DCF289A1145937071C519E31A5819507FAA923BB3D6666651";
    SouFunUserBasicInfo *userinfo = [SouFunUserBasicInfo sharedSouFunUserBasicInfo];
    NSString *sft_cookie = [KFYTool safeString:userinfo.sfut_cookie];

    NSDictionary *cookieDic = [NSDictionary dictionaryWithObjectsAndKeys:
                               @".3fang.com", NSHTTPCookieDomain,
                               @"/", NSHTTPCookiePath,
                               @"sfut",  NSHTTPCookieName,
                               [NSDate dateWithTimeIntervalSinceNow:30*24*3600], NSHTTPCookieExpires,
                               sft_cookie, NSHTTPCookieValue,
                               nil];
    NSHTTPCookie *userInfoCookie = [NSHTTPCookie cookieWithProperties:cookieDic];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:userInfoCookie];
}

/**
 3fang.com cookie
 */
- (void)write3fangSecurityAuthSfytCookie {

    //    NSString *sfyt_cookie = @"JOyoSJzf0hdmRTFKNYWx4qOGmcEt4wXcQ_TMPYHMyqNW-2DZmE2gVI1u5oNJYFX5waxlGjVMFBemZQClLPgk2A==";
    SouFunUserBasicInfo *userinfo = [SouFunUserBasicInfo sharedSouFunUserBasicInfo];
    NSString *sfyt_cookie = [KFYTool safeString:userinfo.sfyt];

    NSDictionary *cookieDic = [NSDictionary dictionaryWithObjectsAndKeys:
                               @".3fang.com", NSHTTPCookieDomain,
                               @"/", NSHTTPCookiePath,
                               @"sfyt",  NSHTTPCookieName,
                               [NSDate dateWithTimeIntervalSinceNow:30*24*3600], NSHTTPCookieExpires,
                               sfyt_cookie, NSHTTPCookieValue,
                               nil];
    NSHTTPCookie *userInfoCookie = [NSHTTPCookie cookieWithProperties:cookieDic];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:userInfoCookie];
}
- (BOOL)isBlankView:(UIView*)view { // YES：判断是否白屏
 
   Class wkCompositingView =NSClassFromString(@"WKCompositingView");
   if ([view isKindOfClass:[wkCompositingView class]]) {
       return NO;
       
   }
   for(UIView *subView in view.subviews) {
       
       if (![self isBlankView:subView]) {
           return NO;
       }
       
   }
    return YES;

}
-(void)dealloc
{
    [self unRegisterKVO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}
@end
