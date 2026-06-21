//
//  Models - Loads and present entity data as conceptual model objects
//

import SwiftUI
import CoreLocation
import MapKit

class Model: ObservableObject {
    @Published var airports: [Airport] = []
    @Published var flights: [Flight] = []
    fileprivate var airportsByName: [String: Airport] = [:]
    fileprivate var flightsByOrigin: [String: [Flight]] = [:]

    lazy var coverage: MKCoordinateRegion = findBound(from: airportsByName["KHH"]!,
                                                      for: [airportsByName["WKJ"]!])

    func load() -> Self {
        let airportEntities: [AirportEntity] = loadFile(fileName: "airports")
        let flightEntities: [FlightEntity] = loadFile(fileName: "flights")

        let flights = flightEntities.map({ Flight.init(model: self, entity: $0) })
        flightsByOrigin = Dictionary(grouping: flights, by: \.origin)

        let airports = airportEntities.map({ Airport.init(model: self, entity: $0) })
        airportsByName = Dictionary(uniqueKeysWithValues: airports.map({ ($0.id, $0) }))

        self.flights = flights
        self.airports = airports
        return self
    }

    func airport(forCode code: String) -> Airport? {
        airportsByName[code]
    }

    func flights(from origin: Airport, to destination: Airport) -> [Flight] {
        (flightsByOrigin[origin.id] ?? [])
            .filter { $0.destination == destination.id }
            .sorted { $0.departureTime < $1.departureTime }
    }

    func mileage(from origin: Airport, to destination: Airport) -> (miles: Int, isEstimated: Bool) {
        if let miles = flights(from: origin, to: destination).first?.miles {
            return (miles, false)
        }
        return (greatCircleMiles(from: origin, to: destination), true)
    }

    func duration(from origin: Airport, to destination: Airport) -> Duration? {
        guard let flight = flights(from: origin, to: destination).first else {
            return nil
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        guard let departure = formatter.date(from: flight.departureTime),
              var arrival = formatter.date(from: flight.arrivalTime) else {
            return nil
        }

        if arrival < departure {
            arrival = Calendar.current.date(byAdding: .day, value: 1, to: arrival) ?? arrival
        }

        return Duration.seconds(arrival.timeIntervalSince(departure))
    }
}

struct RouteStop: Identifiable, Equatable {
    let id = UUID()
    let airport: Airport
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
        model?.flightsByOrigin[id] ?? []
    }

    lazy var connections: [Connection] = {
        let flightsByDestination = Dictionary(grouping: flights, by: \.destination)
        return flightsByDestination.compactMap({
            guard let destination = model!.airportsByName[$0] else {
                return nil
            }
            return Connection(origin: self, destination: destination, flights: $1)
        }).sorted()
    }()

    lazy var coverage: MKCoordinateRegion = findBound(from: self, for: connections.map(\.destination))

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
        if lhs.flights.count != rhs.flights.count {
            return lhs.flights.count > rhs.flights.count
        }
        return lhs.flights.first!.departureTime < rhs.flights.first!.departureTime
    }

    static func == (lhs: Connection, rhs: Connection) -> Bool {
        lhs.origin == rhs.origin && lhs.destination == rhs.destination
    }
}
