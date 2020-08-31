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
        
        if self.id != SESSION_MESSAGE {
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
