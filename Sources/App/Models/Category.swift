//
//  Category.swift
//
//
//  Created by DOMINIC NDONDO on 3/8/24.
//
import Vapor
import Fluent
import Foundation


final class Category: Model {
    static let schema = "categories"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    init() { }
    
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

extension Category: Content { }
