//
//  SwiftUIAuthApp.swift
//  SwiftUIAuth
//
//  Created by Swathi Karthikeyan on 4/12/24.
//


import SwiftUI
import Firebase

@main
struct SwiftUIAuthApp: App {
    @StateObject var viewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
        
        
    }
}
