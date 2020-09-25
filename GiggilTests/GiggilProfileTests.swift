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

func randomKey() -> Sign.KeyPair {
    return sodium.sign.keyPair()!
}

class GiggilProfileTests: XCTestCase {
    
    func testUnsignedSessionFails() {
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
    
    func testOnlyValidMessagesPass() {
        let keys = randomKey()
        
        let session = SessionMessage(orig: SessionMessage(keys: keys).sign(keys)!.original)!
        
        let profile = GiggilProfile(session)
        
        let invalid = TextMessage(sender: profile.id, text: "Anything really").sign(testKey)!
        
        profile.add { _ in XCTFail() }
        
        profile.listener(invalid)
        
    }
    
    func testValidMessagesPass() {
        let keys = randomKey()
               
        let session = SessionMessage(orig: SessionMessage(keys: keys).sign(keys)!.original)!

        let profile = GiggilProfile(session)

        let valid = TextMessage(sender: profile.id, text: "Anything really").sign(keys)!
        
        let expectation = XCTestExpectation()

        profile.add { _ in  expectation.fulfill() }

        profile.listener(valid)
        
        wait(for: [expectation], timeout: 1.0)

    }
    
    func testOnlySignedMessagesPass() {
        let keys = randomKey()
               
        let session = SessionMessage(orig: SessionMessage(keys: keys).sign(keys)!.original)!

        let profile = GiggilProfile(session)

        let invalid = TextMessage(sender: profile.id, text: "Anything really")

        profile.add { _ in XCTFail() }

        profile.listener(invalid)
        
    }
    
    func testDefaultName() {
        
    }
    
    func testRevokesBlock() {
        let keys = randomKey()
               
        let session = SessionMessage(orig: SessionMessage(keys: keys).sign(keys)!.original)!

        let profile = GiggilProfile(session)

        let valid = TextMessage(sender: profile.id, text: "Anything really").sign(keys)!
        
        let valid2 = TextMessage(sender: profile.id, text: "Anything new really").sign(keys)!
        
        let revoke = RevokeMessage(object: profile.id, prev: valid.id).sign(keys)!

        let expectation = XCTestExpectation()
        
        profile.add { message in
            XCTAssert(message != valid)
            if message == valid2 { expectation.fulfill() }
        }

        profile.listener(revoke)
        profile.listener(valid)
        profile.listener(valid2)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRevokesBeingRevoked() {
        let keys = randomKey()
               
        let session = SessionMessage(orig: SessionMessage(keys: keys).sign(keys)!.original)!

        let profile = GiggilProfile(session)

        let valid = TextMessage(sender: profile.id, text: "Anything really").sign(keys)!
        
        let revoked = RevokeMessage(object: profile.id, prev: valid.id).sign(keys)!
        
        let revoked2 = RevokeMessage(object: profile.id, prev: valid.id).sign(keys)!
        
        let expectation = XCTestExpectation()
        
        var count = 0

        profile.add { _ in
            count += 1
            if count == 3 { expectation.fulfill() }
        }

        profile.listener(valid)
        profile.listener(revoked)
        profile.listener(revoked2)
        
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testRevokesBeingRevoked2() {
        let keys = randomKey()
               
        let session = SessionMessage(orig: SessionMessage(keys: keys).sign(keys)!.original)!

        let profile = GiggilProfile(session)

        let valid = TextMessage(sender: profile.id, text: "Anything really").sign(keys)!
        
        let revoke = RevokeMessage(object: profile.id, prev: valid.id).sign(keys)!
        
        let revoked2 = RevokeMessage(object: profile.id, prev: revoke.id).sign(keys)!

        let expectation = XCTestExpectation()
        
        profile.add { message in
            XCTAssert(message != revoke)
            if message == valid { expectation.fulfill() }
        }

        profile.listener(revoked2)
        profile.listener(revoke)
        profile.listener(valid)
        
        wait(for: [expectation], timeout: 1.0)
    }

}
