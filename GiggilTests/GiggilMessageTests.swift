//
//  GiggilMessageTests.swift
//  GiggilTests
//
//  Created by Daniel Fitchmun on 8/17/20.
//  Copyright © 2020 Fitchmun. All rights reserved.
//
import XCTest
import Foundation
@testable import Giggil

extension GiggilTests {
    func testSigningPreservesID() {
        
        let keys = sodium.sign.keyPair()!
        
        for message in allMessages {
            
            let signedMessage = message.sign(keys)
            
            XCTAssert(message.id == signedMessage!.id)
        }
    }
    
    func testSigningPreservesTID() {
        
        let keys = sodium.sign.keyPair()!
        
        for message in allMessages {
            
            let signedMessage = message.sign(keys)
            
            XCTAssert(message.tid == signedMessage!.tid)
        }
    }
    
    func testSigningPreservesEquality() {
        
        let keys = sodium.sign.keyPair()!
        
        for message in allMessages {
            
            let signedMessage = message.sign(keys)
            
            XCTAssert(message == signedMessage)
        }
    }
    
    func testSign() {
        let message = SessionMessage(keys: testKey).sign(testKey)
        
        XCTAssert( message != nil )
        XCTAssert( message?.signature != nil)
    }
    
    func testVerify() {
        for message in allSigned {
            XCTAssert(message.verify(testKey.publicKey) == true)
        }
        
        let otherKeys = randomKey()
        
        for message in allSigned {
            XCTAssert(message.verify(otherKeys.publicKey) == false)
        }
    }
    
    
}
