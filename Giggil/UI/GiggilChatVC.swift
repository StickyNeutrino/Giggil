//
//  GiggilChatVC.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 6/14/19.
//  Copyright © 2019 Fitchmun. All rights reserved.
//

import UIKit

import MessageKit
import InputBarAccessoryView

import NotificationCenter

class GiggilChatVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(chatView)
        
        layoutViews()
        
        chatView.didMove(toParent:self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        chatView.becomeFirstResponder()
    }
    
    func layoutViews(){
        
        self.view.addSubview(chatView.view)
        
        chatView.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        chatView.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        chatView.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        chatView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    }
    
    lazy var chatView : MessagesViewController = { [weak self] in
        
        let VC = MessagesViewController()
        
        VC.messagesCollectionView.messagesDisplayDelegate = self
        VC.messagesCollectionView.messagesLayoutDelegate = self
        
        
        VC.messageInputBar.delegate = self
        
        VC.view.translatesAutoresizingMaskIntoConstraints = false
        
        VC.scrollsToBottomOnKeyboardBeginsEditing = true
        
        if let layout = VC.messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            
            layout.setMessageIncomingAvatarSize(.zero)
            layout.setMessageOutgoingAvatarSize(.zero)
            layout.setMessageIncomingMessageTopLabelAlignment(
                LabelAlignment(
                    textAlignment: .left,
                    textInsets:
                        UIEdgeInsets(top: 0, left: 12, bottom: 4, right: 0))
            )
        }
        
        return VC
    }()
    
    var messageDataSource: MessagesDataSource? {
        get {
            return chatView.messagesCollectionView.messagesDataSource
        }
        
        set(value) {
            chatView.messagesCollectionView.messagesDataSource = value
        }
    }
    
    var messagesLayoutDelegate: MessagesLayoutDelegate? {
        get {
            return chatView.messagesCollectionView.messagesLayoutDelegate
        }
        
        set(value) {
            chatView.messagesCollectionView.messagesLayoutDelegate = value
        }
    }
    
    var messageInputBarDelegate: MessageInputBarDelegate?

}

extension GiggilChatVC : MessagesDisplayDelegate, MessagesLayoutDelegate {
    
}

extension GiggilChatVC : MessageInputBarDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        inputBar.inputTextView.text = ""

        messageInputBarDelegate?.inputBar(inputBar, didPressSendButtonWith: text)
        
        DispatchQueue.main.async {
            self.chatView.messagesCollectionView.reloadData()
        }

    }
}

