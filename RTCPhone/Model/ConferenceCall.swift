//
//  ConferenceCall.swift
//  RTCPhone
//
//  Created by Md. Yamin on 5/24/22.
//  Copyright © 2022 Mamun Ar Rashid. All rights reserved.
//

import Foundation

struct ConferenceCall {
    var name: String = ""
    var mobile: String = ""
    var call: Optional<OpaquePointer>? = nil
}
