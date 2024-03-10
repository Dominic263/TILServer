import Fluent
import Vapor

func routes(_ app: Application) throws {
    let acronymController = AcronymsController()
    try app.register(collection: acronymController)
   
    let usersController = UsersController()
    try app.register(collection: usersController) 
    
    let categoriesController = CategoriesController()
    try app.register(collection: categoriesController)
}
