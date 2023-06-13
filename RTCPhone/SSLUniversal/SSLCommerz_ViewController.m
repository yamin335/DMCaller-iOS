//
//  SSLCommerz_ViewController.m
//  SSLCOMMERZ_SDKTest
//
//  Created by SSL Wireless on 7/18/16.
//  Copyright © 2016 SSL Wireless. All rights reserved.
//

#import "SSLCommerz_ViewController.h"
#import "GatewayTableViewCell.h"
#import "Gateway.h"
#import "UIImageView+AFNetworking.h"
#import "MBProgressHUD.h"

#define TRANSACTION_END_URL_SANDBOX     @"https://sandbox.sslcommerz.com/gwprocess/v3/api.php"
#define TRANSACTION_END_URL             @"https://securepay.sslcommerz.com/gw/apps/result.php"


@interface SSLCommerz_ViewController (){
    NSArray * _gatewayList;
    UIWindow * _mainWindow;
}

@end

@implementation SSLCommerz_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    _sdkObject = [[ECommerz_iOS alloc] init];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
   _mainWindow = [UIApplication sharedApplication].delegate.window;
    CGRect WebViewContainerFrame = self.SSLCOMMERZ_WebViewContainer.frame;
    WebViewContainerFrame.origin.y+= _mainWindow.frame.size.height;
    self.SSLCOMMERZ_WebViewContainer.frame = WebViewContainerFrame;
    self.webviewContainerTopSpaceConstratint.constant = _mainWindow.frame.size.height+200;
    [self.view layoutIfNeeded];
    
}







#pragma mark - tableview delegate methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.gatewayDetails.count+1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Configure the cell...

    static NSString *CellIdentifier = @"Cell";
    static NSString *gatewayCellIdentifier = @"gatewayCell";
    
    GatewayTableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:gatewayCellIdentifier];
    
    if (!cell2) {
        [tableView registerNib:[UINib nibWithNibName:@"GatewayTableViewCell" bundle:nil] forCellReuseIdentifier:gatewayCellIdentifier ];
        cell2 = [tableView dequeueReusableCellWithIdentifier:gatewayCellIdentifier];
    }
    UITableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell1 == nil) {
        cell1 = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:CellIdentifier];
    }
    
    return cell2;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(GatewayTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == self.gatewayDetails.count) {
//        cell.gatewayNameLabel.hidden = YES;
//        cell.gatewayLogoImageview.hidden = YES;
        cell.contentView.hidden = YES;
        return;
    }
    cell.contentView.hidden = NO;

    Gateway *gatewayDetailsToDisplay = [self.gatewayDetails objectAtIndex:indexPath.section];
    cell.gatewayNameLabel.text = gatewayDetailsToDisplay.gatewayTitle;
    [cell.gatewayLogoImageview setImageWithURL:[NSURL URLWithString:gatewayDetailsToDisplay.gatewayLogoURL]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Gateway *gatewayDetailsToDisplay = [self.gatewayDetails objectAtIndex:indexPath.section];

//    self.SSLCOMMERZ_WebViewContainer.hidden = NO;
    [self.SSLCOMMERZWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    [self toggleWebview:YES];
    gatewayDetailsToDisplay.gatewayRedirectURL = [gatewayDetailsToDisplay.gatewayRedirectURL stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSURL *url = [NSURL URLWithString:gatewayDetailsToDisplay.gatewayRedirectURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [self.SSLCOMMERZWebview setScalesPageToFit:YES];
//    [self.SSLCOMMERZWebview stopLoading];

    [self.SSLCOMMERZWebview loadRequest:request];
    NSLog(@"Requested loaded: %@", url.absoluteString);

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    
    return view;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    
    return view;
}

-(CGFloat ) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}
-(CGFloat ) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}


#pragma mark - webview Delegate methods


- (void)webViewDidStartLoad:(UIWebView *)webView{
    dispatch_after(0, dispatch_get_main_queue(), ^(void){
        // Do something...
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    NSURL * myRequestedUrl= [webView.request mainDocumentURL];
    NSLog(@"Requested url: %@", myRequestedUrl);
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    dispatch_after(0, dispatch_get_main_queue(), ^(void){
        // Do something...
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    NSURL* endPointURL = [self.SSLCOMMERZWebview.request mainDocumentURL];
    NSLog(@"%@", endPointURL.absoluteString);
    if ([endPointURL.absoluteString isEqualToString:@"https://securepay.sslcommerz.com/gw/apps/result.php"]) {
        NSLog(@"");
        [self.SSLCOMMERZWebview stopLoading];
        [self toggleWebview:NO];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"TransactionResultAvailableNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TransactionResultAvailableNotification" object:nil userInfo:nil];
        [self closeSDKViewController];
    }

}

#pragma mark - webview Toggle

-(void)toggleWebview:(BOOL) isON{
    __block   CGRect webviewContainerFrame = self.SSLCOMMERZ_WebViewContainer.frame;
    if (isON) {
        [UIView animateWithDuration:0.3 animations:^{
            
            self.webviewContainerTopSpaceConstratint.constant = 0;//_mainWindow.frame.size.height;
            [self.view layoutIfNeeded];
        }];
    }
    
    else{
        [UIView animateWithDuration:0.3 animations:^{
            
            self.webviewContainerTopSpaceConstratint.constant = _mainWindow.frame.size.height+200;
            [self.view layoutIfNeeded];
            
        }];
    }
}

#pragma mark - Button Actions


- (IBAction)closeButtonTapped:(id)sender {
     [self toggleWebview:NO];
}

- (IBAction)sdkCloseTapped:(id)sender {
    
    [self closeSDKViewController];
    
}

-(void)closeSDKViewController{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
