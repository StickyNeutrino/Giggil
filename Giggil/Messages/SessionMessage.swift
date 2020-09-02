//
//  SessionMessage.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 8/31/20.
//  Copyright © 2020 Fitchmun. All rights reserved.
//

import Foundation
import Sodium

class SessionMessage : GiggilMessage {
    override init?(orig: String) {
        super.init(orig: orig)
        
        if self.tid != SESSION_MESSAGE {
            return nil
        }
    }
    
    init(keys: Sign.KeyPair) {
        
        let claims : [claimKeys : claimValue] = [
            .key : .data(Data(keys.publicKey))
        ]
        
        super.init(claims: claims)
    }
}

extension SessionMessage {
    
    var key : Bytes {
        get {
            guard case let .data(mainKey) = claims[.key]
                else { fatalError() }
            
            return Bytes(mainKey)
        }
    }
    
    func verify(_ message: GiggilMessage) -> Bool {
        return message.verify(key)
    }
}
