//
//  MovieUser.swift
//  movies
//
//  Created by Terran Winner on 2/2/25.
//

import Foundation
import CoreData


@objc(MovieUser)
public class MovieUser: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var email: String
    @NSManaged public var name: String
    @NSManaged public var dateOfBirth: Date
    @NSManaged public var password: String
   
    // For preview and testing
    static var preview: MovieUser {
        let user = MovieUser()
        user.id = UUID()
        user.email = "test@example.com"
        user.name = "John Doe"
        user.dateOfBirth = Date()
        user.password = "password123"
        return user
    }
}


extension MovieUser {
    static var entityName: String { "MovieUser" }
   
    static func fetchRequest() -> NSFetchRequest<MovieUser> {
        return NSFetchRequest<MovieUser>(entityName: entityName)
    }
   
    convenience init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "MovieUser", in: context)!
        self.init(entity: entity, insertInto: context)
    }
}
