//
//  Main application
//

import SwiftUI

@main
struct CalliandraApp: App {
    @State var airports: [Airport] = loadAirports()

    var body: some Scene {
        WindowGroup {
            AirportMapView(airports: $airports)
        }
    }

    static func loadAirports() -> [Airport] {
        guard let url = Bundle.main.url(forResource: "airports", withExtension: "json") else {
            fatalError(#function + ": Cannot find JSON file")
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode([Airport].self, from: data)
        } catch {
            fatalError("Error loading airports: \(error)")
        }
    }
}
