//
//  Models - Loads and present entity data as conceptual model objects
//

import SwiftUI
import CoreLocation

class Model: ObservableObject {
    @Published var airports: [Airport] = []
    @Published var flights: [Flight] = []
    fileprivate var airportsByName: [String: Airport] = [:]
    fileprivate var flightsByOrigin: [String: [Flight]] = [:]

    func load() -> Self {
        let airportEntities: [AirportEntity] = loadFile(fileName: "airports")
        let flightEntities: [FlightEntity] = loadFile(fileName: "flights")

        let flights = flightEntities.map({ Flight.init(model: self, entity: $0) })
        flightsByOrigin = Dictionary(grouping: flights, by: \.origin)

        let airports = airportEntities.filter({ flightsByOrigin[$0.id] != nil }).map({ Airport.init(model: self, entity: $0) })
        airportsByName = Dictionary(uniqueKeysWithValues: airports.map({ ($0.id, $0) }))

        self.flights = flights
        self.airports = airports
        return self
    }
}

class Airport: Identifiable, Equatable, Hashable {
    private unowned let model: Model?

    fileprivate init(model: Model, entity: AirportEntity) {
        self.model = model
        self.id = entity.id
        self.name = entity.name
        self.latitude = entity.latitude
        self.longitude = entity.longitude
        self.country = entity.country
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    let id: String // IATA Code
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String
    let coordinate: CLLocationCoordinate2D

    var flights: [Flight] {
        model!.flightsByOrigin[id]!
    }

    lazy var connections: [Connection] = {
        let flightsByDestination = Dictionary(grouping: flights, by: \.destination)
        return flightsByDestination.map({ Connection(origin: self, destination: model!.airportsByName[$0]!, flights: $1) }).sorted()
    }()

    static func == (lhs: Airport, rhs: Airport) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}

class Flight: Identifiable, Equatable {
    private unowned let model: Model?

    fileprivate init(model: Model, entity: FlightEntity) {
        self.model = model
        self.id = entity.id
        self.airline = entity.airline
        self.number = entity.number
        self.origin = entity.origin
        self.destination = entity.destination
        self.departureTime = entity.departureTime
        self.arrivalTime = entity.arrivalTime
        self.miles = entity.miles
    }

    let id: String  // Flight number
    let airline: String
    let number: Int
    let origin: String
    let destination: String
    let departureTime: String
    let arrivalTime: String
    let miles: Int

    static func == (lhs: Flight, rhs: Flight) -> Bool {
        lhs.id == rhs.id
    }
}

class Connection: Identifiable, Equatable, Comparable {
    let id: String
    unowned let origin: Airport
    unowned let destination: Airport
    let flights: [Flight]

    fileprivate init(origin: Airport, destination: Airport, flights: [Flight]) {
        self.id = origin.id + destination.id
        self.origin = origin
        self.destination = destination
        self.flights = flights.sorted { $0.departureTime < $1.departureTime }
    }

    static func < (lhs: Connection, rhs: Connection) -> Bool {
        !(lhs.flights.count < rhs.flights.count || lhs.flights.first!.departureTime > rhs.flights.first!.departureTime)
    }

    static func == (lhs: Connection, rhs: Connection) -> Bool {
        lhs.origin == rhs.origin && lhs.destination == rhs.destination
    }
}
