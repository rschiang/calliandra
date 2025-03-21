//
//  Flight - Represent a flight schedule
//

struct Flight: Identifiable, Codable, Equatable {
    let id: String  // Flight number
    let airline: String
    let number: Int16
    let origin: String
    let destination: String
    let departureTime: String
    let arrivalTime: String

    static func ==(lhs: Flight, rhs: Flight) -> Bool {
        lhs.id == rhs.id
    }
}
