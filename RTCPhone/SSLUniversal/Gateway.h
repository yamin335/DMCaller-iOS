//
//  Gateway.h
//  ECommerz_iOS
//
//  Created by SSL Wireless on 7/17/16.
//  Copyright © 2016 SSL Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Gateway : NSObject


    //                         "name": "AMEX",
    //                         "type": "amex",
    //                         "logo": "https://sandbox.sslcommerz.com/gwprocess/v3/image/gw/amex.png",
    //                         "gw": "amexcard"
    //                     }

@property (nonatomic, strong) NSString *gatewayTitle;
@property (nonatomic, strong) NSString *gatewayType;
@property (nonatomic, strong) NSString *gatewayLogoURL;
@property (nonatomic, strong) NSString *gatewayName;
@property (nonatomic, strong) NSString *gatewayRedirectURL;


@end
