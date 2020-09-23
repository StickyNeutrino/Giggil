//
//  MessageUtility.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 12/7/19.
//  Copyright © 2019 Fitchmun. All rights reserved.
//

import Foundation
import MessageKit


extension GiggilMessage {
    var body: String {
        get {
            let sections = original.split(separator: ".")
           
            if sections.count < 2 {
               fatalError()
            }

            return String(sections[1])
        }
    }
}

func GiggilMessageTyped (_ orig: String) -> GiggilMessage {
    let types = [
        SessionMessage.self,
        KeyExchangeMessage.self,
        ProfileNameMessage.self,
        TextMessage.self,
        InviteMessage.self,
        RevokeMessage.self,
        CharterMessage.self
    ]
    
    return types.reduce(nil, { prev, current in prev ?? current.init(orig: orig) })!
}
