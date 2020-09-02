//
//  ActiveSession.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 1/1/20.
//  Copyright © 2020 Fitchmun. All rights reserved.
//

import Foundation
import Sodium

struct ActiveSession {
    let profile: GiggilProfile
    let keys:    Sign.KeyPair
}


func getSession() -> ActiveSession {
    loadSession() ?? genSession()
}

func loadSession() -> ActiveSession? {
    guard let seed = UserDefaults.standard.data(forKey: "seed")
        else { return nil }
    
    guard let keys = sodium.sign.keyPair(seed: Bytes(seed))
        else { return nil }
    
    guard let messages = UserDefaults.standard.stringArray(forKey: "profile")
        else { return nil }
    
    if messages.count == 0 { return nil }
    
    guard let session = SessionMessage(orig: messages[0] )
        else { return nil }
    
    let profile = GiggilProfile(session)
    
    for message in messages.suffix(from: 1) {
        profile.listener(message: GiggilMessage(orig: message)!, hash: nil)
    }
    
    return ActiveSession(profile: profile, keys: keys)
}

func genSession() -> ActiveSession {
    let seed = sodium.randomBytes.buf(length: sodium.sign.SeedBytes)!
    let keys = sodium.sign.keyPair(seed: seed)!
    
    let session = SessionMessage(keys: keys).sign(keys)!

    let activeSession = ActiveSession(profile: GiggilProfile(seed: session)!, keys: keys)
    
    UserDefaults.standard.set([session.original], forKey: "profile")
    UserDefaults.standard.set(Data(seed), forKey: "seed")
    
    return activeSession
}

func saveProfile() {
    DispatchQueue.main.async {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else { return }
        
        let profile = appDelegate.activeSession.profile
        
        let seedOriginal = profile.session.original
        let memberOriginals = profile.members().map { (message) -> String in
            message.original
        }
        
        var saveData = [seedOriginal]
        saveData.append(contentsOf: memberOriginals)
        
        UserDefaults.standard.set(saveData, forKey: "profile")
        
    }
}


