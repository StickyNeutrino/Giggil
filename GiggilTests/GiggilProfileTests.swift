//
//  GiggilProfileTests.swift
//  GiggilTests
//
//  Created by Daniel Fitchmun on 9/21/20.
//  Copyright © 2020 Fitchmun. All rights reserved.
//

import XCTest
import Foundation
@testable import Giggil
import Sodium

func randomString(length: Int) -> String {
  let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  return String((0..<length).map{ _ in letters.randomElement()! })
}

class GiggilProfileTests: XCTestCase {
    
    func randomKey() -> Sign.KeyPair {
        return sodium.sign.keyPair()!
    }
    
    func randomNameMessage(session: SessionMessage) -> ProfileNameMessage {
        let name = randomString(length: .random(in: 1...1024))

        return ProfileNameMessage(object: session.id, name: name)
    }
    
    func testUnsignedSession() {
        let session = SessionMessage(keys: randomKey())
        
        let profile = GiggilProfile(seed: session)
        
        XCTAssert(profile == nil, session.original)
    }
    
    func testSignedSession() {
        let keys = randomKey()
        
        let session = SessionMessage(keys: keys).sign(keys)!
        
        let profile = GiggilProfile(seed: session)
        
        XCTAssert(profile != nil, session.original)
    }
    
    func testInitFailure() {
        for message in allMessages {
            let profile = GiggilProfile(seed: message)
            
            if message.tid != SESSION_MESSAGE {
                XCTAssert( profile == nil )
            }
        }
    }
    
    func testOnlyValidMessagesPass() {
        
    }
    
    func testAllValidMessagesPass() {
        
    }
    
    func testDefaultName() {
        
    }

}
