#  Giggil Vision

### Purpose
This document is meant to serve two purposes. Firstly, to solidify my current mental model of what I would like giggil to become. Secondly, I would hope it would serve as inspiration for what / where some other developers could contribute to the project.

No part of this is set in stone, and only some of it is set in code.

One of the main goals of Giggil is to have a network and protocol that can be used for efficent and secure text comunication, while maintaining flexibility for other purposes.

## Messges

Messages are the core unit of giggil. 

Everything exchanged between devices is a message.

Valid messages are a subset of valid JWT.

As such they have a head, body, and signature.

The head is currently not used, as it's contents are not verifyed by the signature.

The body is a JSON object that contains the Claims of the message. It also includes information on how to find the key of the message sender.

The Signature is a LibSodium public/private key singature. It will be explained later on how the key is found.

### ID
Messages are ID'ed by contents, that is to say, if two messages have the same body, they have the same ID.

Currently this is achived by hashing the body section of the JWT.

This hashing must be consistent across devices and versions, as some messages refer to other messages by ID.


### TID

### Verification

## Distributed Objects

### Outline
Distributed objects are collections of messages that enable more complex and mutable representations of data.
### ID

### Seed 
Distributed obejct are created by a seed message.
The seed is all that is nessesary to prove the existence of an object.
There is a one to one mapping of seeds to objects, as such both share the same ID.
### Data 

### Revoke

### History (aka Members)

## Current Objects

### Profiles
Validate:
- Must be signed by a valid key
- Must not be revoked

### Groups

