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
