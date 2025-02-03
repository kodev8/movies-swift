//
//  MovieModel.swift
//  movies
//
//  Created by Terran Winner on 2/3/25.
//

import Foundation
import SwiftData
import SwiftUI


@Model
class DetailedMovie {
    var title: String
    var year: String
    var rated: String?
    var released: String?
    var runtime: String?
    var genre: String?
    var director: String?
    var writer: String?
    var actors: String?
    var plot: String
    var language: String?
    var country: String?
    var awards: String?
    var poster: String
    var metascore: String?
    var imdbRating: String?
    var imdbVotes: String?
    var imdbID: String?
    var type: String?
    var dvd: String?
    var boxOffice: String?
    var production: String?
    var website: String?
    var rating: Int
    @Relationship(inverse: \MovieUser.movies) var user: MovieUser?
   
    // Add a transient property for gallery images
    @Transient
    var galleryImage: Image?
   
    init(from detail: MovieDetail, galleryImage: Image? = nil) {
        self.title = detail.title
        self.year = detail.year
        self.rated = detail.rated
        self.released = detail.released
        self.runtime = detail.runtime
        self.genre = detail.genre
        self.director = detail.director
        self.writer = detail.writer
        self.actors = detail.actors
        self.plot = detail.plot
        self.language = detail.language
        self.country = detail.country
        self.awards = detail.awards
        self.poster = detail.poster
        self.metascore = detail.metascore
        self.imdbRating = detail.imdbRating
        self.imdbVotes = detail.imdbVotes
        self.imdbID = detail.imdbID
        self.type = detail.type
        self.dvd = detail.dvd
        self.boxOffice = detail.boxOffice
        self.production = detail.production
        self.website = detail.website
        self.rating = 0
        self.galleryImage = galleryImage
    }
}









