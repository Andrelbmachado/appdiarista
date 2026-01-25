//
//  ServiceSelectionView.swift
//  Diarista facil
//
//  Created by André Machado on 20/01/26.
//

import SwiftUI

struct Service: Identifiable {
    let id = UUID()
    let name: String
    var isSelected: Bool = false

    var iconName: String {
        let lower = name.lowercased()
        if lower.contains("padr") { return "sparkles" }
        if lower.contains("pesad") { return "hammer" }
        if lower.contains("roup") { return "tshirt" }
        if lower.contains("vidr") { return "drop" }
        return "circle.grid.cross.left.filled" // generic
    }
}

struct ServiceSelectionView: View {
    @Binding var services: [Service]

    var body: some View {
        let columns = [GridItem(.adaptive(minimum: 140), spacing: 12)]
        LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
            ForEach(services.indices, id: \.self) { index in
                ServiceRow(service: $services[index])
            }
        }
    }

    private struct ServiceRow: View {
        @Binding var service: Service

        var body: some View {
            HStack {
                Label {
                    Text(service.name)
                        .foregroundColor(service.isSelected ? .white : .primary)
                } icon: {
                    Image(systemName: service.iconName)
                        .foregroundColor(service.isSelected ? .white : .blue)
                }
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(service.isSelected ? Color.blue : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.blue, lineWidth: service.isSelected ? 0 : 2)
                    )
            )
            .onTapGesture {
                service.isSelected.toggle()
            }
        }
    }
}

#Preview {
    ServiceSelectionView(services: .constant([
        Service(name: "Limpeza Padrão"),
        Service(name: "Limpeza Pesada"),
        Service(name: "Passar Roupa"),
        Service(name: "Limpeza de Vidros")
    ]))
}
