//
//  MessageFilter.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 9/13/20.
//  Copyright © 2020 Fitchmun. All rights reserved.
//

import Foundation

infix operator |> : ForwardPipe
func |> <T, U>(value: T, function: (T)->(U)) -> U { function(value) }

func Signed (_ message: GiggilMessage?) -> GiggilMessage? {
    if message?.signature != nil {
        return message
    }
}

func SessionType (_ message: GiggilMessage?) -> GiggilMessage? {
    if message?.tid == SESSION_MESSAGE {
        return message
    }
}

func ValidSession (_ message: GiggilMessage?) -> GiggilMessage? {
    return message
    |> SessionType
    |> Signed
    |>
}
