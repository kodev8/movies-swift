// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let tMDBMovieDetail = try? JSONDecoder().decode(TMDBMovieDetail.self, from: jsonData)


import Foundation


// MARK: - TMDBMovieDetail
struct TMDBMovieDetail: Codable {
    let adult: Bool
    let backdropPath: String
    let budget: Int
    let genres: [Genre]
    let homepage: String
    let id: Int
    let imdbID: String
    let originCountry: [String]
    let originalLanguage, originalTitle, overview: String
    let popularity: Double
    let posterPath: String
//    let productionCompanies: [ProductionCompany]
    let productionCountries: [ProductionCountry]
    let releaseDate: String
    let revenue, runtime: Int
    let spokenLanguages: [SpokenLanguage]
    let status, tagline, title: String
    let video: Bool
    let voteAverage: Double
    let voteCount: Int


    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case budget, genres, homepage, id
        case imdbID = "imdb_id"
        case originCountry = "origin_country"
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview, popularity
        case posterPath = "poster_path"
//        case productionCompanies = "production_companies"
        case productionCountries = "production_countries"
        case releaseDate = "release_date"
        case revenue, runtime
        case spokenLanguages = "spoken_languages"
        case status, tagline, title, video
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}


// MARK: - Genre
struct Genre: Codable {
    let id: Int
    let name: String
}


//// MARK: - ProductionCompany
//struct ProductionCompany: Codable {
//    let id: Int
//    let logoPath, name, originCountry: String
//
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case logoPath = "logo_path"
//        case name
//        case originCountry = "origin_country"
//    }
//}


// MARK: - ProductionCountry
struct ProductionCountry: Codable {
    let iso3166_1, name: String


    enum CodingKeys: String, CodingKey {
        case iso3166_1 = "iso_3166_1"
        case name
    }
}


// MARK: - SpokenLanguage
struct SpokenLanguage: Codable {
    let englishName, iso639_1, name: String


    enum CodingKeys: String, CodingKey {
        case englishName = "english_name"
        case iso639_1 = "iso_639_1"
        case name
    }
}



struct TMDBMovieCredits: Codable {
    let id: Int
    let cast, crew: [Cast]
}


struct Cast: Codable {
//    let adult: Bool
//    let gender, id: Int
    let knownForDepartment: Department
    let name, originalName: String
    let popularity: Double
    let profilePath: String?
    let castID: Int?
    let character: String?
    let creditID: String
    let order: Int?
    let department: Department?
    let job: String?


    enum CodingKeys: String, CodingKey {
//        case adult,
//             case gender, id
        case knownForDepartment = "known_for_department"
        case name
        case originalName = "original_name"
        case popularity
        case profilePath = "profile_path"
        case castID = "cast_id"
        case character
        case creditID = "credit_id"
        case order, department, job
    }
}


enum Department: String, Codable {
    case acting = "Acting"
    case directing = "Directing"
    case writing = "Writing"
    case art = "Art"
    case sound = "Sound"
    case camera = "Camera"
    case editing = "Editing"
    case production = "Production"
    case crew = "Crew"
    case visualEffects = "Visual Effects"
    case costume = "Costume & Make-Up"
   
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Department(rawValue: rawValue) ?? .crew
    }
}









