//
//  GiggilMessage.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 10/1/19.
//  Copyright © 2019 Fitchmun. All rights reserved.
//

import Foundation
import Sodium


typealias Hash = Bytes

typealias Signature = Bytes

class GiggilMessage {
    
    let claims: [claimKeys: claimValue]
    let signature: Signature?
    
    let original: String
    
    required init?(orig: String) {
        original = orig
        
        let sections = original.split(separator: ".")
        
        if sections.count != 3 {
            return nil
        }
        
        let body = String(sections[1])
        
        signature = Bytes( base64decode(string: String(sections[2])) ?? Data())
        
        guard let claim = decodeClaims(body)
            else { return nil }
        
        claims = claim
    }
    
    init(claims: [claimKeys: claimValue]) {
        
        guard let body = encodeClaims(claims)
            else { fatalError() }
        
        original =  "HEAD." + body + "."
        
        signature = nil
        
        self.claims = claims
        
    }

    func sign(_ keys: Sign.KeyPair) -> GiggilMessage?{
        guard let bytes = sodium.sign.signature(
            message: body.bytes,
            secretKey: keys.secretKey)
            else { return nil }
        
        guard let signature = base64encode(data: Data(bytes))
            else { return nil }
        
        let message = GiggilMessageTyped("DEBUG." + body + "." + signature)

        return message
    }
    
    func verify(_ key: Sign.PublicKey) -> Bool {
        return sodium.sign.verify(
            message: body.bytes,
            publicKey: key,
            signature: signature ?? Bytes()
        )
    }
}

extension GiggilMessage: Comparable, Hashable {
    static func < (lhs: GiggilMessage, rhs: GiggilMessage) -> Bool {
        guard let result = sodium.utils.compare(lhs.id, rhs.id)
            else { fatalError() }
        
        switch result {
        case -1:
            return false
        case 0:
            return false
        case 1:
            return true
        default:
            fatalError()
        }
    }
    
    static func == (lhs: GiggilMessage, rhs: GiggilMessage) -> Bool {
        guard let result = sodium.utils.compare(lhs.id, rhs.id)
            else { fatalError() }
        
        return result == 0
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

extension GiggilMessage {
    var id: Hash {
        get {
            return sodium.genericHash.hash(message: body.bytes)!
        }
    }
    
    var tid: Hash {
        get {
            return tidCalc(claims: Array(claims.keys))!
        }
    }
}
