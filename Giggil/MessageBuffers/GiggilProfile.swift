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
            if filter(message) != nil {
                queue.async {
                    self.messages[message.id] = message
                }
                
                if let revoke = message as? RevokeMessage {
                    self.revoked[ revoke.prev ] = true
                }
                
                if filter(message) != nil {
                    self.handle(message: message)
                }
            }
        
    }
}

extension GiggilProfile: messageFilter {
    func filter(_ message: GiggilMessage) -> GiggilMessage? {
        queue.sync {
            if revoked[message.id] ?? false { return nil}
            if session.verify(message) { return message }
            return nil
        }
    }
}

extension GiggilProfile {
    
    var name: String {
        queue.sync {
            
            var names = [String]()
            
            for message in messages.values {
                if revoked[message.id] == true {
                    continue
                }
                
                if let nameMessage = message as? ProfileNameMessage {
                    names.append(nameMessage.name)
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
