//
//  MainVC.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 6/14/19.
//  Copyright © 2019 Fitchmun. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView

import Sodium

class MainVC: SwitchVC {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        rightVC = GiggilChatVC()
    
        leftVC = NearbyUsersVC()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else { return }
        
        appDelegate.profileCollector.add(reloadListener)
        
        (rightVC as! GiggilChatVC) //Fixme
            .messageInputBarDelegate = appDelegate
        
        (rightVC as! GiggilChatVC) //Fixme
            .messageDataSource = appDelegate.localChat
        
        (rightVC as! GiggilChatVC) //Fixme
            .messagesLayoutDelegate = appDelegate.localChat
        
        setSegmentNames(names: ["Nearby", "Chat"])
        
        leftButton.setImage(UIImage(named: "gear-outline")!, for: .normal)
        
        leftButton.addTarget(self, action: #selector(leftPressed), for: .primaryActionTriggered)
        
    }

    private func reloadListener(message: GiggilMessage) {
        if message.tid  == TEXT_MESSAGE
        || message.tid == PROFILE_NAME_MESSAGE
        || message.tid == REVOKE_MESSAGE {
            reloadChat()
        }
    }
    
    func reloadChat() {
        DispatchQueue.main.async {
            let chatView = (self.rightVC as! GiggilChatVC).chatView
            chatView.messagesCollectionView.reloadData()
        }
    }
    
    @objc func leftPressed(){
        self.present(SettingsVC(), animated: true)
    }
   
}

