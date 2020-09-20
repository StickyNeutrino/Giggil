//
//  GiggilGroup.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 9/15/20.
//  Copyright © 2020 Fitchmun. All rights reserved.
//

import Foundation

class GiggilGroup: MessageBuffer, MessageListener {
    
    let charter: CharterMessage
    
    var messages: [Hash: (messsage: GiggilMessage?, revoked: Bool)] = [:]
    
    let queue = DispatchQueue(label: "Giggil.Group.queue")
    
    init(_ charter: CharterMessage) {
        
        self.charter = charter
        
        super.init()
    }
    
    func listener(_ message: GiggilMessage) {
        queue.async {
            switch message.tid {
            case SESSION_MESSAGE:
                self.messages[message.id] = (message, false)
            case REVOKE_MESSAGE:
                self.revoke(message)
            default:
                break
                
            }
        }
    }
    
    private func checkObject(_ message: GiggilMessage) -> Bool {
        guard case let .data(object) = message.claims[.object]
            else { return false }
        
        return Hash(object) == charter.id
    }
    
    private func checkSender(_ message: GiggilMessage) -> Bool {
        
        guard case let .data(sender) = message.claims[.sender]
            else { return false }
        
        if let session = SessionMessage(orig: messages[Hash(sender)]?.messsage?.original ?? "") {
            return session.verify(message)
        }
        
        return false
    }
    
    private func revoke(_ message: GiggilMessage) {
        if !checkObject(message) { return }
        if !checkSender(message) { return }
        
        guard case let .data(revoked) = message.claims[.prev]
            else { fatalError() }
        
        self.messages[Hash(revoked)]?.revoked = true
    }
    
    private func canSend(_ ID: Hash) -> Bool {
        
        let invites = messages.compactMap { (arg0) -> InviteMessage? in
            
            let (messsage, revoked) = arg0.value
            
            if revoked { return nil }
            
            if let invite = messsage as? InviteMessage {
                 return invite.next == ID ? invite : nil
            }
            
            return nil
            
        }
    
        for invite in invites {
            if canSend( invite.sender ) {
                return true
            }
            
            if invite.sender == charter.owner {
                return true
            }
        }
        
        return false
    }
    
    private func invite(_ message: GiggilMessage) {
        
    }
}
/*
 Charter:
    Owner: hash
    rand: hash
  
 Invite:
    object: hash
    sender: hash
    to: hash
 
 GroupName:
    object: hash
    signer: hash
    name: String
 
 groupText:
    object: hash
    sender: hash
    text: String
    sent: Date
 
 groupRevoke:
    object: hash
    sender: hash
    prev: hash
 
 */
