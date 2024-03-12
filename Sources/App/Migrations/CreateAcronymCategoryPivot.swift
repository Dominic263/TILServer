//
//  CreateAcronymCategoryPivot.swift
//
//
//  Created by DOMINIC NDONDO on 3/11/24.
//
import Foundation
import Fluent

struct CreateAcronymCategoryPivot: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("acronym-category-pivot")
            .id()
            .field("acronymID", .uuid, .required, .references("acronyms", "id", onDelete: .cascade))
            .field("categoryID", .uuid, .required, .references("categories", "id", onDelete: .cascade))
            .unique(on: "categoryID")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("acronym-category-pivot")
            .delete()
    }
}
