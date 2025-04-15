//
//  FullSettleUpView.swift
//  Blu
//
//  Created by Nicolas Cuenca on 3/28/25.
//

import SwiftUI

struct FullSettleUpView: View {
    let settlements: [(String, String, Double)]

    var body: some View {
        List(settlements.indices, id: \.self) { index in
            let (from, to, amount) = settlements[index]
            HStack {
                VStack(alignment: .leading) {
                    Text("\(from) pays \(to)")
                    Text("→ Pay via Venmo")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
                Spacer()
                Text("$\(amount, specifier: "%.2f")")
                    .bold()
            }
        }
        .navigationTitle("Settle Up")
    }
}
