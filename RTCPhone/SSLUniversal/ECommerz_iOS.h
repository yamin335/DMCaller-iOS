//
//  ECommerz_iOS.h
//  ECommerz_iOS
//
//  Created by SSL Wireless on 7/17/16.
//  Copyright © 2016 SSL Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TransactionDetails.h"


@interface ECommerz_iOS : NSObject



typedef void (^Failure)(NSString *error, int API_number);

typedef void (^API_completionHandler)(BOOL isSuccess, NSArray* gateWayDataList, NSString *redirectGatewayURL, NSString *sessionKey);

typedef void (^API_transactionDetailsCompletionHandler)(BOOL isSuccess, TransactionDetails* details);

//-(void) startPaymentGatewayInView:(UIView*)hostView  StoreID:(NSString *)storeID StorePassword:(NSString *)storePassword TotalAmount:(NSString *)amount PaymentCurrency:(NSString *)currency TransactionID:(NSString *)transactionID shouldOpenInTestMode:(BOOL) isTest;

-(void)ShouldRunInTestMode:(BOOL) isTestMode;

-(void)gatewayListForStoreID:(NSString *)storeID StorePassword:(NSString*) storePassword totalAmount:(NSString *)amount paymentCurrency:(NSString *)currency TransactionID:(NSString *)transactionID AppID:(NSString *)appID SourceDetail:(NSString *)sourceDetails SuccessURL:(NSString *)successURL FailURL:(NSString *)failURL CancelURL:(NSString *)cancelURL WithSuccess:(API_completionHandler)successCompletionHandler onFailure:(Failure)FailCompletetionHeandler;

-(void)gatewayListForStoreID:(NSString *)storeID StorePassword:(NSString*) storePassword totalAmount:(NSString *)amount paymentCurrency:(NSString *)currency TransactionID:(NSString *)transactionID AppID:(NSString *)appID SourceDetail:(NSString *)sourceDetails withCustomerEmail: (NSString *)customerEmail CustomerName:(NSString *)customerName CustomerContactNumber:(NSString *)customerContactNumber CustomerFax:(NSString *)customerFax CustomerAddress1:(NSString *)customerAddress1 CustomerAddress2:(NSString *)customerAddress2 CustomerCity:(NSString *)customerCity CustomerState:(NSString *)customerState CustomerPostCode:(NSString *)customerPostCode CustomerCountry:(NSString *)customerCountry WithShipmentInfo:(NSString *)shipmentName ShipmentAddress1:(NSString *) shipmentAddress1 ShipmentAddress2:(NSString *) shipmentAddress2 ShipmentCity:(NSString *) shipmentCity ShipmentState:(NSString *)shipmentState SHipmentPostCode:(NSString *)shipmentPostCode ShipmentCountry:(NSString *)shipmentCountry WithOptionalValueA:(NSString *)optionalValueA OptionalValueB:(NSString *)optionalValueB OptionalValueC:(NSString *)optionalValueC OptionalValueD:(NSString *)optionalValueD SuccessURL:(NSString *)successURL FailURL:(NSString *)failURL CancelURL:(NSString *)cancelURL WithSuccess:(API_completionHandler)successCompletionHandler onFailure:(Failure)FailCompletetionHeandler;



-(void)getTransactionDetailsForSessionID: (NSString *)sessionKey StoreID:(NSString *)storeID StorePassword: (NSString *)storePassword WithSuccess:(API_transactionDetailsCompletionHandler)successCompletionHandler onFailure:(Failure)FailCompletetionHeandler;






@end
