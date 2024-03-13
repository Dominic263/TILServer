//
//  User.swift
//
//
//  Created by DOMINIC NDONDO on 3/8/24.
//
import Foundation
import Vapor
import Fluent

final class User: Model {
    
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "password")
    var password: String
    
    @Children(for: \.$user)
    var acronyms: [Acronym]
    
    init() { }
    
    init(id: UUID? = nil, name: String, username: String, password: String) {
        self.id = id
        self.name = name
        self.username = username
        self.password = password
    }
    
    struct Public: Content {
        var id: UUID?
        var name: String
        var username: String
    }
}

extension User: Content { }

extension User {
    func convertToPublic() -> User.Public {
        return User.Public(id: self.id, name: self.name, username: self.username)
    }
}


extension EventLoopFuture where Value: User {
    func convertToPublic() -> EventLoopFuture<User.Public> {
        self.map { user in
            user.convertToPublic()
        }
    }
}
