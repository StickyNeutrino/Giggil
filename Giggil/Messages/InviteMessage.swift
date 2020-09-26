//
//  InviteMessage.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 9/20/20.
//  Copyright © 2020 Fitchmun. All rights reserved.
//

import Foundation
import Sodium

let INVITE_CLAIMS: [claimKeys] = [
    .object,
    .sender,
    .next,
]

let INVITE_MESSAGE = tidCalc(claims: INVITE_CLAIMS)!

class InviteMessage : GiggilMessage {
    required init?(orig: String) {
        super.init(orig: orig)
        
        if self.tid != INVITE_MESSAGE {
            return nil
        }
    }
    
    init(object: Hash, sender: Hash, next: Hash) {
        let claims: [claimKeys : claimValue] = [
                  .object: .data(Data(object)),
                  .sender: .data(Data(sender)),
                  .next: .data(Data(next))
              ]
              
        super.init(claims: claims)
    }
}

extension InviteMessage {
    
    var object: Hash {
        guard case let .data(object) = claims[.object]
            else { fatalError() }
    
        return Bytes(object)
    }
    
    var sender: Hash {
        guard case let .data(object) = claims[.sender]
            else { fatalError() }
    
        return Bytes(object)
    }
    
    var next: Hash {
        guard case let .data(object) = claims[.next]
            else { fatalError() }
    
        return Bytes(object)
    }
}
