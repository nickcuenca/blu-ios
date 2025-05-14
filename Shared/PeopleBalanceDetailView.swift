//
//  PeopleBalanceDetailView.swift
//  Blu
//
//  Created by Nicolas Cuenca on 3/28/25.
//

import SwiftUI

struct PeopleBalanceDetailView: View {
    var people: [String]
    var balances: [String: (paid: Double, owes: Double)]
    var username: String
    var isOwedToYou: Bool

    var body: some View {
        List(people, id: \.self) { person in
            let paid = balances[isOwedToYou ? username : person]?.paid ?? 0
            let owes = balances[isOwedToYou ? person : username]?.owes ?? 0
            let diff = paid - owes

            HStack {
                Text(person)
                Spacer()
                Text(String(format: "$%.2f", abs(diff)))
                    .foregroundColor(isOwedToYou ? .green : .red)
            }
        }
        .navigationTitle(isOwedToYou ? "People Who Owe You" : "People You Owe")
    }
}
