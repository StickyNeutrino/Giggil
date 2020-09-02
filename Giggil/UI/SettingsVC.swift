//
//  SettingsVC.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 12/27/19.
//  Copyright © 2019 Fitchmun. All rights reserved.
//

import Foundation
import UIKit
import MTSlideToOpen

class SettingsVC : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view = settingsView
        
        settingsView.doneButton.addTarget(self, action:#selector(donePressed), for: .touchUpInside)

        settingsView.cancelButton.addTarget(self, action:#selector(cancelPressed), for: .touchUpInside)
        
        let tapToCloseKeyboard = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        
        view.addGestureRecognizer(tapToCloseKeyboard)
    }
    
    let settingsView = SettingsView()
    
    @objc func closeKeyboard() {
        settingsView.nameField.resignFirstResponder()
    }
    
    @objc func donePressed() {
        if let newName = settingsView.nameField.text {
            if newName == "" {
                dismiss(animated: true, completion: nil)
                return
            }
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
                else { return }
            
            let keys = appDelegate.activeSession.keys
            
            let profileID = appDelegate.activeSession.profile.session.id

            guard let nameMsg = GiggilMessage(
                claims: [
                    .object: .data(Data(profileID)),
                    .name: .text(newName),
                    .rand: .data(Data(sodium.randomBytes.buf(length: 32)!))
                ])
                .sign(keys)
                else { return }
            
            var newMessages = [nameMsg]
            
            for message in appDelegate.activeSession.profile.members() {
                if message.tid == PROFILE_NAME_MESSAGE {
                    guard let revoke = GiggilMessage(
                        claims: [
                            .object: .data(Data(profileID)),
                            .prev: .data(Data(message.id)),
                        ])
                    .sign(keys)
                    else { continue }
                    
                    newMessages.append(revoke)
                }
            }
            
            for message in newMessages {
                appDelegate.activeSession.profile.listener(message: message, hash: nil)
                appDelegate.localNetwork?.sendAll(message: message)
            }
            
            saveProfile()
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func cancelPressed() {
        dismiss(animated: true, completion: nil)
    }
}
