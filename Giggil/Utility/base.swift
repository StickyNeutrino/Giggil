//
//  base.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 10/27/19.
//  Copyright © 2019 Fitchmun. All rights reserved.
//

import Foundation

func base64encode(data: Data) -> String? {
    return data.base64EncodedString()
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
        .replacingOccurrences(of: "=", with: "")
}

func base64decode(string: String) -> Data? {
    var unpadded = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
    
    if unpadded.count % 4 != 0 {
        unpadded.append(String(repeating: "=", count: 4 - unpadded.count % 4))
    }
    
    return Data(base64Encoded: unpadded)
}

func htos(_ hash: Hash) -> String {
    base64encode(data: Data(hash))!
}
