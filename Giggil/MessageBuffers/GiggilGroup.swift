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
    
    let profileCollector = ProfileCollector()
    
    init(_ charter: CharterMessage) {
        
        self.charter = charter
        
        super.init()
    }
    
    func listener(_ message: GiggilMessage) {
            
            queue.sync { self.profileCollector.listener(message) }
        
            if filter(message) != nil {
                queue.async {
                    switch message {
                    case is SessionMessage:
                        self.messages[message.id] = (message, false)
                    case is RevokeMessage:
                        self.revoke(message as! RevokeMessage)
                    case is InviteMessage:
                        self.messages[message.id] = (message, false)
                        
                    default:
                        self.messages[message.id] = (message, false)
                        
                    }
                }
            }
            
            if filter(message) != nil { handle(message: message) }
    }
    
    private func checkSender(_ message: GiggilMessage) -> Bool {
        
        guard case let .data(sender) = message.claims[.sender]
            else { return false }
        
        if let session = SessionMessage(orig: messages[Hash(sender)]?.messsage?.original ?? "") {
            return session.verify(message)
        }
        
        return false
    }
    
    private func revoke(_ revoke: RevokeMessage) {
        if self.filter(revoke) == nil { return }
        
        self.messages[ revoke.prev ]?.revoked = true
    }
    
    private func canSend(_ ID: Hash) -> Bool {
        
        if ID == charter.owner { return true }
        
        
        let invites = messages.values.compactMap{ (arg0) -> InviteMessage? in
            
            let (messsage, revoked) = arg0
            if revoked { return nil }
            if let invite = messsage as? InviteMessage {
                if invite.next == ID { return invite}
            }
            return nil
        }
        
        for invite in invites {
                if invite.next != ID { continue }
                if invite.sender == charter.owner {
                    return true
                }
                if canSend( invite.sender ) {
                    return true
                }

              
            }
        
        return false
    }
    
    private func invite(_ message: GiggilMessage) {
        
    }
}


extension GiggilGroup: messageFilter {
    func filter(_ message: GiggilMessage) -> GiggilMessage? {
        
        if Signed(message) == nil { return nil }
        if (message.id == self.charter.owner) { return message }
        
        switch message {
        case is TextMessage:
            if let text = message as? TextMessage {
                if (text.sender == self.charter.owner) { return message }
            }
        default:
            break
        }
        
        if ( queue.sync { self.profileCollector.filter(message) == nil } ) {
            return nil
        }
        
        
        switch message {
        case is CharterMessage:
            if message == charter { return message }
        case is InviteMessage:
            if let sender = (message as? InviteMessage)?.sender {
                return queue.sync {
                    if canSend(sender) { return message }
                    return nil
                }
            }
        case is TextMessage: //Change to grouptext
            if let text = message as? TextMessage {
                return queue.sync {
                    if canSend(text.sender) { return text }
                    return nil
                }
            }
        default:
            break
        }
        return nil
    }
    
    func isGroupMessage(_ message: GiggilMessage) -> GiggilMessage? {
        if (message is CharterMessage) || (message is TextMessage){
            return message
        }
        return nil
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
