//
//  AirportMapView - Lists and interacts with airports
//

import SwiftUI
import MapKit
import CoreLocation

struct AirportMapView: View {
    @StateObject var model = Model().load()
    @State private var position: MapCameraPosition = .automatic
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var selectedAirport: Airport?
    @State private var routeStops: [RouteStop] = []

    private var routePairs: [(index: Int, origin: Airport, destination: Airport)] {
        guard routeStops.count > 1 else { return [] }
        return routeStops.indices.dropLast().map { index in
            (index, routeStops[index].airport, routeStops[index + 1].airport)
        }
    }

    private var routeAirportIDs: Set<String> {
        Set(routeStops.map(\.airport.id))
    }

    private var suggestedConnectionIDs: Set<String> {
        guard let last = routeStops.last?.airport else { return [] }
        return Set(last.connections.map(\.destination.id))
    }

    var sidebar: some View {
        RoutePlannerPane(
            model: model,
            routeStops: $routeStops,
            onSubmitAirportCode: addAirportCodeToRoute,
            onClearRoute: clearRoute
        )
        .padding(.horizontal)
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebar
                .navigationSplitViewColumnWidth(min: 180, ideal: 240, max: 360)
        } detail: {
            ZStack(alignment: .bottomTrailing) {
                Map(position: $position, interactionModes: [.pan, .zoom], selection: $selectedAirport) {
                    selectedAirportConnections
                    plannedRoute
                    airportAnnotations
                }
                .ignoresSafeArea()
                .mapControls {
                    MapZoomStepper()
                }
                .mapStyle(.standard(
                    elevation: .realistic,
                    emphasis: .muted,
                    pointsOfInterest: .including([
                        .museum, .castle, .fortress, .landmark, .nationalMonument,
                        .nationalPark, .amusementPark, .aquarium,
                        .beach, .park, .zoo, .hiking, .publicTransport]),
                    showsTraffic: false
                ))

                if let selectedAirport {
                    AirportDetailPopup(
                        airport: selectedAirport,
                        onAddToRoute: { addAirportToRoute(selectedAirport) },
                        onDismiss: { self.selectedAirport = nil }
                    )
                    .padding(24)
                }
            }
        }
        .navigationSplitViewStyle(.prominentDetail)
        .onAppear {
            position = .region(model.coverage)
        }
        .onChange(of: selectedAirport) {
            updateMapPosition()
        }
        .onChange(of: routeStops) {
            updateMapPosition()
        }
    }

    @MapContentBuilder
    private var selectedAirportConnections: some MapContent {
        if let selectedAirport {
            ForEach(selectedAirport.connections) { connection in
                MapPolyline(coordinates: [
                    selectedAirport.coordinate,
                    connection.destination.coordinate,
                ], contourStyle: .geodesic)
                .stroke(.secondary.opacity(0.45), lineWidth: 0.5 + Double(min(max(connection.flights.count, 1), 6)) * 0.25)
            }
        }
    }

    @MapContentBuilder
    private var plannedRoute: some MapContent {
        ForEach(routePairs.indices, id: \.self) { index in
            let pair = routePairs[index]
            MapPolyline(coordinates: [
                pair.origin.coordinate,
                pair.destination.coordinate,
            ], contourStyle: .geodesic)
            .stroke(.orange, lineWidth: 3)
        }
    }

    @MapContentBuilder
    private var airportAnnotations: some MapContent {
        ForEach(model.airports) { airport in
            Annotation(airport.name, coordinate: airport.coordinate) {
                AirportMapItem(
                    isMajor: (airport.flights.count >= 10),
                    isSelected: (airport == selectedAirport),
                    isInRoute: routeAirportIDs.contains(airport.id),
                    isSuggestedConnection: suggestedConnectionIDs.contains(airport.id)
                )
            }
            .tag(airport)
        }
    }

    private func addAirportCodeToRoute(_ airportCode: String) {
        addAirportToRoute(model.airport(forCode: airportCode)!)
    }

    private func addAirportToRoute(_ airport: Airport) {
        guard routeStops.last?.airport.id != airport.id else { return }
        routeStops.append(RouteStop(airport: airport))
    }

    private func clearRoute() {
        routeStops.removeAll()
    }

    private func updateMapPosition() {
        withAnimation(.easeOut) {
            if let selectedAirport {
                if selectedAirport.flights.count > 0 {
                    position = .region(selectedAirport.coverage)
                }
            } else if routeStops.count > 1 {
                position = .region(findBound(from: routeStops[0].airport, for: routeStops.dropFirst().map(\.airport)))
            } else {
                position = .region(model.coverage)
            }
        }
    }
}

#Preview {
    AirportMapView()
}
