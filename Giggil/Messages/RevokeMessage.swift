//
//  RevokeMessage.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 9/15/20.
//  Copyright © 2020 Fitchmun. All rights reserved.
//

import Foundation
import Sodium

class RevokeMessage : GiggilMessage {
    required init?(orig: String) {
        super.init(orig: orig)
        
        if self.tid != REVOKE_MESSAGE {
            return nil
        }
    }
        
    init(object: Hash, prev: Hash) {
        
        let claims : [claimKeys : claimValue] = [
            .prev : .data(Data(prev)),
            .object : .data(Data(object))
        ]
        
        super.init(claims: claims)
    }
}

extension RevokeMessage {
    var prev : Bytes {
        get {
            guard case let .data(prev) = claims[.prev]
                else { fatalError() }
            
            return Bytes(prev)
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
