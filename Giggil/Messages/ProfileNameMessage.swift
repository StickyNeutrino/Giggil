//
//  ProfileNameMessage.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 9/15/20.
//  Copyright © 2020 Fitchmun. All rights reserved.
//

import Foundation
import Sodium

class ProfileNameMessage : GiggilMessage {
    required init?(orig: String) {
        super.init(orig: orig)
        
        if self.tid != PROFILE_NAME_MESSAGE {
            return nil
        }
    }
    
    init(object: Hash, name: String) {
        
        let claims: [claimKeys : claimValue] = [
            .object: .data(Data(object)),
            .name: .text(name),
            .rand: .data(Data(sodium.randomBytes.buf(length: 32)!))
        ]
        
        super.init(claims: claims)
    }
}

extension ProfileNameMessage {
    
    var object: Hash {
        guard case let .data(object) = claims[.object]
            else { fatalError() }
    
        return Bytes(object)
    }
    
    var name: String {
        guard case let .text(name) = claims[.name]
            else { fatalError() }
        
        return name
    }
    
}
