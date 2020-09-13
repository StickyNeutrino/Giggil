//
//  LocalChat.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 12/7/19.
//  Copyright © 2019 Fitchmun. All rights reserved.
//

import Foundation
import MessageKit
import InputBarAccessoryView

class LocalChat: MessageBuffer, MessageListener {

    var messages = [GiggilMessage]()
    
    let queue = DispatchQueue(label: "Giggil.Local.queue")
    
    func send(_ text: String){
        guard  let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else { return }
        
        let session = appDelegate.activeSession
        let unsigned = GiggilMessage(claims: [
            .object: .data(Data(session.profile.id)),
            .text: .text(text),
            .sent: .date(Date())
        ])
        
        let signed = unsigned.sign(session.keys)!
        
        queue.async {
            self.insert(signed)
            //Might be source of concurrency issues
            self.handle(message: signed)
        }
        
        appDelegate.localNetwork?.sendAll(message: signed)
    }
    

    
    func insert(_ message: GiggilMessage) {
        queue.async {
            
            if self.messages.contains(message){
                return
            }
            
            guard case let .date(sent) = message.claims[.sent]
                else { return }
            
            let index = self.messages.firstIndex { (msg) -> Bool in
                guard case let .date(test) = msg.claims[.sent]
                    else { return false }
                
                return test > sent
            }
            
            self.messages.insert(message, at: index ?? self.messages.endIndex)
        }
    }
    
    func purge(userID: Hash) {
        queue.async {
            self.messages = self.messages.filter { (message) -> Bool in
                guard case let .data(ID) = message.claims[.object]
                    else { return false }
                return userID != Hash(ID)
            }
        }
    }
    
    func listener(_ message: GiggilMessage) {
        if message.tid == TEXT_MESSAGE {
            insert(message)
            handle(message: message)
        }
    }
}

extension LocalChat: MessageInputBarDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        send(text)
    }
}
