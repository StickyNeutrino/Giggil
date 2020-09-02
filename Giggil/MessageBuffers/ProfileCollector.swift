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

    var profiles = [Hash:GiggilProfile]()
    var order = [Hash]()
    
    var blocked = [Hash]()
    
    let queue: DispatchQueue
    
    init(net: LocalNetwork){
        let queueLabel = "Giggil.Sessions.queue"
        
        queue = DispatchQueue(label: queueLabel)
        
        super.init()
        
        net.add(localListen)
    }

    func blockProfile(ID: Hash) {
        queue.async {
            return
        }
    }
    
    func newProfile(_ message: GiggilMessage) {
        queue.async {
            let profile = GiggilProfile(seed: message)!
            
            profile.add(self.handle(message:peer:))
            
            self.profiles[message.id] = profile
        
        }
    }
    
    func updateProfile(_ message: GiggilMessage) {
        queue.async {
            
            guard case let .data(ID) = message.claims[.object]
                else { return }
            

            self.profiles[Bytes(ID)]?.add([message])
            
            self.profiles[Bytes(ID)]?.listener(message: message, hash: nil)
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
        struct sender: SenderType {
            var senderId: String = ""
            
            var displayName: String = "Unknown User"
        }
        
        let IDString = htos(id)
        
        guard let profile = profiles[id]
            else { return sender() }
        
        return sender(senderId: IDString, displayName: profile.name)
    }
    
    private func localListen(message: GiggilMessage, peer: Hash?) {
        
        queue.async {
            switch message.tid {
            case SESSION_MESSAGE:
                
                self.newProfile(message)
                
            default:
                self.updateProfile(message)
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
            
            return cell
        }
    }

}
