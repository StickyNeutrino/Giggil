//
//  SessionCollector.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 12/7/19.
//  Copyright © 2019 Fitchmun. All rights reserved.
//

import Foundation
import MessageKit
import Sodium

class ProfileCollector: MessageBuffer {
    
    var profiles = [Hash:(profile: GiggilProfile, blocked: Bool)]()
    var order = [Hash]()
    
    let queue = DispatchQueue(label: "Giggil.Sessions.queue")
    
    func blockProfile(ID: Hash) {
        queue.async {
            self.profiles[ID]?.blocked = true
        }
    }
    
    func moveToTop(_ id: Hash){
        queue.async {
            self.order.removeAll { (profileID) -> Bool in
                profileID == id
            }
            
            self.order.insert(id, at: 0)
        }
    }
    
    func idToSender(_ id: Hash) -> SenderType {
        let IDString = htos(id)
        
        guard let profile = profiles[id]?.profile
            else { return Sender(senderId: IDString, displayName: "Unknown Sender") }
        
        return Sender(senderId: IDString, displayName: profile.name)
    }
}

extension ProfileCollector : MessageListener {
        
    func listener(_ message: GiggilMessage) {
        
        func newProfile(_ message: SessionMessage) {
            let profile = GiggilProfile(message)

            queue.async {
                self.profiles[message.id] = (profile, false)
            }
        }
        
        func updateProfile(_ message: GiggilMessage) {
            guard case let .data(ID) = message.claims[.object]
                    else { return }
            queue.async {
                self.profiles[Bytes(ID)]?.profile.listener(message)
            }
        }
        
        switch message {
        case is SessionMessage:
            
            newProfile(message as! SessionMessage)
            
        case is ProfileNameMessage,
             is RevokeMessage:
            updateProfile(message)
            
        default:
            break
        }
        
        if self.filter(message) == nil { return }

        self.handle(message: message)
    
        guard case let .data(ID) = message.claims[.object]
            else { return }
        
        self.moveToTop(Bytes(ID))
    
    }
}

extension ProfileCollector: messageFilter {
    func filter(_ message: GiggilMessage) -> GiggilMessage? {
        queue.sync {
            for (profile, blocked) in profiles.values {
                if blocked { continue }
                if profile.filter(message) != nil { return message }
            }
            return nil
        }
    }
}

extension ProfileCollector: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        queue.sync {
            return order.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        queue.sync {
            guard let profile = profiles[order[indexPath.row]]?.profile
                else { fatalError() }
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NearbyUserCell.identifier) as? NearbyUserCell
                else { fatalError()}
            
            cell.loadProfile(profile)
            
            cell.blockCallback = {
                self.profiles[profile.id]?.blocked = true
                
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    else { return }
                
                appDelegate.localChat.purge(userID: profile.id)
                
                appDelegate.reloadChat?()
            }
            
            return cell
        }
    }
}
