//
//  File.swift
//  
//
//  Created by DOMINIC NDONDO on 3/8/24.
//
import Vapor
import Fluent
import Foundation


struct CreateUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("users")
            .id()
            .field("name", .string, .required)
            .field("username", .string, .required)
            .unique(on: "username")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("users")
            .delete()
    }
}
