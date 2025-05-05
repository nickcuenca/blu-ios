//
//  CheckpointDetailView.swift
//  Blu
//
//  Created by Nicolas Cuenca on 3/27/25.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore

struct CheckpointDetailView: View {
    var sessionId: String
    @Binding var checkpoint: Checkpoint
    var participants: [String]

    @State private var expenses: [Expense] = []
    @State private var moments: [Moment] = []
    @State private var showingAddExpense = false
    @State private var showingAddMoment = false
    @State private var selectedMoment: Moment? = nil  // ✅ Editor sheet trigger

    let columns = [GridItem(.adaptive(minimum: 100), spacing: 12)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Location: \(checkpoint.location.latitude), \(checkpoint.location.longitude)")
                    .font(.caption)
                    .foregroundColor(.gray)

                if let time = checkpoint.time {
                    Text("Time: \(time.formatted(.dateTime.hour().minute()))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                // MARK: - Expenses
                if expenses.isEmpty {
                    Text("No expenses yet")
                        .foregroundColor(.gray)
                } else {
                    Text("Expenses").font(.headline)
                    ForEach(expenses) { expense in
                        VStack(alignment: .leading) {
                            Text(expense.title).bold()
                            Text("Amount: $\(expense.amount, specifier: "%.2f")")
                            Text("Paid by: \(expense.paidBy)")
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }

                Button("Add Expense") {
                    showingAddExpense = true
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                // MARK: - Moments
                if moments.isEmpty {
                    Text("No moments yet")
                        .foregroundColor(.gray)
                } else {
                    MomentGridView(
                        sessionId: sessionId,
                        checkpointId: checkpoint.id.uuidString,
                        moments: $moments
                    )
                }

                Button("Add Moment") {
                    showingAddMoment = true
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle(checkpoint.title)
        .onAppear {
            fetchExpenses()
            fetchMoments()
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(
                participants: participants,
                sessionId: sessionId,
                checkpointId: checkpoint.id.uuidString
            ) { newExpense in
                expenses.append(newExpense)
            }
        }
        .sheet(isPresented: $showingAddMoment) {
            AddMomentView(
                sessionId: sessionId,
                checkpointId: checkpoint.id.uuidString,
                checkpointTitle: checkpoint.title
            ) {
                fetchMoments()
            }
        }
    }

    // MARK: - Firebase Fetchers

    func fetchExpenses() {
        let db = Firestore.firestore()
        db.collection("hangoutSessions")
            .document(sessionId)
            .collection("checkpoints")
            .document(checkpoint.id.uuidString)
            .collection("expenses")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Failed to fetch expenses: \(error)")
                    return
                }

                guard let documents = snapshot?.documents else { return }

                do {
                    expenses = try documents.map { try $0.data(as: Expense.self) }
                } catch {
                    print("❌ Error decoding expenses: \(error)")
                }
            }
    }

    func fetchMoments() {
        let db = Firestore.firestore()
        db.collection("hangoutSessions")
            .document(sessionId)
            .collection("checkpoints")
            .document(checkpoint.id.uuidString)
            .collection("moments")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Failed to fetch moments: \(error)")
                    return
                }

                guard let documents = snapshot?.documents else { return }

                do {
                    moments = try documents.map { try $0.data(as: Moment.self) }
                } catch {
                    print("❌ Error decoding moments: \(error)")
                }
            }
    }
}
