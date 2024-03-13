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
        
        //create a basic authentication middleware and pass it to the user routes
        let basicAuthMiddleware = User.authenticator()
        let basicAuthGroup = userRoutes.grouped(basicAuthMiddleware)
        basicAuthGroup.post("login", use: loginHandler)
    }
    
    func loginHandler(_ req: Request) async throws -> Token {
        // get the authenticated user from the request
        let user = try req.auth.require(User.self)
        
        // generate, save and return the generated token
        let token = try Token.generateToken(for: user)
        
        try await token.save(on: req.db)
        return token
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
        print("I am here")
        let user = try req.content.decode(User.self)
        print("Now I am here")
        
        user.password = try Bcrypt.hash(user.password)
        
        try await user.save(on: req.db)
        return user.convertToPublic()
    }
}
