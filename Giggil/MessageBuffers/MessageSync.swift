//
//  MessageSync.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 12/31/19.
//  Copyright © 2019 Fitchmun. All rights reserved.
//

import Foundation
import UIKit
import Sodium

class MessageSync : MessageListener {
    
    var messages = [GiggilMessage]()
    
    var listenID = Bytes()
    
    init(myID: Hash) {
        
        listenID = myID
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] (_) in
            self?.prune()
        }
    }
    
    func listener(_ message: GiggilMessage) {
        if message.tid != TEXT_MESSAGE {
            return
        }
        
        guard case let .data(id) = message.claims[.object]
            else { return }
        
        if Bytes(id) == listenID {
            self.messages.append(message)
        }
    }

    
    func prune() {
        messages = messages.filter { (message) -> Bool in
            guard case let .date(sent) = message.claims[.sent]
                else { return false }
            
            return sent.timeIntervalSinceNow > TimeInterval(-1 * 10 * 60)
        }
    }
    
}
