//
//  Token.swift
//
//
//  Created by DOMINIC NDONDO on 3/12/24.
//
import Fluent
import Vapor
import Foundation


final class Token: Model, Content {
    
    static let schema = "tokens"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "value")
    var value: String
    
    @Parent(key: "userID")
    var user: User
    
    init() { }
    
    init(id: UUID? = nil, value: String, userID: User.IDValue) {
        self.id = id
        self.value = value
        self.$user.id = userID
    }
    
}

extension Token {
    static func generateToken(for user: User) throws -> Token {
        let random = [UInt8].random(count: 16).base64
        return try Token(value: random, userID: user.requireID())
    }
}

extension Token: ModelTokenAuthenticatable {
    static let valueKey = \Token.$value
    static let userKey = \Token.$user
    typealias User = App.User
    
    var isValid: Bool {
        // check for expiration dates here.
        return true
    }
}
