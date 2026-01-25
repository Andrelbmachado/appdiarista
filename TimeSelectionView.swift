//
//  TimeSelectionView.swift
//  Diarista facil
//
//  Created by André Machado on 20/01/26.
//

import SwiftUI

struct TimeSelectionView: View {
    @Binding var selectedTime: Date

    var body: some View {
        DatePicker(
            "Selecione o horário",
            selection: $selectedTime,
            displayedComponents: .hourAndMinute
        )
        .datePickerStyle(.wheel)
        .labelsHidden()
        .padding()
        .background(cardBackgroundColor)
        .cornerRadius(20)
    }

    private var cardBackgroundColor: Color {
        #if os(macOS)
        return Color(NSColor.windowBackgroundColor)
        #else
        return Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(white: 1.0, alpha: 0.08) : UIColor.systemGray6
        })
        #endif
    }
}

#Preview {
    TimeSelectionView(selectedTime: .constant(Date()))
}
