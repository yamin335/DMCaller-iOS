//
//  SSLCommerz.m
//  SSLCOMMERZ_SDKTest
//
//  Created by SSL Wireless on 7/18/16.
//  Copyright © 2016 SSL Wireless. All rights reserved.
//

#import "SSLCommerz.h"
#import "ECommerz_iOS.h"
#import "SSLCommerz_ViewController.h"
#import "MBProgressHUD.h"


@implementation SSLCommerz{
    NSString *_savedSessionKey;
    NSString *_savedStoreID;
    NSString *_savedStorePass;
    ECommerz_iOS * _sdkObject;
    NSString *  _currentSessionKey;
    NSString *  _currentStoreID;
    NSString *  _currentStorePassword;
    NSString *  _redirectGateWayURL;
    NSString *              _userTransactionID;
    NSString *              _amountToPay;

}

- (id) init {
    
    // Call superclass's initializer
    self = [super init];
    if( !self ) return nil;
    
    // observer to watch for transaction detail availablity.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transactionResultAvailable) name:@"TransactionResultAvailableNotification" object:nil];
    
    
    return self;
}


#pragma  mark - SDK Start.

-(void) startSSLCOMMERZinViewController:(UIViewController *)viewController withStoreID:(NSString *)storeID StorePassword:(NSString *)storePass AmountToPay:(NSString *) amount AmountCurrency:(NSString *)currency ApplicationUDID:(NSString *)appUniqueID appTransactionID: (NSString *)transactionID shouldRunInTestMode:(BOOL) isTestMode{
    
//    __block UIViewController *VC_inBlock = viewController;
    
    _userTransactionID = transactionID;
    _amountToPay = amount;
    //allocate SDK base object
    _sdkObject = [[ECommerz_iOS alloc] init];
    
    //define if sdk should run in test mode. Test mode will send request to sand box URLs
    [_sdkObject ShouldRunInTestMode:isTestMode];
    
    
    //start loading UI.
    [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    
    //API call to get gateway list.
//    [_sdkObject gatewayListForStoreID:storeID StorePassword:storePass totalAmount:amount paymentCurrency:currency TransactionID:transactionID AppID:appUniqueID SourceDetail:@"" SuccessURL:@"https://securepay.sslcommerz.com/gw/apps/result.php" FailURL:@"https://securepay.sslcommerz.com/gw/apps/result.php" CancelURL:@"https://securepay.sslcommerz.com/gw/apps/result.php" WithSuccess:^(BOOL isSuccess, NSArray *gateWayDataList, NSString *redirectGatewayURL, NSString *sessionKey) {
//        
//        
//        NSLog(@"success");
//        _savedSessionKey = sessionKey;
//        _savedStoreID = storeID;
//        _savedStorePass =storePass;
//        
//        dispatch_after(0, dispatch_get_main_queue(), ^(void){
//            // Do something...
//            [MBProgressHUD hideHUDForView:viewController.view animated:YES];
//        });
//        
//        //Create view controller to display gateway List.
//        SSLCommerz_ViewController *sdkVC = [[SSLCommerz_ViewController alloc] init];
//        
//        
//        //assign received data to viewController for displaying
//        sdkVC.sessionKey = sessionKey;
//        sdkVC.gatewayDetails = gateWayDataList;
//        
//        //Display View controller.
//        if (viewController.navigationController) {
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [viewController.navigationController pushViewController:sdkVC animated:YES];
//            });
//        }
//        else{
//            dispatch_async(dispatch_get_main_queue(), ^{
//               [viewController presentViewController:sdkVC animated:YES completion:^{
//                    
//                }];
//
//            });
//        }
//        
//        
//    } onFailure:^(NSString *error, int API_number) {
//        //Handle request failure.
//        NSLog(@"Failed");
//        dispatch_after(0, dispatch_get_main_queue(), ^(void){
//            // Do something...
//            [MBProgressHUD hideHUDForView:viewController.view animated:YES];
//        });    }];
    
    
    
   [ _sdkObject gatewayListForStoreID:storeID StorePassword:storePass totalAmount:amount paymentCurrency:currency TransactionID:transactionID AppID:appUniqueID SourceDetail:@""  withCustomerEmail:@""  CustomerName:@""  CustomerContactNumber:@""  CustomerFax:@""  CustomerAddress1:@""  CustomerAddress2:@""  CustomerCity:@""  CustomerState:@""  CustomerPostCode:@""  CustomerCountry:@""  WithShipmentInfo:@""  ShipmentAddress1:@""  ShipmentAddress2:@""  ShipmentCity:@""  ShipmentState:@""  SHipmentPostCode:@""  ShipmentCountry:@""  WithOptionalValueA:@""  OptionalValueB:@""  OptionalValueC:@""  OptionalValueD:@""  SuccessURL:@"https://securepay.sslcommerz.com/gw/apps/result.php" FailURL:@"https://securepay.sslcommerz.com/gw/apps/result.php" CancelURL:@"https://securepay.sslcommerz.com/gw/apps/result.php" WithSuccess:^(BOOL isSuccess, NSArray *gateWayDataList, NSString *redirectGatewayURL, NSString *sessionKey) {
        
        
        NSLog(@"success");
        _savedSessionKey = sessionKey;
        _savedStoreID = storeID;
        _savedStorePass =storePass;
        
        dispatch_after(0, dispatch_get_main_queue(), ^(void){
            // Do something...
            [MBProgressHUD hideHUDForView:viewController.view animated:YES];
        });
        
        //Create view controller to display gateway List.
        SSLCommerz_ViewController *sdkVC = [[SSLCommerz_ViewController alloc] init];
        
        
        //assign received data to viewController for displaying
        sdkVC.sessionKey = sessionKey;
        sdkVC.gatewayDetails = gateWayDataList;
        
        //Display View controller.
        if (viewController.navigationController) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [viewController.navigationController pushViewController:sdkVC animated:YES];
            });
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [viewController presentViewController:sdkVC animated:YES completion:^{
                    
                }];
                
            });
        }
        
        
    } onFailure:^(NSString *error, int API_number) {
        //Handle request failure.
        NSLog(@"Failed");
        dispatch_after(0, dispatch_get_main_queue(), ^(void){
            // Do something...
            [MBProgressHUD hideHUDForView:viewController.view animated:YES];
        });    }];
    
}

-(void) startSSLCOMMERZinViewController:(UIViewController *)viewController withStoreID:(NSString *)storeID StorePassword:(NSString *)storePass AmountToPay:(NSString *) amount AmountCurrency:(NSString *)currency ApplicationBundleID:(NSString *)bundleID appTransactionID: (NSString *)transactionID SourceDetail:(NSString *)sourceDetails withCustomerEmail: (NSString *)customerEmail CustomerName:(NSString *)customerName CustomerContactNumber:(NSString *)customerContactNumber CustomerFax:(NSString *)customerFax CustomerAddress1:(NSString *)customerAddress1 CustomerAddress2:(NSString *)customerAddress2 CustomerCity:(NSString *)customerCity CustomerState:(NSString *)customerState CustomerPostCode:(NSString *)customerPostCode CustomerCountry:(NSString *)customerCountry WithShipmentInfo:(NSString *)shipmentName ShipmentAddress1:(NSString *) shipmentAddress1 ShipmentAddress2:(NSString *) shipmentAddress2 ShipmentCity:(NSString *) shipmentCity ShipmentState:(NSString *)shipmentState SHipmentPostCode:(NSString *)shipmentPostCode ShipmentCountry:(NSString *)shipmentCountry WithOptionalValueA:(NSString *)optionalValueA OptionalValueB:(NSString *)optionalValueB OptionalValueC:(NSString *)optionalValueC OptionalValueD:(NSString *)optionalValueD shouldRunInTestMode:(BOOL) isTestMode{
    
    //    __block UIViewController *VC_inBlock = viewController;
    
    _userTransactionID = transactionID;
    _amountToPay = amount;
    //allocate SDK base object
    _sdkObject = [[ECommerz_iOS alloc] init];
    
    //define if sdk should run in test mode. Test mode will send request to sand box URLs
    [_sdkObject ShouldRunInTestMode:isTestMode];
    
    
    //start loading UI.
    [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    
        
    
    [ _sdkObject gatewayListForStoreID:storeID StorePassword:storePass totalAmount:amount paymentCurrency:currency TransactionID:transactionID AppID:bundleID SourceDetail:sourceDetails  withCustomerEmail:customerEmail  CustomerName:customerName  CustomerContactNumber:customerContactNumber  CustomerFax:customerFax  CustomerAddress1:customerAddress1  CustomerAddress2:customerAddress2  CustomerCity:customerCity  CustomerState:customerState  CustomerPostCode:customerPostCode  CustomerCountry:customerCountry  WithShipmentInfo:shipmentName  ShipmentAddress1:shipmentAddress1  ShipmentAddress2:shipmentAddress2  ShipmentCity:shipmentCity  ShipmentState:shipmentState SHipmentPostCode:shipmentPostCode  ShipmentCountry:shipmentCountry  WithOptionalValueA:optionalValueA  OptionalValueB:optionalValueB  OptionalValueC:optionalValueC  OptionalValueD:optionalValueD  SuccessURL:@"https://securepay.sslcommerz.com/gw/apps/result.php" FailURL:@"https://securepay.sslcommerz.com/gw/apps/result.php" CancelURL:@"https://securepay.sslcommerz.com/gw/apps/result.php" WithSuccess:^(BOOL isSuccess, NSArray *gateWayDataList, NSString *redirectGatewayURL, NSString *sessionKey) {
        
        
        NSLog(@"success");
        _savedSessionKey = sessionKey;
        _savedStoreID = storeID;
        _savedStorePass =storePass;
        
        dispatch_after(0, dispatch_get_main_queue(), ^(void){
            // Do something...
            [MBProgressHUD hideHUDForView:viewController.view animated:YES];
        });
        
        //Create view controller to display gateway List.
        SSLCommerz_ViewController *sdkVC = [[SSLCommerz_ViewController alloc] init];
        
        
        //assign received data to viewController for displaying
        sdkVC.sessionKey = sessionKey;
        sdkVC.gatewayDetails = gateWayDataList;
        
        //Display View controller.
        if (viewController.navigationController) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [viewController.navigationController pushViewController:sdkVC animated:YES];
            });
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [viewController presentViewController:sdkVC animated:YES completion:^{
                    
                }];
                
            });
        }
        
        
    } onFailure:^(NSString *error, int API_number) {
        //Handle request failure.
        NSLog(@"Failed");
        dispatch_after(0, dispatch_get_main_queue(), ^(void){
            // Do something...
            [MBProgressHUD hideHUDForView:viewController.view animated:YES];
            
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Transaction Unsuccessful"
                                          message:error                                  preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
            
            
            [alert addAction:ok];
            
            [viewController presentViewController:alert animated:YES completion:nil];
        });
    
    }];
    
}

-(void)transactionResultAvailable{
    
    //API Call for fetching transaction details
    [_sdkObject getTransactionDetailsForSessionID:_savedSessionKey StoreID:_savedStoreID StorePassword:_savedStorePass WithSuccess:^(BOOL isSuccess, TransactionDetails *details) {
        
        if ([details.amount isEqualToString:_amountToPay] && [details.tran_id isEqualToString:_userTransactionID]) {
            [self.delegate transactionSuccessfulWithCompletionhandler:details];

        }
        else{
            [self.delegate transactionSuccessfulWithCompletionhandler:nil];

        }
        
        //call delegate if transaction details successfully received.
        
    } onFailure:^(NSString *error, int API_number) {
        
    }];
}



-(void)dealloc{
    //remove observer upon dealloc
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TransactionResultAvailableNotification" object:nil];

}

@end
