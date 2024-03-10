//
//  CreateCategory.swift
//
//
//  Created by DOMINIC NDONDO on 3/8/24.
//
import Fluent
import Foundation
import Vapor


struct CreateCategory: AsyncMigration {
    func prepare(on database: FluentKit.Database) async throws {
       try await database.schema("categories")
            .id()
            .field("name", .string, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
       try await database.schema("categories")
            .delete()
    }
}
