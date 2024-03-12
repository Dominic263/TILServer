//
//  AcronymCategoryPivot.swift
//
//
//  Created by DOMINIC NDONDO on 3/11/24.
//

import Foundation
import Fluent
import Vapor


final class AcronymCategoryPivot: Model {
    static let schema = "acronym-category-pivot"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "acronymID")
    var acronym: Acronym
    
    @Parent(key: "categoryID")
    var category: Category
    
    init() { }
    
    init(id: UUID? = nil, acronym: Acronym, category: Category) throws {
        self.id = id
        self.$acronym.id = try acronym.requireID()
        self.$category.id = try category.requireID()
    }
}

extension AcronymCategoryPivot: Content {}
