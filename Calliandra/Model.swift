//
//  Model - Holds the data model of the application
//

import SwiftUI

class Model: ObservableObject {
    @Published var airports: [Airport]
    @Published var flights: [Flight]
    @Published var flightsByOrigin: [String: [Flight]]

    init() {
        let airports: [Airport] = Model.loadFile(fileName: "airports")
        let flights: [Flight] = Model.loadFile(fileName: "flights")
        let flightsByOrigin = Dictionary(grouping: flights, by: { $0.origin })

        self.airports = airports.filter { flightsByOrigin[$0.id] != nil }
        self.flights = flights
        self.flightsByOrigin = flightsByOrigin
    }

    static func loadFile<T: Decodable>(fileName: String) -> [T] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            fatalError("Cannot find JSON resource named \(fileName).json")
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode([T].self, from: data)
        } catch {
            fatalError("Error loading \(fileName): \(error)")
        }
    }
}
