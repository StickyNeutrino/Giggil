//
//  CharterMessage.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 9/15/20.
//  Copyright © 2020 Fitchmun. All rights reserved.
//

import Foundation
import Sodium

let CHARTER_CLAIMS: [claimKeys] = [
    .prev,
    .rand
]

let CHARTER_MESSAGE = tidCalc(claims: CHARTER_CLAIMS)!

class CharterMessage : GiggilMessage {
    override init?(orig: String) {
        super.init(orig: orig)
        
        if self.tid != CHARTER_MESSAGE {
            return nil
        }
    }
    
    init(owner: SessionMessage) {
        
        let claims : [claimKeys : claimValue] = [
            .prev : .data(Data(owner.id)),
            .rand : .data(Data(sodium.randomBytes.buf(length: 32)!))
        ]
        
        super.init(claims: claims)
    }
}

extension CharterMessage {
    
    var owner : Bytes {
        get {
            guard case let .data(mainKey) = claims[.prev]
                else { fatalError() }
            
            return Bytes(mainKey)
        }
    }
}
