//
//  LocalChat.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 12/7/19.
//  Copyright © 2019 Fitchmun. All rights reserved.
//

import Foundation
import MessageKit

class LocalChat: MessageBuffer, MessageListener {

    var messages = [GiggilMessage]()
    
    let senderID : Hash
    
    let profileCollector = ProfileCollector()
    
    init(sender: Hash){
        senderID = sender
        
        super.init()
        
        _ = self ||> profileCollector
        
        profileCollector.add(insert(_:))
    }
    
    let queue = DispatchQueue(label: "Giggil.Local.queue")

    func insert(_ message: GiggilMessage) {
        queue.async {
            
            if message.tid != TEXT_MESSAGE {
                return
            }
            
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
        handle(message: message)
    }
}

extension LocalChat: MessagesDataSource {
    func currentSender() -> SenderType {
        Sender(
            id: htos(senderID),
            displayName: profileCollector.profiles[senderID]!.name
        )
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        queue.sync {
            return toMessageKit(messages[indexPath.section])
        }
    }
    
    func toMessageKit(_ message: GiggilMessage) -> MessageType {
        struct messageStruct: MessageType {
            let sender: SenderType
            
            let messageId: String
            
            let sentDate: Date
            
            let kind: MessageKind
        }
        
        let sender: SenderType
        
        if case let .data(data) = message.claims[.sender] {
            let hash = Hash(data)
            
            if hash == senderID {
                sender = currentSender()
            } else {
                sender = profileCollector.idToSender(hash)
            }
        } else { fatalError() }
        
        guard case let .date(sentDate) =  message.claims[.sent]
            else { fatalError() }
        
        guard case let .text(text) = message.claims[.text]
            else { fatalError() }
        
        return messageStruct(
            sender: sender,
            messageId: htos(message.id),
            sentDate: sentDate,
            kind: .text(text))
    }

    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        queue.sync {
            messages.count
        }
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {

        let name = message.sender.displayName
    
        return NSAttributedString(
            string: name,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .caption1),
                .foregroundColor: UIColor.gray,
        ])
    }
}

extension LocalChat: MessagesLayoutDelegate {
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if !isNamed(indexPath.section) {
                return 0
            }

            return self.isFromCurrentSender(message: message) ? 0 : 12
    }
}

extension LocalChat {
    //Only first message in a block get a user name
    func isNamed(_ index: Int) -> Bool {
        
        if index == 0 { return true }
        
        guard case let .data(prev) = messages[index - 1].claims[.sender]
            else { fatalError() }
        
        guard case let .data(target) = messages[index].claims[.sender]
            else { fatalError() }
        
        if prev == target {
            return false
        }
        
        return true
    }
}
