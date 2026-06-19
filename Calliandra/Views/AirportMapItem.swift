//
//  AirportMapItem - Represents the annotation icon on map
//

import SwiftUI
import MapKit

struct AirportMapItem : View {
    var isMajor: Bool
    var isSelected: Bool
    var isInRoute: Bool = false
    var isLastRouteStop: Bool = false
    var isSuggestedConnection: Bool = false

    var body: some View {
        Image(systemName: "airplane.circle.fill")
            .symbolRenderingMode(.palette)
            .foregroundStyle(
                foregroundColor,
                backgroundColor)
            .imageScale((isMajor || isSelected || isInRoute || isLastRouteStop) ? .large : .medium)
            .clipShape(Circle())
    }

    private var foregroundColor: Color {
        if isSelected || isLastRouteStop {
            return .white
        }
        if isInRoute || isSuggestedConnection {
            return .accentColor
        }
        return .accentColor
    }

    private var backgroundColor: Color {
        if isLastRouteStop {
            return .orange
        }
        if isSelected {
            return .accentColor
        }
        if isInRoute {
            return .accentColor.opacity(0.55)
        }
        if isSuggestedConnection {
            return .orange.opacity(0.35)
        }
        return .accentColor.opacity(0.25)
    }
}

#Preview {
    HStackLayout(spacing: 16) {
        AirportMapItem(isMajor: false, isSelected: false)
        AirportMapItem(isMajor: true, isSelected: false)
        AirportMapItem(isMajor: true, isSelected: true)
        AirportMapItem(isMajor: true, isSelected: false, isInRoute: true)
        AirportMapItem(isMajor: true, isSelected: false, isLastRouteStop: true)
    }.padding(32)
}
