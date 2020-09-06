//
//  GiggilSession.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 10/23/19.
//  Copyright © 2019 Fitchmun. All rights reserved.
//

import Foundation

class GiggilProfile: MessageBuffer {
    
    let session: SessionMessage
    
    let queue = DispatchQueue(label: "Giggil.Session.queue")
    
    var messages = [Hash: GiggilMessage]()
    
    init(_ session: SessionMessage) {
        self.session = session
    }
    
    required init?(seed: GiggilMessage) {
        if seed.tid != SESSION_MESSAGE {
            return nil
        }
        
        self.session = SessionMessage(orig: seed.original)!
    }
    
    func members() -> [GiggilMessage] {
        queue.sync {
            return Array(self.messages.values)
        }
    }
    
    func listener(message: GiggilMessage, hash: Hash?) {
        queue.async {
            if self.session.verify(message) {
                self.handle(message: message, peer: hash)
                
                self.messages[message.id] = message
                
                switch message.tid {
                case REVOKE_MESSAGE:
                    guard case let .data(revoked) = message.claims[.prev]
                        else { fatalError() }
                    
                    self.messages[Bytes(revoked)] = nil
                default:
                    break
                }
            }
        }
    }
}


import Sodium

extension GiggilProfile {
    
    var name: String {
        queue.sync {
            
            var names = [String]()
            
            for message in messages.values {
                if message.tid == PROFILE_NAME_MESSAGE {
                    if case let .text(name) = message.claims[.name] {
                        names.append(name)
                    }
                }
            }
            
            return names.max() ?? "Unknown User"
        }
    }
}