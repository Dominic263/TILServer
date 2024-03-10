//
//  CategoriesController.swift
//
//
//  Created by DOMINIC NDONDO on 3/8/24.
//

import Foundation
import Vapor
import Fluent


struct CategoriesController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let categoriesRoutes = routes.grouped("api", "category")
        
        categoriesRoutes.get( use: getAllCategoriesHandler)
        categoriesRoutes.post(use: createCategoriesHandler)
        categoriesRoutes.get(":categoryID", use: getHandler)
    }
    
    func getHandler(_ req: Request) async throws -> Category {
        let categoryID = req.parameters.get("categoryID", as: UUID.self)
        guard let category = try await Category.find(categoryID, on: req.db) else {
            throw Abort(.notFound, reason: "Could not find category on database.")
        }
        
        return category
    }
    
    func createCategoriesHandler(_ req: Request) async throws -> Category {
        let category = try req.content.decode(Category.self)
        try await category.save(on: req.db)
        return category
    }
    
    func getAllCategoriesHandler(_ req: Request) async throws -> [Category] {
        return try await Category.query(on: req.db).all()
    }
}
