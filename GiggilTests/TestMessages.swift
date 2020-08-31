//
//  TestMessages.swift
//  GiggilTests
//
//  Created by Daniel Fitchmun on 8/31/20.
//  Copyright © 2020 Fitchmun. All rights reserved.
//

import Foundation
@testable import Giggil

let testSession = GiggilMessage(
    claims: [
        .key : .data(Data(sodium.sign.keyPair()!.publicKey))
    ])

let testText = GiggilMessage(
    claims: [
        .object : .data(Data(testSession.id)),
        .text   : .text("who"),
        .sent   : .date(Date())
    ])

let testRevoke = GiggilMessage(
    claims: [
        .object : .data(Data(testSession.id)),
        .prev   : .data(Data(testText.id)),
])

let testProfileName = GiggilMessage(
    claims: [
        .object : .data(Data(testSession.id)),
        .rand  : .data(Data(testText.id)),
        .name : .text("Daniel")
])

let testKeyExchange = GiggilMessage(
   claims: [
    .key : .data(Data(sodium.sign.keyPair()!.publicKey)),
    .object : .data(Data(testSession.id))
])

let allMessages = [testSession, testText, testRevoke, testProfileName, testKeyExchange]
