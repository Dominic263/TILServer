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
        
        
        acronymRoutes.get( use: getAllAcronymsHandler)
        acronymRoutes.get(":acronymID", use: getHandler)
        acronymRoutes.get(":acronymID", "user", use: getUserForAcronymHandler)
        acronymRoutes.get(":acronymID", "categories", use: getCategoriesForAcronym)
        acronymRoutes.get("search", use: searchHandler)
        
        // protect the routes so that only an authenticated user can access them
        /*
         Middlewares
            tokenAuthMiddleware - ensures that the token is valid and not expired for the user
            guardMiddleware - ensures that the user has been successfully authenticated and given permission to access the acronymRoutes
         */
        let tokenAuthMiddleware = Token.authenticator()
        let guardMiddleware = User.guardMiddleware()
        let tokenAuthGroup = acronymRoutes.grouped(tokenAuthMiddleware, guardMiddleware)
        
        tokenAuthGroup.post(use: createHandler)
        tokenAuthGroup.put(":acronymID", use: updateHandler)
        tokenAuthGroup.post(":acronymID", "categories", ":categoryID", use: addCategories)
        tokenAuthGroup.delete(":acronymID", use: deleteHandler)
    }
    
    func searchHandler(_ req: Request) async throws -> [Acronym] {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        
        return try await Acronym.query(on: req.db)
            .group(.or) { query in
                query.filter(\.$short == searchTerm)
                query.filter(\.$long == searchTerm)
            }
            .all()
    }
    
    func getCategoriesForAcronym(_ req: Request) async throws -> [Category] {
        guard let acronym = try await Acronym.find(req.parameters.get("acronymID"), on: req.db) else {
            throw Abort(.notFound, reason: "Could not find acronym on database.")
        }
        
        return try await acronym.$categories.get(on: req.db)
    }
    
    func getUserForAcronymHandler(_ req: Request) async throws -> User.Public {
        guard let acronym = try await Acronym.find(req.parameters.get("acronymID"), on: req.db) else {
            throw Abort(.notFound, reason: "Could not find acronym on database.")
        }
        
        return try await acronym.$user.get(on: req.db).convertToPublic()
    }
    
    func updateHandler(_ req: Request) async throws -> Acronym  {
        
        let decodedAcronym = try req.content.decode(Acronym.self)
        let user = try req.auth.require(User.self)
        
        guard let acronym = try await Acronym.find(req.parameters.get("acronymID"), on: req.db) else {
            throw Abort(.notFound, reason: "Could not find the acronym on the database.")
        }
        
        acronym.short = decodedAcronym.short
        acronym.long = decodedAcronym.long
        acronym.$user.id = try user.requireID()
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
        let user = try req.auth.require(User.self)
        let acronym = try Acronym(short: data.short, long: data.long, userID: user.requireID())
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
}
