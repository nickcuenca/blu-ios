//  BluApp.swift
//  Blu
//
//  Created by Nicolas Cuenca on 3/27/25.

import SwiftUI
import Firebase

@main
struct BluApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            LauncherView()
        }
    }
}
