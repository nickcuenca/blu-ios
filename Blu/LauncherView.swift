//
//  LauncherView.swift
//  Blu
//
//  Created by Nicolas Cuenca on 3/28/25.
//

import SwiftUI

struct LauncherView: View {
    @AppStorage("username") var username: String = ""

    var body: some View {
        if username.isEmpty {
            RegistrationViewV2()
        } else {
            TabBarView()
        }
    }
}
