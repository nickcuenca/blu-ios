//
//  FullSummaryView.swift
//  Blu
//
//  Created by Nicolas Cuenca on 3/28/25.
//

import SwiftUI

struct FullSummaryView: View {
    let summary: [(String, Double, Double)] // (name, paid, owes)

    var body: some View {
        List(summary.indices, id: \.self) { index in
            let (name, paid, owes) = summary[index]
            let net = paid - owes

            HStack {
                VStack(alignment: .leading) {
                    Text(name)
                        .font(.headline)
                    Text("Paid: $\(paid, specifier: "%.2f") | Owes: $\(owes, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text("\(net >= 0 ? "+" : "")$\(net, specifier: "%.2f")")
                    .foregroundColor(net >= 0 ? .green : .red)
                    .bold()
            }
        }
        .navigationTitle("Summary")
    }
}
