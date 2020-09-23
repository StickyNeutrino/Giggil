//
//  TextMessage.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 9/15/20.
//  Copyright © 2020 Fitchmun. All rights reserved.
//

import Foundation
import Sodium

class TextMessage : GiggilMessage {
    required init?(orig: String) {
        super.init(orig: orig)
        
        if self.tid != TEXT_MESSAGE {
            return nil
        }
    }
    
    init(sender: Hash, text: String) {
        let claims: [claimKeys : claimValue] = [
                  .sender: .data(Data(sender)),
                  .text: .text(text),
                  .sent: .date(Date())
              ]
              
        super.init(claims: claims)
    }
}

extension TextMessage {
    
    var sender: Hash {
        guard case let .data(object) = claims[.sender]
            else { fatalError() }
    
        return Bytes(object)
    }
    
    var text: String {
        guard case let .text(text) = claims[.key]
            else { fatalError() }
        
        return text
    }
    
    var sent: Date {
        guard case let .date(sent) = claims[.sent]
            else { fatalError() }
        
        return sent
    }
}
