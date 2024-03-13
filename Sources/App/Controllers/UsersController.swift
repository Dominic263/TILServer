//
//  UserController.swift
//  
//
//  Created by DOMINIC NDONDO on 3/8/24.
//
import Vapor
import Fluent
import Foundation


struct UsersController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let userRoutes = routes.grouped("api", "user")
        
        userRoutes.get(use: getAllUsersHandler)
        userRoutes.post(use: createHandler)
        userRoutes.get(":userID", use: getHandler)
        userRoutes.get(":userID", "acronyms", use: getAcronymsForUser)
    }
    
    
    func getAcronymsForUser(_ req: Request) async throws -> [Acronym] {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound, reason: "Could not find the user on the database.")
        }
        return try await user.$acronyms.get(on: req.db)
    }
    
    func getAllUsersHandler(_ req: Request) async throws -> [User.Public] {
        try await User.query(on: req.db).all().map { user in
            user.convertToPublic()
        }
    }
    
    func getHandler(_ req: Request) async throws -> User.Public {
        guard let user = try await User.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound, reason: "Could not find user on the database.")
        }
        return user.convertToPublic()
    }
    
    func createHandler(_ req: Request) async throws -> User.Public {
        let user = try req.content.decode(User.self)
        
        user.password = try Bcrypt.hash(user.password)
        
        try await user.save(on: req.db)
        return user.convertToPublic()
    }
}
