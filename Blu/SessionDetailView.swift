//  SessionDetailView.swift
//  Blu

import SwiftUI
import CoreLocation

struct SessionDetailView: View {
    @Binding var session: HangoutSession
    @AppStorage("username") var username: String = ""

    @State private var selectedCheckpoint: Checkpoint? = nil
    @State private var showAllSummary = false
    @State private var showAllSettleUp = false
    @State private var showEditHangout = false
    @State private var showingAddCheckpoint = false
    @State private var newCheckpointTitle = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        headerSection

                        if session.checkpoints.isEmpty {
                            Text("No checkpoints yet.")
                                .foregroundColor(.gray)
                                .padding(.top, 10)
                        } else {
                            ForEach(session.checkpoints) { checkpoint in
                                Button {
                                    selectedCheckpoint = checkpoint
                                } label: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(checkpoint.title)
                                                    .font(.headline)
                                                if let time = checkpoint.time {
                                                    Text(time, style: .time)
                                                        .font(.caption)
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(12)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }

                        if !session.checkpoints.flatMap({ $0.expenses }).isEmpty {
                            summarySection
                            Divider().padding(.vertical)
                            settleUpSection
                        }
                    }
                    .padding()
                }

                Button(action: {
                    showingAddCheckpoint = true
                }) {
                    Text("Add Checkpoint")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                }
            }
            .navigationTitle(session.title)
            .sheet(isPresented: $showingAddCheckpoint) {
                VStack(spacing: 20) {
                    Text("Add Checkpoint")
                        .font(.title2)
                    TextField("Checkpoint Title", text: $newCheckpointTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Button("Save") {
                        let newCheckpoint = Checkpoint(
                            title: newCheckpointTitle,
                            location: CLLocationCoordinate2D(latitude: 0, longitude: 0)
                        )
                        session.checkpoints.append(newCheckpoint)
                        newCheckpointTitle = ""
                        showingAddCheckpoint = false
                    }
                    .disabled(newCheckpointTitle.isEmpty)

                    Button("Cancel") {
                        newCheckpointTitle = ""
                        showingAddCheckpoint = false
                    }
                    .foregroundColor(.red)
                }
                .padding()
            }
            .sheet(isPresented: $showEditHangout) {
                EditHangoutView(hangout: $session, isEditing: true)
            }
            .navigationDestination(item: $selectedCheckpoint) { checkpoint in
                CheckpointDetailView(
                    checkpoint: binding(for: checkpoint),
                    participants: session.participants
                )
            }
        }
    }

    // MARK: - Binding Helper

    private func binding(for checkpoint: Checkpoint) -> Binding<Checkpoint> {
        guard let index = session.checkpoints.firstIndex(where: { $0.id == checkpoint.id }) else {
            fatalError("Checkpoint not found in session")
        }
        return $session.checkpoints[index]
    }

    // MARK: - Summary Helpers

    private func calculateSummary(for expense: Expense) -> [(String, (paid: Double, owes: Double))] {
        var summary: [String: (paid: Double, owes: Double)] = [:]

        for person in expense.participants {
            summary[person] = (0, 0)
        }

        for (person, amount) in expense.itemizedBreakdown ?? [:] {
            summary[person, default: (0, 0)].owes += amount
        }

        summary[expense.paidBy, default: (0, 0)].paid += expense.amount

        return summary.map { ($0.key, $0.value) }
    }

    private func calculateSettleUp(summary: [String: (paid: Double, owes: Double)]) -> [(String, String, Double)] {
        let netBalancesDict = summary.mapValues { $0.paid - $0.owes }
        let netBalances = netBalancesDict.map { ($0.key, $0.value) }

        var payers = netBalances.filter { $0.1 < 0 }
        var receivers = netBalances.filter { $0.1 > 0 }

        var result: [(String, String, Double)] = []

        for (payer, payerBalance) in payers {
            var payerOwes = -payerBalance
            var updatedReceivers: [(String, Double)] = []

            for (receiver, receiverBalance) in receivers {
                if payerOwes == 0 {
                    updatedReceivers.append((receiver, receiverBalance))
                    continue
                }

                let payment = min(receiverBalance, payerOwes)
                if payment > 0 {
                    result.append((payer, receiver, payment))
                    payerOwes -= payment
                    let remaining = receiverBalance - payment
                    if remaining > 0 {
                        updatedReceivers.append((receiver, remaining))
                    }
                }
            }

            receivers = updatedReceivers
        }

        return result
    }

    // MARK: - Sections

    private var headerSection: some View {
        HStack {
            Text(session.title)
                .font(.largeTitle.bold())
                .padding(.horizontal)
            Spacer()
            Button(action: {
                showEditHangout = true
            }) {
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Circle())
            }
        }
    }

    private var summarySection: some View {
        let allSummaries = session.checkpoints.flatMap { $0.expenses }.flatMap { calculateSummary(for: $0) }
        let summaryDict = Dictionary(grouping: allSummaries, by: { $0.0 }).mapValues {
            $0.reduce((paid: 0.0, owes: 0.0)) { partial, next in
                (partial.paid + next.1.paid, partial.owes + next.1.owes)
            }
        }
        let summaryList = summaryDict.map { ($0.key, $0.value.paid, $0.value.owes) }

        return VStack(alignment: .leading, spacing: 8) {
            Text("Summary").font(.headline)

            ForEach(summaryList.prefix(2), id: \.0) { name, paid, owes in
                let net = paid - owes
                HStack {
                    VStack(alignment: .leading) {
                        Text(name).font(.subheadline.bold())
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
        }
    }

    private var settleUpSection: some View {
        let allSummaries = session.checkpoints.flatMap { $0.expenses }.flatMap { calculateSummary(for: $0) }
        let summaryDict = Dictionary(grouping: allSummaries, by: { $0.0 }).mapValues {
            $0.reduce((paid: 0.0, owes: 0.0)) { partial, next in
                (partial.paid + next.1.paid, partial.owes + next.1.owes)
            }
        }
        let settlements = calculateSettleUp(summary: summaryDict)

        return VStack(alignment: .leading, spacing: 8) {
            Text("Settle Up").font(.headline)

            ForEach(settlements.prefix(2), id: \.0) { (payer, receiver, amount) in
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(payer) pays \(receiver)")
                        Text("➜ Pay via Venmo")
                            .foregroundColor(.blue)
                            .font(.caption)
                    }
                    Spacer()
                    Text("$\(amount, specifier: "%.2f")").bold()
                }
            }
        }
    }
}
