//
//  RoutePlannerPane - Builds and summarizes an airport route
//

import SwiftUI

struct RoutePlannerPane: View {
    let model: Model
    @Binding var routeStops: [RouteStop]
    @Binding var airportCodeInput: String
    let inputError: String?
    let onSubmitAirportCode: () -> Void
    let onClearRoute: () -> Void

    @FocusState private var isAirportCodeFocused: Bool

    private var routePairs: [(index: Int, origin: Airport, destination: Airport)] {
        guard routeStops.count > 1 else { return [] }
        return routeStops.indices.dropLast().map { index in
            (index, routeStops[index].airport, routeStops[index + 1].airport)
        }
    }

    private var totalMiles: Int {
        routePairs.reduce(0) { total, pair in
            total + model.mileage(from: pair.origin, to: pair.destination).miles
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            airportInput
            routeStopsList
            routeSummary
            Spacer(minLength: 0)
        }
        .padding(16)
        .onAppear {
            isAirportCodeFocused = true
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Route Planner")
                .font(.title2)
                .bold()
            Text("Add airport codes or click an airport on the map.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

    private var airportInput: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                TextField("Airport code", text: $airportCodeInput)
                    .textFieldStyle(.roundedBorder)
                    .monospaced()
                    .focused($isAirportCodeFocused)
                    .onSubmit(onSubmitAirportCode)
                    .onChange(of: airportCodeInput) { _, newValue in
                        airportCodeInput = newValue.uppercased()
                    }

                Button("Add", action: onSubmitAirportCode)
                    .keyboardShortcut(.return, modifiers: [])
            }

            if let inputError {
                Text(inputError)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    private var routeStopsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Stops")
                    .font(.headline)
                Spacer()
                Button("Clear", action: onClearRoute)
                    .disabled(routeStops.isEmpty)
            }

            if routeStops.isEmpty {
                ContentUnavailableView(
                    "No Route Yet",
                    systemImage: "point.topleft.down.curvedto.point.bottomright.up",
                    description: Text("Enter airport codes to build a route.")
                )
                .frame(minHeight: 140)
            } else {
                List {
                    ForEach(Array(routeStops.enumerated()), id: \.element.id) { index, routeStop in
                        let airport = routeStop.airport
                        HStack {
                            Text("\(index + 1)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 22, alignment: .trailing)
                            VStack(alignment: .leading) {
                                Text(airport.id)
                                    .monospaced()
                                    .font(.headline)
                                Text(airport.name)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Image(systemName: "line.3.horizontal")
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .onDelete { offsets in
                        routeStops.remove(atOffsets: offsets)
                    }
                    .onMove { source, destination in
                        routeStops.move(fromOffsets: source, toOffset: destination)
                    }
                }
                .frame(minHeight: 140)
            }
        }
    }

    private var routeSummary: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Route")
                    .font(.headline)
                Spacer()
                Text("\(totalMiles) mi")
                    .font(.headline)
                    .monospacedDigit()
            }

            if routePairs.isEmpty {
                Text("Add at least two stops to see segment mileage and available flights.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(routePairs.indices, id: \.self) { index in
                            routeSegment(routePairs[index])
                        }
                    }
                }
            }
        }
    }

    private func routeSegment(_ pair: (index: Int, origin: Airport, destination: Airport)) -> some View {
        let flights = model.flights(from: pair.origin, to: pair.destination)
        let mileage = model.mileage(from: pair.origin, to: pair.destination)

        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("\(pair.origin.id) → \(pair.destination.id)")
                    .font(.headline)
                    .monospaced()
                Spacer()
                Text("\(mileage.miles) mi")
                    .font(.subheadline)
                    .monospacedDigit()
                if mileage.isEstimated {
                    Text("est.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if flights.isEmpty {
                Text("No static flights listed; using great-circle estimate.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(flights) { flight in
                    HStack(spacing: 8) {
                        Text(flight.departureTime)
                            .monospacedDigit()
                        Text(flightDuration(from: flight.departureTime, to: flight.arrivalTime) ?? "Duration unavailable")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(flight.miles) mi")
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                    .font(.caption)
                }
            }
        }
        .padding(10)
        .background(.quaternary.opacity(0.6), in: RoundedRectangle(cornerRadius: 10))
    }
}
