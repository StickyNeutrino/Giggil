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

class LocalChat: MessageBuffer {

    var messages = [GiggilMessage]()
    
    let queue = DispatchQueue(label: "Giggil.Local.queue")
    
    func send(_ text: String){
        guard  let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else { return }
        
        let myID = appDelegate.activeSession.profile.session.id

        let unsigned = GiggilMessage(claims: [
            .object: .data(Data(myID)),
            .text: .text(text),
            .sent: .date(Date())
        ])
        
        let signed = appDelegate.sign(unsigned)
        
        queue.async {
            self.insert(signed)
            //Might be source of concurrency issues
            self.handle(message: signed, peer: myID)
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
    
    func localListen(message: GiggilMessage, peer: Hash?) {
        if message.tid == TEXT_MESSAGE {
            insert(message)
            handle(message: message, peer: peer)
        }
    }
}

extension LocalChat: MessageInputBarDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        send(text)
    }
}
