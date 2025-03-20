//
//  Airport - Represent an airport
//

import CoreLocation

struct Airport: Identifiable, Codable, Equatable {
    let id: String  // IATA Code
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String

    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }

    static func ==(lhs: Airport, rhs: Airport) -> Bool {
        lhs.id == rhs.id
    }
}
