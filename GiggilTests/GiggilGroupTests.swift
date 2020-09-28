//
//  GiggilGroupTests.swift
//  GiggilTests
//
//  Created by Daniel Fitchmun on 9/22/20.
//  Copyright © 2020 Fitchmun. All rights reserved.
//

import XCTest
import Foundation
@testable import Giggil
import Sodium

class GiggilGroupTests: XCTestCase {
    
    let owner = SessionMessage(keys: testKey).sign(testKey)!
    
    lazy var charter = CharterMessage(owner: owner as! SessionMessage)
    
    lazy var group = GiggilGroup(charter)
    
    override func setUp() {
        group = GiggilGroup(charter)
    }
    
    func testOwnerMessagesPass() {
        let text = TextMessage(sender: owner.id, text: "Anything really").sign(testKey)!
        
        let expectation = XCTestExpectation()
        
        group.add { (message) in
            if message == text { expectation.fulfill() }
        }
        
        XCTAssert( group.filter(text) != nil )
        group.listener(text)
        
        wait(for: [expectation] , timeout: 1)
    }
    
    func testUnsignedMessagesFail() {
        let text = TextMessage(sender: owner.id, text: "Anything really")
    
        group.add { (message) in
            if message == text { XCTFail() }
        }
        
        group.listener(text)
        XCTAssert( group.filter(text) == nil )
    }
    
    func testSenderMustBeInvited() {
        let newKeys = randomKey()
        let newUser = SessionMessage(keys: newKeys).sign(newKeys)!
        let text = TextMessage(sender: newUser.id, text: "Anything really").sign(newKeys)!
        
        group.add { (message) in
            if message == text { XCTFail() }
        }
        
        XCTAssert( group.filter(text) == nil )
        group.listener(text)
    }
    
    func testInvitedSenderPass() {
        let newKeys = randomKey()
        let newUser = SessionMessage(keys: newKeys).sign(newKeys)!
        let text = TextMessage(sender: newUser.id, text: "Anything really").sign(newKeys)!
        
        let invite = InviteMessage(
            object: group.charter.id,
            sender: owner.id,
            next: newUser.id)
        .sign(testKey)!
        
        let expectation = XCTestExpectation()
        
        group.add { (message) in
            if message == text { expectation.fulfill() }
        }
        group.listener(newUser)
        group.listener(invite)
        group.listener(text)
        
        XCTAssert( group.filter(text) != nil )
        
        wait(for: [expectation] , timeout: 1)
    }
    
    func testInviteChains() {
        
        var expectations = [XCTestExpectation]()
        
        var prev = owner as! SessionMessage
        var signKeys = testKey
        for _ in 0...8 {
            let newKeys = randomKey()
            let newUser = SessionMessage(keys: newKeys).sign(newKeys)!
            
            let invite = InviteMessage(
                object: group.charter.id,
                sender: prev.id,
                next: newUser.id)
            .sign(signKeys)!
            
            prev = newUser as! SessionMessage
            signKeys = newKeys
            
            group.listener(invite)
            group.listener(newUser)
            
            let text = TextMessage(sender: newUser.id, text: "Anything really").sign(newKeys)!
            
            
            let expectation = XCTestExpectation()
            expectations.append(expectation)
            group.add { (message) in
                if message == text { expectation.fulfill() }
            }
            
            group.listener(text)
            
            XCTAssert( group.filter(text) != nil )
        }
        
        wait(for: expectations , timeout: 3)
    }
    
    func testSelfInviteFails() {
        let newKeys = randomKey()
        let newUser = SessionMessage(keys: newKeys).sign(newKeys)!
        let text = TextMessage(sender: newUser.id, text: "Anything really").sign(newKeys)!
        
        let invite = InviteMessage(
            object: group.charter.id,
            sender: newUser.id,
            next: newUser.id)
        .sign(newKeys)!
        
        group.add { (message) in
            if message == text { XCTFail() }
        }
        
        group.listener(invite)
        
        XCTAssert( group.filter(invite) == nil )
        
        group.listener(text)
    }
}
