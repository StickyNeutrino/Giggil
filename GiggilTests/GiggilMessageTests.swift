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
        
        let message = GiggilMessage(claims: [.key : .data(Data(keys.publicKey))])
        
        let signedMessage = message.sign(keys)
        
        XCTAssert(message == signedMessage)
        XCTAssert(message.id == signedMessage!.id)
        XCTAssert(message.tid == signedMessage!.tid)
    }
    
    func testVerifyReturnsTrueWithPropperKey() {

    }
    
    func testVerifyReturnsFalseWithImpropperKey() {

    }
    
    
}
