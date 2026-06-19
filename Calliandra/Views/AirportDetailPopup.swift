//
//  AirportDetailPopup - Compact map popup for an airport
//

import SwiftUI

struct AirportDetailPopup: View {
    let airport: Airport
    let onAddToRoute: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(airport.name)
                        .font(.headline)
                    Text(airport.id)
                        .font(.title3)
                        .monospaced()
                        .foregroundStyle(.secondary)
                    Text(airport.country)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }

            if airport.connections.isEmpty {
                Text("No static outbound flights listed.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Connections")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ForEach(airport.connections.prefix(5)) { connection in
                        HStack {
                            Text(connection.destination.id)
                                .monospaced()
                            Text(connection.destination.name)
                                .lineLimit(1)
                            Spacer()
                            Text("\(connection.flights.count)")
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }
                        .font(.caption)
                    }
                }
            }

            Button("Add to Route", action: onAddToRoute)
                .buttonStyle(.borderedProminent)
        }
        .padding(14)
        .frame(width: 280)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        .shadow(radius: 10)
    }
}
