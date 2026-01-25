//
//  Diarista_facilApp.swift
//  Diarista facil
//
//  Created by André Machado on 20/01/26.
//

import SwiftUI
import UIKit

@main
struct Diarista_facilApp: App {
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var appearanceSettings = AppearanceSettings()
    @StateObject var serviceBoard = ServiceBoard()
    
    init() {
        UITabBar.appearance().isHidden = false
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isLoggedIn {
                    ContentView()
                } else {
                    LoginView()
                }
            }
            .environmentObject(authViewModel)
            .environmentObject(appearanceSettings)
            .environmentObject(serviceBoard)
            .preferredColorScheme(appearanceSettings.colorScheme)
            .environment(\.dynamicTypeSize, appearanceSettings.dynamicType)
        }
    }
}
