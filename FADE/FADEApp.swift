// FADEApp.swift
// FADE — Focus. Achieve. Dominate. Excel.
// A premium iOS productivity app

import SwiftUI

@main
struct FADEApp: App {
    @StateObject private var store = AppStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}
