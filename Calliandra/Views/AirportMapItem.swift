//
//  AirportMapItem - Represents the annotation icon on map
//

import SwiftUI
import MapKit

struct AirportMapItem : View {
    var isMajor: Bool
    var isSelected: Bool
    var isInRoute: Bool = false
    var isSuggestedConnection: Bool = false

    var body: some View {
        Image(systemName: "airplane.circle.fill")
            .symbolRenderingMode(.palette)
            .foregroundStyle(primaryColor, secondaryColor)
            .imageScale((isMajor || isSelected || isInRoute) ? .large : .medium)
            .clipShape(Circle())
    }

    private var primaryColor: Color {
        if isSelected || isInRoute {
            return .white
        }
        if isSuggestedConnection {
            return .orange
        }
        return .accentColor
    }

    private var secondaryColor: Color {
        if isInRoute {
            return .orange.opacity(isSelected ? 0.95 : 0.67)
        }
        if isSelected {
            return .accentColor
        }
        if isSuggestedConnection {
            return .orange.opacity(0.15)
        }
        return .accentColor.opacity(0.15)
    }
}

#Preview {
    HStackLayout(spacing: 16) {
        AirportMapItem(isMajor: false, isSelected: false)
        AirportMapItem(isMajor: true, isSelected: false)
        AirportMapItem(isMajor: true, isSelected: true)
        AirportMapItem(isMajor: true, isSelected: false, isInRoute: true)
        AirportMapItem(isMajor: true, isSelected: true, isInRoute: true)
        AirportMapItem(isMajor: true, isSelected: false, isSuggestedConnection: true)
    }.padding(32)
}
