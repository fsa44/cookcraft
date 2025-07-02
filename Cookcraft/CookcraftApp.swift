//
//  CookcraftApp.swift
//  Cookcraft
//
//  Created by Fatmasarah Abdikadir on 04/06/2025.
//

import SwiftUI
import Firebase

@main
struct CookcraftApp: App {
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
