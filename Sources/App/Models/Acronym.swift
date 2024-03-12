//
//  Acronym.swift
//  Defines an Acronym model
//
//  Created by DOMINIC NDONDO on 3/8/24.
//
import Fluent
import Foundation
import Vapor

final class Acronym: Model {
    static let schema = "acronyms"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "short")
    var short: String
    
    @Field(key: "long")
    var long: String
    
    @Parent(key: "userID") // this key maps the ID column in the parent's table.
    var user: User
    
    @Siblings(through: AcronymCategoryPivot.self, from: \.$acronym, to: \.$category)
    var categories: [Category]
    
    init() { }
    
    init(id: UUID? = nil, short: String, long: String, userID: User.IDValue) {
        self.id = id
        self.short = short
        self.long = long
        self.$user.id = userID
    }
}

extension Acronym: Content { }
