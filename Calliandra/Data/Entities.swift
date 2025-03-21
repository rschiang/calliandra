//
//  Entities - Stores codable structures that represent the source dataset
//

import CoreLocation

struct AirportEntity: Identifiable, Codable, Equatable {
    let id: String  // IATA Code
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String
}

struct FlightEntity: Identifiable, Codable, Equatable {
    let id: String  // Flight number
    let airline: String
    let number: Int
    let origin: String
    let destination: String
    let departureTime: String
    let arrivalTime: String
    let miles: Int
}
