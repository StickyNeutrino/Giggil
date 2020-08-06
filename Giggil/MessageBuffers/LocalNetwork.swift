//
//  LocalDelivery.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 10/29/19.
//  Copyright © 2019 Fitchmun. All rights reserved.
//

import Foundation
import Sodium
import MultipeerConnectivity
import os

class LocalNetwork: MessageBuffer {
    
    struct Peer {
    
        let id: Hash
        var session: MCSession
        var outbox: [GiggilMessage] = []
        let rx: SecretBox.Key, tx: SecretBox.Key
    }
    
    let queue = DispatchQueue(label: "Giggil.Local.Network.queue")
    
    var locals: [MCPeerID: Peer] = [:]
    var peerIDs: [Hash: MCPeerID] = [:]
    
    let myself: MCPeerID
    let browser: MCNearbyServiceBrowser
    let advertiser: MCNearbyServiceAdvertiser
    
    let keys = sodium.keyExchange.keyPair()!
    
    let id: Hash
    
    init?(me: GiggilProfile, keys: Sign.KeyPair) {
        
        myself = MCPeerID(displayName: me.name)
        
        id = me.session.id
        
        guard let kx =
            GiggilMessage(
                claims: [
                    .key: .data(Data(self.keys.publicKey)),
                    .object: .data(Data(me.session.id))
                ]
            ).sign(keys)
            else { return nil }

        browser = .init(
            peer: myself,
            serviceType: "GiggilNetwork")
        
        advertiser = .init(
            peer: myself,
            discoveryInfo: [
                "session":  me.session.original,
                "kx":       kx.original
            ],
            serviceType: "GiggilNetwork")
        
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
        
        super.init()
        
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [unowned self] notification in
            
            self.peerIDs = [:]
            _ = self.locals.values.map { (p) in p.session.disconnect() }
            self.locals = [:]
        }
        
        advertiser.delegate = self
        browser.delegate = self
    }
    
    func send(_ message: GiggilMessage, to peer: Hash) {
        queue.async {
            guard let peerID = self.peerIDs[peer]
                else { return }
            
            
            self.locals[peerID]?.outbox.append(message)
            
            self.flushOutbox(id: peerID)
        }
    }
    
    func sendAll(message: GiggilMessage) {
        queue.async {
            for peer in self.peerIDs.keys {
                self.send(message, to: peer)
            }
        }
    }
    
}

// MARK: - Browser Delegate

extension LocalNetwork: MCNearbyServiceBrowserDelegate{
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        queue.async {
            func validateKX(kx: GiggilMessage, session: GiggilMessage) -> Bool {
                return true
            }
                    
            guard let sessionMessage = GiggilMessage(orig: info?["session"] ?? "")
                else { return }
            
            guard let kxMessage = GiggilMessage(orig: info?["kx"] ?? "")
                else { return }
            
            if !validateKX(kx: kxMessage, session: sessionMessage) {
                return
            }
            
            self.handle(message: sessionMessage, peer: sessionMessage.id)
            
            let session = MCSession(peer: self.myself, securityIdentity: nil, encryptionPreference: .optional)
            
            session.delegate = self
         
            guard case let .data(other) = kxMessage.claims[.key]
                else { return }
            
            guard let rx = sodium.keyExchange.sessionKeyPair(
                publicKey: self.keys.publicKey,
                secretKey: self.keys.secretKey,
                otherPublicKey: Bytes(other),
                side: .CLIENT)?.rx
                else { return }
            
            guard let tx = sodium.keyExchange.sessionKeyPair(
                publicKey: self.keys.publicKey,
                secretKey: self.keys.secretKey,
                otherPublicKey: Bytes(other),
                side: .SERVER)?.tx
                else { return }
                    
            let peer = Peer(id: sessionMessage.id, session: session, rx: rx, tx: tx)
            
            self.locals[peerID] = peer
            self.peerIDs[peer.id] = peerID
            
            print("Found new peer: \(htos(peer.id))")
            
            DispatchQueue.main.async {
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    else { return }
                
                for message in appDelegate.activeSession!.profile.members() {
                        self.send(message, to: peer.id)
                }
                
                for message in appDelegate.messageSync?.messages ?? [] {
                    self.send(message, to: peer.id)
                }
            }
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        queue.async {
            guard let id = self.locals[peerID]?.id
                else { return }
            
            print("Browser lost peer: \(htos(id))")
            
            self.locals[peerID]?.session.disconnect()
            self.peerIDs[id] = nil
            self.locals[peerID] = nil
        }
    }
}

// MARK: - Advertiser Delegate

extension LocalNetwork: MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        queue.async {
            guard let local = self.locals[peerID]
                else {
                    print("Got invite with no local")
                    invitationHandler(false, nil)
                    return
            }
            
            invitationHandler(true, local.session)
            print("Accepted Invite")
        }
    }
}

// MARK: - Session Delegate

extension LocalNetwork: MCSessionDelegate {
    
    func flushOutbox(id: MCPeerID){
        queue.async {
            guard let local = self.locals[id]
                else { return }
            
            let session = local.session
            
            if session.connectedPeers.count == 0 {
                self.browser.invitePeer(id, to: session, withContext: nil, timeout: 30)
                print("Invited Peer \(htos(local.id))")
                return
            }
            
            self.locals[id]?.outbox = local.outbox.filter
            { (message) -> Bool in  //Returns true for failure
                
                let cleartext = message.original.bytes
                
                guard let transmission: Bytes = sodium.secretBox.seal(message: cleartext, secretKey: local.tx)
                    else { return true }
                
                do {
                    try session.send(
                    Data(transmission),
                    toPeers: [id],
                    with: .reliable)
                    
                    print("SENT", message.id)
                    
                } catch {
                    return true
                }
                return false
                
            }
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        queue.async {
            switch state {
                
            case .notConnected:
                print("Not Connected")
                if ( self.locals[peerID]?.outbox.count ?? 0 ) > 0 {
                    self.flushOutbox(id: peerID)
                }
            case .connecting:
                print("Connecting")
                return
            case .connected:
                print("Connected")
                self.flushOutbox(id: peerID)
            default:
                return
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        queue.async {
            guard let rx = self.locals[peerID]?.rx
            else { return }
            
            let plaintext = sodium.secretBox.open(
                nonceAndAuthenticatedCipherText: Bytes(data),
                secretKey: rx)
            
            guard let jwt = plaintext?.utf8String
                else { return }
            
            guard let message = GiggilMessage(orig: jwt)
                else { return }
            
            print("GOT", message.id)
            
            self.handle(message: message, peer: self.locals[peerID]?.id)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        return
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        return
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        return
    }
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
}
