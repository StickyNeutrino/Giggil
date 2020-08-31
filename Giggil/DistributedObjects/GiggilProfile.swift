//
//  GiggilSession.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 10/23/19.
//  Copyright © 2019 Fitchmun. All rights reserved.
//

import Foundation

class GiggilProfile: DistributedObject {
    
    let session: GiggilMessage
    
    let queue = DispatchQueue(label: "Giggil.Session.queue")
    
    var messages = [Hash: GiggilMessage]()
    
    init(_ session: SessionMessage) {
        self.session = session
    }
    
    required init?(seed: GiggilMessage) {
        if seed.tid != SESSION_MESSAGE {
            return nil
        }
        
        self.session = seed
    }
    
    func add(_ newMessages: [GiggilMessage]) {
        queue.async {
            for message in newMessages {
                
                if !self.verify(message) {
                    continue
                } else {
                    self.messages[message.id] = message
                }
                
                switch message.tid {
                case REVOKE_MESSAGE:
                    guard case let .data(revoked) = message.claims[.prev]
                        else { fatalError() }
                    
                    self.messages[Bytes(revoked)] = nil
                default:
                    continue
                }
            }
        }
    }
    
    func members() -> [GiggilMessage] {
        queue.sync {
            return Array(self.messages.values)
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
    
    func verify(_ message: GiggilMessage) -> Bool {
        guard case let .data(mainKey) = self.session.claims[.key]
            else { fatalError() }
        
        return message.verify(Bytes(mainKey))
    }
}
