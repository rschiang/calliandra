//
//  RoutePlannerPane - Builds and summarizes an airport route
//

import SwiftUI

struct RoutePlannerPane: View {
    let model: Model
    @Binding var routeStops: [RouteStop]
    @State private var airportCodeInput: String = ""
    let onSubmitAirportCode: (String) -> Void
    let onClearRoute: () -> Void

    private var totalMiles: Int {
        guard routeStops.count > 1 else { return 0 }
        var total = 0
        for index in 1..<routeStops.count {
            total += model.mileage(from: routeStops[index - 1].airport, to: routeStops[index].airport).miles
        }
        return total
    }

    private var airportCode: String {
        airportCodeInput.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    }

    private var isAirportCodeInvalid: Bool {
        !airportCode.isEmpty && suggestedAirports.isEmpty
    }

    private var suggestedAirports: [Airport] {
        guard !airportCode.isEmpty else { return [] }
        return model.airports.filter { $0.id.hasPrefix(airportCode) }
    }

    var body: some View {
        VStack(alignment: .leading) {
            header
            airportInput
            routeStopsList
        }
    }

    private var header: some View {
        HStack(spacing: 8) {
            Text(routeStops.isEmpty ? "Route" : "\(totalMiles) mi")
            Spacer()
            if !routeStops.isEmpty {
                Button("Clear", systemImage: "xmark", action: onClearRoute)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderless)
                    .disabled(routeStops.isEmpty)
            }
        }
        .font(.title2.weight(.semibold))
    }

    private var airportInput: some View {
        TextField("Airport code", text: $airportCodeInput)
            .safeAreaInset(edge: .leading) {
                Image(systemName: "magnifyingglass")
            }
            .monospaced()
            .autocorrectionDisabled()
            .onSubmit {
                let code = suggestedAirports.first?.id ?? airportCode
                guard routeStops.last?.airport.id != code else { return }
                guard code.count == 3 else { return }
                guard model.airport(forCode: code) != nil else { return }
                onSubmitAirportCode(code)
                airportCodeInput = ""
            }
            .onChange(of: airportCodeInput) { _, newValue in
                airportCodeInput = newValue.uppercased()
            }
            .textInputSuggestions {
                ForEach(suggestedAirports) { airport in
                    HStack {
                        Text(attributedAirportCode(code: airport.id))
                        Text(airport.name)
                            .foregroundStyle(.secondary)
                    }
                    .textInputCompletion(airport.id)
                }
            }
            .foregroundStyle(isAirportCodeInvalid ? Color.red : .primary)
    }

    private var routeStopsList: some View {
        List {
            ForEach(Array(routeStops.enumerated()), id: \.element.id) { index, routeStop in
                let airport = routeStop.airport
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "\(index + 1).circle")
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading) {
                            HStack {
                                Text(airport.id)
                                    .monospaced()
                                    .font(.headline)
                                Text(airport.name)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            if index > 0 {
                                let origin = routeStops[index - 1].airport
                                let destination = routeStop.airport
                                let mileage = model.mileage(from: origin, to: destination)
                                let flights = model.flights(from: origin, to: destination)
                                let duration = model.duration(from: origin, to: destination)

                                Text([
                                    "\(mileage.miles)mi",
                                    mileage.isEstimated ? "*" : "",
                                    duration != nil ? " ⸱ " : "",
                                    duration?.formatted(.units(allowed: [.hours, .minutes], width: .narrow)) ?? "",
                                ].joined(separator: ""))
                                .font(.caption)
                                .foregroundStyle(.secondary)

                                if flights.count > 0 {
                                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                                        ForEach(flights, id: \.id) { flight in
                                            Text(flight.departureTime)
                                                .padding(.horizontal, 2)
                                                .foregroundStyle(.tertiary)
                                                .background(.ultraThinMaterial)
                                                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                                        }
                                    }
                                    .font(.caption)
                                }
                            }
                        }
                        Spacer()
                        Button("Remove", systemImage: "xmark.circle.fill") {
                            routeStops.remove(at: index)
                        }
                            .foregroundStyle(.secondary)
                            .labelStyle(.iconOnly)
                            .buttonStyle(.borderless)
                        Image(systemName: "line.3.horizontal")
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .onDelete { offsets in
                routeStops.remove(atOffsets: offsets)
            }
            .onMove { source, destination in
                routeStops.move(fromOffsets: source, toOffset: destination)
            }
        }
    }

    private func attributedAirportCode(code: String) -> AttributedString {
        var marked = AttributedString(airportCode)
        var remaining = AttributedString(code.dropFirst(airportCode.count))
        marked.font = .body.monospaced().weight(.bold)
        remaining.font = .body.monospaced()
        return marked + remaining
    }
}

#Preview {
    @Previewable @State var model = Model().load()
    @Previewable @State var routeStops: [RouteStop] = []
    ZStack {
        RoutePlannerPane(
            model: model,
            routeStops: $routeStops,
            onSubmitAirportCode: {
                routeStops.append(RouteStop(airport: model.airport(forCode: $0)!))
            }, onClearRoute: {
                routeStops.removeAll()
            })
    }.padding()
}
