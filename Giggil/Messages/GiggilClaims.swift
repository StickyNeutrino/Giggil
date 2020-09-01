//
//  GiggilClaims.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 10/17/19.
//  Copyright © 2019 Fitchmun. All rights reserved.
//

import Foundation
import Sodium

enum claimKeys: String {
    case object
    case text
    case sent
    case name
    case rand
    case prev
    case rec
    case key
}

fileprivate func A (key: claimKeys, value: Any) -> claimValue {
    switch key {
    case .object, .rand, .prev, .key:
        guard let v = value as? String
            else { return .none }
        
        guard let d = base64decode(string: v)
            else { return .none }
        
        return .data(d)
    case .text, .name:
        guard let v = value as? String
            else { return .none }
        return .text(v)
    case .rec:
        guard let v = value as? Bool
            else { return .none }
        return .bool(v)
    case .sent:
        guard let n = value as? NSNumber
            else { return .none }
        return .date(Date(timeIntervalSinceReferenceDate: TimeInterval(truncating: n)))
    }
}

enum claimValue {
    case text(String)
    case date(Date)
    case data(Data)
    case bool(Bool)
    case none
}
func tidCalc(claims: [claimKeys]) -> Hash? {
    
    let start = "tid:\(claims.count)".bytes
    
    let hash = sodium.genericHash.initStream()
    
    hash?.update(input: start)

    for claim in claims.sorted(by: { (key1, key2) -> Bool in
        key1.rawValue < key2.rawValue
    }) {
        let key = claim.rawValue
        
        hash?.update(input: key.bytes)
    }
    
    return hash?.final()
}

func encodeClaims(_ claims: [claimKeys: claimValue]) -> String? {
    let preJson = claims.reduce([String: Any]()) { (prev, claim) -> [String: Any] in
        
        let jsonValue: Any
        

        switch claim.value {
            case .text(let val):
                jsonValue = val
            case .date(let val):
                jsonValue = val.timeIntervalSinceReferenceDate
            case .data(let val):
                jsonValue = base64encode(data: Data(val)) ?? "giggil"
            case .bool(let val):
                jsonValue = val
            default:
                jsonValue = "giggil"
        }

        var next = prev
        
        next[claim.key.rawValue] = jsonValue
        
        return next
    }
    
    if !JSONSerialization.isValidJSONObject(preJson){
        return nil
    }
    
    let json: Data
    
    do {
      json = try JSONSerialization.data(withJSONObject: preJson)
    } catch {
        return nil
    }

    return base64encode(data: json)
    
}

func decodeClaims(_ body: String) -> [claimKeys: claimValue]? {
    guard let json = base64decode(string: body)
        else { return nil }
    
    let something: Any
    
    do {
        something = try JSONSerialization.jsonObject(with: json)
    } catch {
        return nil
    }
    
    guard let dict = (something as? NSDictionary) as? [String:Any]
        else { return nil }

    let claims = dict.map { (claim) -> (claimKeys, claimValue)? in
        guard let key = claimKeys(rawValue: claim.key)
            else { return nil }
        
        let value = A(key: key, value: claim.value)
        
        return (key, value)
    }
    
    var final = [claimKeys: claimValue]()
    
    for claim in claims {
        guard let (key, value) = claim
            else { return nil }
        
        final[key] = value
    }
    
    return final
}

let TEXT_CLAIMS: [claimKeys] = [
    .object,
    .text,
    .sent,
]

let TEXT_MESSAGE = tidCalc(claims: TEXT_CLAIMS)!

let REVOKE_CLAIMS: [claimKeys] = [
    .object,
    .prev
]

let REVOKE_MESSAGE = tidCalc(claims: REVOKE_CLAIMS)!

let SESSION_CLAIMS: [claimKeys] = [
    .key
]

let SESSION_MESSAGE = tidCalc(claims: SESSION_CLAIMS)!

let PROFILE_NAME_CLAIMS: [claimKeys] = [
    .object,
    .rand,
    .name
]

let PROFILE_NAME_MESSAGE = tidCalc(claims: PROFILE_NAME_CLAIMS)!

let KEY_EXCHANGE_CLAIMS: [claimKeys] = [
    .key,
    .object,
]

let KEY_EXCHANGE_MESSAGE = tidCalc(claims: KEY_EXCHANGE_CLAIMS)!


