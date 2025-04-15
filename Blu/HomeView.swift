//
//  HomeView.swift
//  Blu
//
//  Created by Nicolas Cuenca on 3/27/25.
//

import SwiftUI

struct HomeView: View {
    @Binding var sessions: [HangoutSession]

    @AppStorage("username") var username: String = ""
    @AppStorage("userEmail") var userEmail: String = ""
    @AppStorage("venmoUsername") var venmoUsername: String = ""
    @AppStorage("cashAppTag") var cashAppTag: String = ""
    @AppStorage("zelleInfo") var zelleInfo: String = ""
    @AppStorage("userProfileImageData") var userProfileImageData: Data?

    @State private var path: [String] = []

    var balances: [String: (paid: Double, owes: Double)] {
        var totals: [String: (paid: Double, owes: Double)] = [:]

        for session in sessions {
            for checkpoint in session.checkpoints {
                for expense in checkpoint.expenses {
                    let totalAmount = expense.amount
                    let participants = expense.participants
                    let owedAmountPerPerson: [String: Double] = {
                        switch expense.splitType {
                        case .equal:
                            let share = totalAmount / Double(participants.count)
                            return Dictionary(uniqueKeysWithValues: participants.map { ($0, share) })
                        case .custom:
                            return expense.itemizedBreakdown ?? [:]
                        }
                    }()
                    
                    for (person, amount) in owedAmountPerPerson {
                        totals[person, default: (0, 0)].owes += amount
                    }
                    
                    totals[expense.paidBy, default: (0, 0)].paid += totalAmount
                }
            }
        }

        return totals
    }

    var owedToOthers: [String] {
        let otherUsers = balances.keys.filter { $0 != username }
        return otherUsers.filter {
            let paidByThem = balances[$0]?.paid ?? 0
            let owedByYou = balances[username]?.owes ?? 0
            return owedByYou > paidByThem
        }
    }

    var othersOweYou: [String] {
        let otherUsers = balances.keys.filter { $0 != username }
        return otherUsers.filter {
            let paidByYou = balances[username]?.paid ?? 0
            let owesByThem = balances[$0]?.owes ?? 0
            return paidByYou > owesByThem
        }
    }

    var upcomingSessions: [HangoutSession] {
        sessions.filter { $0.date > Date() }.sorted(by: { $0.date < $1.date })
    }

    var pastSessions: [HangoutSession] {
        sessions.filter { $0.date <= Date() }.sorted(by: { $0.date > $1.date })
    }

    var body: some View {
        NavigationStack(path: $path) {
            List {
                // Quick Actions
                Section {
                    HStack {
                        NavigationLink("➕ New Hangout", destination: CreateHangoutViewWithLocation(sessions: $sessions))
                        Spacer()
                    }.padding(.vertical, 4)
                }

                // Upcoming Hangouts
                Section(header: Text("Upcoming Hangouts")) {
                    if upcomingSessions.isEmpty {
                        Text("No upcoming hangouts yet.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(upcomingSessions) { session in
                            if let index = sessions.firstIndex(where: { $0.id == session.id }) {
                                NavigationLink(destination: SessionDetailView(session: $sessions[index])) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(session.title).font(.headline)
                                        Text(session.date, style: .date)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                    }
                }

                // Balances
                Section(header: Text("Your Balances")) {
                    let current = balances[username] ?? (0, 0)
                    let net = current.paid - current.owes

                    HStack {
                        Text("You paid:")
                        Spacer()
                        Text(String(format: "$%.2f", current.paid))
                    }
                    HStack {
                        Text("You owe:")
                        Spacer()
                        Text(String(format: "$%.2f", current.owes))
                    }
                    HStack {
                        Text("Net balance:")
                        Spacer()
                        Text(String(format: "$%.2f", net))
                            .foregroundColor(net >= 0 ? .green : .red)
                    }

                    if !owedToOthers.isEmpty {
                        Text("You owe:").font(.subheadline)
                        ForEach(owedToOthers.prefix(2), id: \.self) { person in
                            let paid = balances[person]?.paid ?? 0
                            let owes = balances[username]?.owes ?? 0
                            let diff = paid - owes
                            HStack {
                                Text("\(person):")
                                Spacer()
                                Text(String(format: "$%.2f", abs(diff)))
                                    .foregroundColor(.red)
                            }
                        }
                        if owedToOthers.count > 2 {
                            NavigationLink("Show All", value: "youOweList")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }

                    if !othersOweYou.isEmpty {
                        Text("They owe you:").font(.subheadline)
                        ForEach(othersOweYou.prefix(2), id: \.self) { person in
                            let paid = balances[username]?.paid ?? 0
                            let owes = balances[person]?.owes ?? 0
                            let diff = paid - owes
                            HStack {
                                Text("\(person):")
                                Spacer()
                                Text(String(format: "$%.2f", abs(diff)))
                                    .foregroundColor(.green)
                            }
                        }
                        if othersOweYou.count > 2 {
                            NavigationLink("Show All", value: "theyOweYouList")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }

                // Past Hangouts (All Sessions)
                Section(header: Text("Past Hangouts")) {
                    if pastSessions.isEmpty {
                        Text("No sessions yet. Create a hangout!")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(pastSessions) { session in
                            if let index = sessions.firstIndex(where: { $0.id == session.id }) {
                                NavigationLink(destination: SessionDetailView(session: $sessions[index])) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(session.title).font(.headline)
                                        Text(session.date, style: .date).font(.subheadline).foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Home")
            .navigationDestination(for: String.self) { value in
                if value == "youOweList" {
                    PeopleBalanceDetailView(people: owedToOthers, balances: balances, username: username, isOwedToYou: false)
                } else if value == "theyOweYouList" {
                    PeopleBalanceDetailView(people: othersOweYou, balances: balances, username: username, isOwedToYou: true)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: ProfileViewEnhanced()) {
                        if let data = userProfileImageData, let image = UIImage(data: data) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle")
                                .font(.title2)
                        }
                    }
                }
            }
        }
    }
}
