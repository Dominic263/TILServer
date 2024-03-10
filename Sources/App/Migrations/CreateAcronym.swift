//
//  CreateAcronym.swift
//
//  Runs a migration to create an acronyms table on the db
//  Created by DOMINIC NDONDO on 3/8/24.
//
import Fluent
import Vapor

struct CreateAcronym: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("acronyms")
            .id()
            .field("short", .string, .required)
            .field("long", .string, .required)
            .field("userID", .uuid, .required, .references("users", "id"))
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("acronyms")
            .delete()
    }
}
