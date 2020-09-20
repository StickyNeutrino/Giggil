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
import InputBarAccessoryView

let sodium = Sodium()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var localNetwork: LocalNetwork?
    
    lazy var localChat = {
        LocalChat(sender: activeSession.profile.id)
    }()
    
    let activeSession = getSession()
    
    let profileCollector = ProfileCollector()
    
    var messageSync: MessageSync?
    
    var reloadChat: (() -> ())? = nil
    
    // MARK: - Init Base VC
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        //Could just take a active session
        localNetwork = LocalNetwork(me: activeSession.profile, keys: activeSession.keys)
        
        messageSync = MessageSync(myID: activeSession.profile.id)
        
        localNetwork!
            ||> profileCollector
            ||> localChat
            ||> messageSync!

        localChat.listener(activeSession.profile.session)
        
        for message in activeSession.profile.members() {
            localChat.listener(message)
        }

        self.window = UIWindow(frame: UIScreen.main.bounds)

        let vc = MainVC()
        
        reloadChat = vc.reloadChat
        
        self.window!.rootViewController = vc
        self.window!.makeKeyAndVisible()
        
        return true
    }
}

extension AppDelegate: MessageInputBarDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        send(text)
        reloadChat?()
    }
    
    func send(_ text: String){
        let unsigned = TextMessage(sender: activeSession.profile.id, text: text)
        
        let signed = unsigned.sign(activeSession.keys)!
        
        localChat.listener(signed)
        
        localNetwork?.sendAll(message: signed)
    }
}
