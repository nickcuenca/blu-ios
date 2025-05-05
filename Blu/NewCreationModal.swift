//
//  NewCreationModal.swift
//  Blu
//
//  Created by Nicolas Cuenca on 5/2/25.
//

import SwiftUI

struct NewCreationModal: View {
    @Environment(\.dismiss) var dismiss
    @Binding var sessions: [HangoutSession]
    var onSessionCreated: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Button {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        print("🚧 Quick Add Expense not implemented yet.")
                    }
                } label: {
                    Label("Quick Add Expense (Coming Soon)", systemImage: "plus.circle")
                }

                Button {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let root = windowScene.windows.first?.rootViewController {
                            root.present(
                                UIHostingController(rootView: CreateHangoutViewWithLocation(sessions: $sessions, onHangoutCreated: onSessionCreated)),
                                animated: true
                            )
                        }
                    }
                } label: {
                    Label("Create Hangout", systemImage: "calendar.badge.plus")
                }
            }
            .navigationTitle("What would you like to add?")
        }
    }
}
