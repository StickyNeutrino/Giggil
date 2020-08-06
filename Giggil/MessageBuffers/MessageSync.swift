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

class MessageSync {
    
    var messages = [GiggilMessage]()
    
    init(lc: LocalChat){

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else { return }
        
        if let myID = appDelegate.activeSession?.profile.session.id {
        
            lc.add{ (message, _) in
                if message.tid != TEXT_MESSAGE {
                    return
                }
                
                guard case let .data(id) = message.claims[.object]
                    else { return }
                
                if Bytes(id) == myID {
                    self.messages.append(message)
                }
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (_) in
            self.prune()
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
