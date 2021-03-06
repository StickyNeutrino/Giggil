//
//  MessageBuffer.swift
//  Giggil
//
//  Created by Daniel Fitchmun on 12/9/19.
//  Copyright © 2019 Fitchmun. All rights reserved.
//

import Foundation

class MessageBuffer: NSObject {
    
    let listenerQueue = DispatchQueue(label: "Giggil.Buffer.queue")
    
    private var listeners = [   Int: (GiggilMessage) -> Void   ]    ()
    
    func add(_ listener: @escaping (GiggilMessage) -> Void) {
        listenerQueue.async {
        
            let index = self.listeners.count
        
            self.listeners[index] = listener
        }
    }

    func handle(message: GiggilMessage){
        listenerQueue.async {
            for listener in self.listeners.values {
                self.listenerQueue.async {
                    listener(message)
                }
            }
        }
    }
}

precedencegroup ForwardPipe {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
}

infix operator ||> : ForwardPipe
extension MessageBuffer {
    static func ||> (lhs: MessageBuffer, rhs: MessageListener & MessageBuffer) -> MessageBuffer {

        lhs.add(rhs.listener)
        
        return rhs
    }
    
    static func ||> (lhs: MessageBuffer, rhs: MessageListener) {
        lhs.add(rhs.listener)
    }
}

protocol MessageListener {
    func listener(_: GiggilMessage)
}

