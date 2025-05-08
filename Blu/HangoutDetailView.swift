//
//  HangoutDetailView.swift
//  Blu
//
//  Created by Nicolas Cuenca on 5/7/25.
//

import SwiftUI
import FirebaseFirestore
import MapKit

struct HangoutDetailView: View {
    let hangout: HangoutSession

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(hangout.title)
                    .font(.largeTitle)
                    .bold()

                Label(
                    "\(hangout.location.latitude), \(hangout.location.longitude)",
                    systemImage: "mappin.and.ellipse"
                )
                .foregroundColor(.secondary)

                Label(
                    hangout.date.formatted(date: .abbreviated, time: .shortened),
                    systemImage: "calendar"
                )
                .foregroundColor(.secondary)

                Divider()

                Text("Participants")
                    .font(.headline)

                ForEach(hangout.participants, id: \.self) { name in
                    Label(name, systemImage: "person.fill")
                }

                // Optionally: show expenses or checkpoints
                if !hangout.expenses.isEmpty {
                    Divider()
                    Text("Expenses")
                        .font(.headline)
                    ForEach(hangout.expenses) { expense in
                        Text("• \(expense.title) - $\(expense.amount, specifier: "%.2f")")
                    }
                }

                if !hangout.checkpoints.isEmpty {
                    Divider()
                    Text("Checkpoints")
                        .font(.headline)
                    ForEach(hangout.checkpoints, id: \.id) { checkpoint in
                        Text("• \(checkpoint.title)")
                    }

                }
            }
            .padding()
        }
        .navigationTitle("Hangout Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
