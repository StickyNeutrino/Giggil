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
    
    var revoked = [Hash: Bool]()
    
    init(_ session: SessionMessage) {
        self.session = session
    }
    
    required init?(seed: GiggilMessage) {
        guard let session = SessionMessage(orig: seed.original)
            else { return nil }
        
        self.session = session
    }
    
    func members() -> [GiggilMessage] {
        queue.sync {
            return Array(self.messages.values)
        }
    }
    
    func listener(_ message: GiggilMessage) {
        queue.async {
            if self.session.verify(message) {
                self.handle(message: message)
                
                self.messages[message.id] = message
                
                switch message.tid {
                case REVOKE_MESSAGE:
                    guard case let .data(revoked) = message.claims[.prev]
                        else { fatalError() }
                    
                    self.revoked[Bytes(revoked)] = true
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
                if revoked[message.id] == true {
                    continue
                }
                
                if message.tid == PROFILE_NAME_MESSAGE {
                    if case let .text(name) = message.claims[.name] {
                        names.append(name)
                    }
                }
            }
            
            return names.max() ?? "Unknown User"
        }
    }
    
    var id: Hash {
        queue.sync {
            session.id
        }
    }
}
