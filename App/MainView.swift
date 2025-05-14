//
//  MainView.swift
//  Blu
//
//  Created by Nicolas Cuenca on 3/27/25.
//

import SwiftUI

struct MainView: View {
    @AppStorage("username") var username: String = ""

    var body: some View {
        if username.isEmpty {
            RegistrationViewV2()
        } else {
            TabBarView()
        }
    }
}
