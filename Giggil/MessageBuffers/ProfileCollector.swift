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

class ProfileCollector: MessageBuffer, MessageListener {
    
    var profiles = [Hash:GiggilProfile]()
    var order = [Hash]()
    
    var blocked = [Hash:Bool]()
    
    let queue = DispatchQueue(label: "Giggil.Sessions.queue")
    
    func blockProfile(ID: Hash) {
        queue.async {
            self.blocked[ID] = true
        }
    }
    
    func updateProfile(_ message: GiggilMessage) {
        queue.async {
            
            guard case let .data(ID) = message.claims[.object]
                else { return }
            
            self.profiles[Bytes(ID)]?.listener(message)
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
        
        guard let profile = profiles[id]
            else { return Sender(senderId: IDString, displayName: "Unknown Sender") }
        
        return Sender(senderId: IDString, displayName: profile.name)
    }
    
    func listener(_ message: GiggilMessage) {
        
        func newProfile(_ message: GiggilMessage) {
            let profile = GiggilProfile(seed: message)!
            
            func blockableListener(message:GiggilMessage) {
                self.queue.async {
                    if self.blocked[ profile.id ] ?? false {
                        return
                    }
                    
                    self.handle(message: message)
                }
            }
            
            profile.add(blockableListener)
            
            self.profiles[message.id] = profile
            
            self.handle(message: message)
        }
        
        
        func validateAndHandle(_ message: GiggilMessage) {
            guard case let .data(sender) = message.claims[.sender]
                else { return }
            
            if self.profiles[Hash(sender)]?.session.verify(message) ?? false {
                self.handle(message: message)
            }
        }
        
        queue.async {
            switch message.tid {
            case SESSION_MESSAGE:
                
                newProfile(message)
                
            case PROFILE_NAME_MESSAGE,
                 REVOKE_MESSAGE:
                self.updateProfile(message)
                
            default:
                validateAndHandle(message)
            }
            
            guard case let .data(ID) = message.claims[.object]
                else { return }
            
            self.moveToTop(Bytes(ID))
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
            guard let profile = profiles[order[indexPath.row]]
                else { fatalError() }
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NearbyUserCell.identifier) as? NearbyUserCell
                else { fatalError()}
            
            cell.loadProfile(profile)
            
            cell.blockCallback = {
                self.blocked[profile.id] = true
                
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    else { return }
                
                appDelegate.localChat.purge(userID: profile.id)
                
                appDelegate.reloadChat?()
            }
            
            return cell
        }
    }
}
