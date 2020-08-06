//
//  DistributedObject.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 10/23/19.
//  Copyright © 2019 Fitchmun. All rights reserved.
//

import Foundation

protocol DistributedObject {
    init?(seed: GiggilMessage)
    
    func add(_ messages: [GiggilMessage])
    
    func members() -> [GiggilMessage]
}
 
