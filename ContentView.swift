//
//  ContentView.swift
//  Diarista facil
//
//  Created by André Machado on 20/01/26.
//

import SwiftUI

struct ContentView: View {
    enum Tab {
        case history
        case home
        case marketplace
        case settings
    }

    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HistoryView()
                .tabItem {
                    Label("Serviços", systemImage: "doc.text")
                }
                .tag(Tab.history)

            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(Tab.home)

            MarketplaceView()
                .tabItem {
                    Label("Marketplace", systemImage: "cart")
                }
                .tag(Tab.marketplace)

            SettingsView()
                .tabItem {
                    Label("Conta", systemImage: "person.crop.circle")
                }
                .tag(Tab.settings)
        }
        .toolbar(.visible, for: .tabBar)
        .toolbarBackground(Color(.systemGray6), for: .tabBar)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(AppearanceSettings())
        .environmentObject(ServiceBoard())
}
