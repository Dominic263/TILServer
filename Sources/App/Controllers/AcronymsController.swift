//
//  AcronymsController.swift
//
//
//  Created by DOMINIC NDONDO on 3/8/24.
//

import Foundation
import Vapor
import Fluent

struct AcronymsController: RouteCollection  {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let acronymRoutes = routes.grouped("api", "acronym")
        
        acronymRoutes.post( use: createHandler)
        acronymRoutes.get( use: getAllAcronymsHandler)
        acronymRoutes.get(":acronymID", use: getHandler)
        acronymRoutes.delete(":acronymID", use: deleteHandler)
        acronymRoutes.put(":acronymID", use: updateHandler)
        acronymRoutes.get(":acronymID", "user", use: getUserForAcronymHandler)
        acronymRoutes.get(":acronymID", "categories", use: getCategoriesForAcronym)
        acronymRoutes.post(":acronymID", "categories", ":categoryID", use: addCategories)
    }
    
    func getCategoriesForAcronym(_ req: Request) async throws -> [Category] {
        guard let acronym = try await Acronym.find(req.parameters.get("acronymID"), on: req.db) else {
            throw Abort(.notFound, reason: "Could not find acronym on database.")
        }
        
        return try await acronym.$categories.get(on: req.db)
    }
    
    func getUserForAcronymHandler(_ req: Request) async throws -> User {
        guard let acronym = try await Acronym.find(req.parameters.get("acronymID"), on: req.db) else {
            throw Abort(.notFound, reason: "Could not find acronym on database.")
        }
        
        return try await acronym.$user.get(on: req.db)
    }
    
    func updateHandler(_ req: Request) async throws -> Acronym  {
        
        let decodedAcronym = try req.content.decode(Acronym.self)
        
        guard let acronym = try await Acronym.find(req.parameters.get("acronymID"), on: req.db) else {
            throw Abort(.notFound, reason: "Could not find the acronym on the database.")
        }
        
        acronym.short = decodedAcronym.short
        acronym.long = decodedAcronym.long
        try await acronym.save(on: req.db)
        
        return acronym
    }
    
    func deleteHandler(_ req: Request ) async throws -> Acronym {
        guard let acronym = try await Acronym.find(req.parameters.get("acronymID"), on: req.db) else {
            throw Abort(.notFound, reason: "Could not find the acronym on the database.")
        }
        try await acronym.delete(on: req.db)
        
        return acronym
    }
    
    func getHandler(_ req: Request) async throws -> Acronym  {
        guard let acronym = try await Acronym.find(req.parameters.get("acronymID"), on: req.db) else {
            throw Abort(.notFound, reason: "Could not find the acronym on the database.")
        }
        return acronym
    }
    
    func createHandler(_ req: Request) async throws -> Acronym {
        let data = try req.content.decode(CreateAcronymData.self)
        let acronym = Acronym(short: data.short, long: data.long, userID: data.userID)
        try await acronym.save(on: req.db)
        return acronym
    }
    
    func getAllAcronymsHandler(_ req: Request) async throws -> [Acronym] {
        try await Acronym.query(on: req.db).all()
    }
    
    func addCategories( _ req: Request) async throws -> HTTPStatus {
        
        guard let acronym = try await Acronym.find(req.parameters.get("acronymID"), on: req.db) else {
            throw Abort(.notFound, reason: "Could not find the acronym on the database.")
        }
        
        guard let category = try await Category.find(req.parameters.get("categoryID"), on: req.db) else {
            throw Abort(.notFound, reason: "Could not find category on the database")
        }
        
        try await acronym.$categories.attach(category, on: req.db)
        
        return .created
    }
    
}

// Domain Transfer Objects (DTO)

struct CreateAcronymData: Codable {
    let short: String
    let long: String
    let userID: UUID
}
