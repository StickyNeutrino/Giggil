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

infix operator || : AdditionPrecedence
func || <T, U>(
    lhs: @escaping (T)->(U?),
    rhs: @escaping (T)->(U?))
    -> (T)->(U?) {
        return {(T) in
            lhs(T) ?? rhs(T) ?? nil
        }
        
}

protocol messageFilter {
    func filter(_ : GiggilMessage ) -> GiggilMessage?
}

func Signed (_ message: GiggilMessage?) -> GiggilMessage? {
    if message?.signature != nil {
        return message
    }
    return nil
}

func SessionType (_ message: GiggilMessage?) -> GiggilMessage? {
    if message?.tid == SESSION_MESSAGE {
        return message
    }
    return nil
}

func ValidSession (_ message: GiggilMessage?) -> GiggilMessage? {
    return message
    |> SessionType
    |> Signed
}
