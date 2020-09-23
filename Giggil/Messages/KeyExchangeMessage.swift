//
//  KeyExchangeMessage.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 9/15/20.
//  Copyright © 2020 Fitchmun. All rights reserved.
//

import Foundation
import Sodium

class KeyExchangeMessage : GiggilMessage {
    required init?(orig: String) {
        super.init(orig: orig)
        
        if self.tid != KEY_EXCHANGE_MESSAGE {
            return nil
        }
    }
    
    init(object: Hash, keys: Sign.KeyPair) {
        
        let claims : [claimKeys : claimValue] = [
            .key : .data(Data(keys.publicKey)),
            .object : .data(Data(object))
        ]
        
        super.init(claims: claims)
    }
}

extension KeyExchangeMessage {
    var key : Bytes {
        get {
            guard case let .data(mainKey) = claims[.key]
                else { fatalError() }
            
            return Bytes(mainKey)
        }
    }
    
    var object : Bytes {
        get {
            guard case let .data(object) = claims[.object]
                else { fatalError() }
            
            return Bytes(object)
        }
    }
}
