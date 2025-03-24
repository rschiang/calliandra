//
//  AirportMapItem - Represents the annotation icon on map
//

import SwiftUI
import MapKit

struct AirportMapItem : View {
    var isMajor: Bool
    var isSelected: Bool

    var body: some View {
        Image(systemName: "airplane.circle.fill")
            .symbolRenderingMode(.palette)
            .foregroundStyle(
                isSelected ? Color.white : Color.accentColor,
                isSelected ? Color.accentColor : Color.accentColor.opacity(0.25))
            .imageScale((isMajor || isSelected) ? .large : .medium)
            .clipShape(Circle())
    }
}

#Preview {
    HStackLayout(spacing: 16) {
        AirportMapItem(isMajor: false, isSelected: false)
        AirportMapItem(isMajor: true, isSelected: false)
        AirportMapItem(isMajor: true, isSelected: true)
    }.padding(32)
}
