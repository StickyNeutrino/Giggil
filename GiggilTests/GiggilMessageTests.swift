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
    
    func testVerifyReturnsTrueWithPropperKey() {

    }
    
    func testVerifyReturnsFalseWithImpropperKey() {

    }
    
    
}
