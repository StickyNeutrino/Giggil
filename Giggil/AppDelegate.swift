//
//  AppDelegate.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 10/1/19.
//  Copyright © 2019 Fitchmun. All rights reserved.
//

import UIKit
import CoreData
import Sodium
import MessageKit

let sodium = Sodium()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var localNetwork: LocalNetwork?
    
    var localChat = LocalChat()
    
    let activeSession = getSession()
    
    var profileCollector: ProfileCollector?
    
    var messageSync: MessageSync?
    
    // MARK: - Init Base VC
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        //Could just take a active session
        localNetwork = LocalNetwork(me: activeSession.profile, keys: activeSession.keys)
        
        profileCollector = ProfileCollector(net: localNetwork!)
        
        messageSync = MessageSync(myID: activeSession.profile.session.id)
        
        profileCollector!
            .add(localChat.localListen)
        localChat
            .add(messageSync!.listener)


        self.window = UIWindow(frame: UIScreen.main.bounds)

        self.window!.rootViewController = MainVC()
        self.window!.makeKeyAndVisible()
    
        
        return true
    }
}

extension AppDelegate {
    func sign(_ message: GiggilMessage) -> GiggilMessage {
        let keys = activeSession.keys
        
        guard let signed = message.sign(keys)
            else { fatalError("failed to sign") }
        
        return signed
    }
}

extension AppDelegate: MessagesDataSource {
    func currentSender() -> SenderType {
        Sender(
            id: htos(activeSession.profile.session.id),
            displayName: activeSession.profile.name)
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        return toMessageKit(localChat.messages[indexPath.section])
    }
    
    func toMessageKit(_ message: GiggilMessage) -> MessageType {
        struct messageStruct: MessageType {
            let sender: SenderType
            
            let messageId: String
            
            let sentDate: Date
            
            let kind: MessageKind
        }
        
        let sender: SenderType
        
        if case let .data(data) = message.claims[.object] {
            let hash = Bytes(data)
            
            if hash == activeSession.profile.session.id {
                sender = currentSender()
            } else {
                sender = profileCollector!.idToSender(hash)
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
        localChat.messages.count
        
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

extension AppDelegate: MessagesLayoutDelegate {
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if !localChat.isNamed(indexPath.section) {
                return 0
            }

            return self.isFromCurrentSender(message: message) ? 0 : 12
    }
}

extension LocalChat {
    //Only first message in a block get a user name
    func isNamed(_ index: Int) -> Bool {
        
        if index == 0 { return true }
        
        guard case let .data(prev) = messages[index - 1].claims[.object]
            else { fatalError() }
        
        guard case let .data(target) = messages[index].claims[.object]
            else { fatalError() }
        
        if prev == target {
            return false
        }
        
        return true
    }
}

