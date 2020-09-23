//
//  ProfileCollectorTests.swift
//  GiggilTests
//
//  Created by Daniel Fitchmun on 9/22/20.
//  Copyright © 2020 Fitchmun. All rights reserved.
//

import XCTest
import Foundation
@testable import Giggil
import Sodium

class ProfileCollectorTests: XCTestCase {
    
    var pc = ProfileCollector()
    
    let profile = GiggilProfile(seed: SessionMessage(keys: testKey).sign(testKey)!)!
    
    lazy var unsignedText = {
        TextMessage(sender: profile.id, text: "Anything really")
    }()
    
    lazy var validText = {
        TextMessage(sender: profile.id, text: "Anything really").sign(testKey)!
    }()
    
    lazy var invalidText = {
        TextMessage(sender: profile.id, text: "Anything really").sign(randomKey())!
    }()
    
    override func setUp() {
        pc = ProfileCollector()
        
    }
    
    func testBlockUnsigned() {
        pc.listener(profile.session)

        pc.add { (message) in
            if message == self.unsignedText { XCTFail() }
        }
        
        pc.listener(unsignedText)
        
        sleep(1) //FIXME
    }
    
    func testPassValid() {
        pc.listener(profile.session)
        
        let expect = XCTestExpectation()

        pc.add { (message) in
            if message == self.validText { expect.fulfill() }
        }
        
        pc.listener(validText)
        
        wait(for: [expect], timeout: 1)
    }
    
    func testBlockInvalid() {
        pc.listener(profile.session)

        pc.add { (message) in
            if message == self.invalidText { XCTFail() }
        }

        pc.listener(invalidText)

        sleep(1) //FIXME
    }
    
    func testMessagesWaitForSession() {
        
    }
    
    func testBlock() {
        pc.listener(profile.session)

        pc.add { (message) in
            if message == self.validText { XCTFail() }
        }
        
        pc.blockProfile(ID: profile.session.id)

        pc.listener(validText)

        sleep(1) //FIXME
    }
    
    func testUnblock() {
        
    }
    
}
