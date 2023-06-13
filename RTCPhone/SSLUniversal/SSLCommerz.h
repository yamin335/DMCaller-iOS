//
//  SSLCommerz.h
//  SSLCOMMERZ_SDKTest
//
//  Created by SSL Wireless on 7/18/16.
//  Copyright © 2016 SSL Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ECommerz_iOS.h"
//#import "TransactionDetails.h"

@protocol SSLCommerzDelegate <NSObject>
@required

- (void) transactionSuccessfulWithCompletionhandler:(TransactionDetails *)transactionData ;

@end

@interface SSLCommerz : NSObject

{
    // Delegate to respond back
    id <SSLCommerzDelegate> _delegate;
    
}
@property (nonatomic,strong) id delegate;

- (id) init;

-(void) startSSLCOMMERZinViewController:(UIViewController *)viewController withStoreID:(NSString *)storeID StorePassword:(NSString *)storePass AmountToPay:(NSString *) amount AmountCurrency:(NSString *)currency ApplicationUDID:(NSString *)appUniqueID appTransactionID: (NSString *)transactionID shouldRunInTestMode:(BOOL) isTestMode;

-(void) startSSLCOMMERZinViewController:(UIViewController *)viewController withStoreID:(NSString *)storeID StorePassword:(NSString *)storePass AmountToPay:(NSString *) amount AmountCurrency:(NSString *)currency ApplicationBundleID:(NSString *)bundleID appTransactionID: (NSString *)transactionID SourceDetail:(NSString *)sourceDetails withCustomerEmail: (NSString *)customerEmail CustomerName:(NSString *)customerName CustomerContactNumber:(NSString *)customerContactNumber CustomerFax:(NSString *)customerFax CustomerAddress1:(NSString *)customerAddress1 CustomerAddress2:(NSString *)customerAddress2 CustomerCity:(NSString *)customerCity CustomerState:(NSString *)customerState CustomerPostCode:(NSString *)customerPostCode CustomerCountry:(NSString *)customerCountry WithShipmentInfo:(NSString *)shipmentName ShipmentAddress1:(NSString *) shipmentAddress1 ShipmentAddress2:(NSString *) shipmentAddress2 ShipmentCity:(NSString *) shipmentCity ShipmentState:(NSString *)shipmentState SHipmentPostCode:(NSString *)shipmentPostCode ShipmentCountry:(NSString *)shipmentCountry WithOptionalValueA:(NSString *)optionalValueA OptionalValueB:(NSString *)optionalValueB OptionalValueC:(NSString *)optionalValueC OptionalValueD:(NSString *)optionalValueD shouldRunInTestMode:(BOOL) isTestMode;

@end
