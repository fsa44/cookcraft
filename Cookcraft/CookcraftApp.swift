//
//  CookcraftApp.swift
//  Cookcraft
//
//  Created by Fatmasarah Abdikadir on 04/06/2025.
//
//
//import SwiftUI
//import Firebase
//
//@main
//struct CookcraftApp: App {
//    init(){
//        FirebaseApp.configure()
//    }
//    
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}


import SwiftUI
import Firebase

@main
struct CookcraftApp: App {
    @State private var showingSplash = true

    init() {
        FirebaseApp.configure() // Firebase initialization
    }

    var body: some Scene {
        WindowGroup {
            if showingSplash {
                // Show the splash screen first
                SplashView {
                    withAnimation {
                        showingSplash = false
                    }
                }
                .transition(.opacity) // Optional fade effect for splash screen
            } else {
                // Once splash is done, show the main content
                ContentView()
            }
        }
    }
}
