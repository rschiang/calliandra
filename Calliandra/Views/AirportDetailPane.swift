//
//  AirportDetailPane - Shows detail about an airport

import SwiftUI

struct AirportDetailPane : View {
    var airport: Airport

    var heading: some View {
        HStack {
            Text(airport.name)
                .font(.title)
            Spacer()
            Text(airport.id)
                .font(.title2)
                .monospaced()
                .foregroundStyle(.secondary)
        }.padding(.horizontal, 16)
    }

    var list: some View {
        List(airport.connections) { connection in
            VStackLayout(alignment: .leading) {
                HStack {
                    Text(connection.destination.name)
                        .font(.headline)
                    Spacer()
                    Text(connection.destination.id)
                        .monospaced()
                        .foregroundStyle(.secondary)
                }
                HStackLayout(spacing: 4) {
                    ForEach(connection.flights) { flight in
                        Text(flight.departureTime)
                            .fixedSize()
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
    }

    var body: some View {
        VStack {
            heading
            list
        }
    }
}
