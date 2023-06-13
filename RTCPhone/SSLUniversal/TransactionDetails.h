//
//  TransactionDetails.h
//  ECommerz_iOS
//
//  Created by SSL Wireless on 7/17/16.
//  Copyright © 2016 SSL Wireless. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransactionDetails : NSObject

@property (nonatomic, strong) NSString *status;//": "VALIDATED",
@property (nonatomic, strong) NSString *sessionkey;//": "99A0E42CF77FB200555490FF4818365D",
@property (nonatomic, strong) NSString *tran_date;//": "2016-07-13 17:19:05",
@property (nonatomic, strong) NSString *tran_id;//": "123456",
@property (nonatomic, strong) NSString *val_id;//": "1607131720331ciBAkrFoevskkX",
@property (nonatomic, strong) NSString *amount;//": "12.00",
@property (nonatomic, strong) NSString *store_amount;//": "11.64",
@property (nonatomic, strong) NSString *bank_tran_id;//": "160713172033ULWXESej0ACthXb",
@property (nonatomic, strong) NSString *card_type;//": "VISA-Dutch Bangla",
@property (nonatomic, strong) NSString *card_no;//": "",
@property (nonatomic, strong) NSString *card_issuer;//": "",
@property (nonatomic, strong) NSString *card_brand;//": "",
@property (nonatomic, strong) NSString *card_issuer_country;//": "",
@property (nonatomic, strong) NSString *card_issuer_country_code;//": "",
@property (nonatomic, strong) NSString *currency_type;//": "BDT",
@property (nonatomic, strong) NSString *currency_amount;//": "12.00",
@property (nonatomic, strong) NSString *currency_rate;//": "1.00",
@property (nonatomic, strong) NSString *base_fair;//": "0.00",
@property (nonatomic, strong) NSString *value_a;//": "",
@property (nonatomic, strong) NSString *value_b;//": "",
@property (nonatomic, strong) NSString *value_c;//": "",
@property (nonatomic, strong) NSString *value_d;//": "",
@property (nonatomic, strong) NSString *risk_title;//": "Safe",
@property (nonatomic, strong) NSString *risk_level;//": "0",
@property (nonatomic, strong) NSString *APIConnect;//": "DONE",
@property (nonatomic, strong) NSString *validated_on;//": "2016-07-13 17:25:00",
@property (nonatomic, strong) NSString *gw_version;//": "3.01"

@end
