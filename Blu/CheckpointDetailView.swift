import SwiftUI
import FirebaseStorage
import FirebaseFirestore
import Foundation

struct CheckpointDetailView: View {
    @Binding var checkpoint: Checkpoint
    var participants: [String]

    @State private var showingAddExpense = false
    @State private var showingAddMoment = false

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

                if checkpoint.expenses.isEmpty {
                    Text("No expenses yet")
                        .foregroundColor(.gray)
                } else {
                    Text("Expenses").font(.headline)
                    ForEach(checkpoint.expenses) { expense in
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

                if !checkpoint.moments.isEmpty {
                    Text("Moments").font(.headline)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(checkpoint.moments) { moment in
                                VStack {
                                    if let data = moment.imageData,
                                       let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .frame(width: 120, height: 120)
                                            .cornerRadius(8)
                                    } else {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 120, height: 120)
                                            .cornerRadius(8)
                                            .overlay(Text("No Image").font(.caption))
                                    }
                                    Text(moment.caption).font(.caption)
                                }
                            }
                        }
                    }
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
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(participants: participants) { newExpense in
                checkpoint.expenses.append(newExpense)
            }
        }
        .sheet(isPresented: $showingAddMoment) {
            AddMomentView { newMoment in
                checkpoint.moments.append(newMoment)
                logToFeed(moment: newMoment, checkpoint: checkpoint)
            }
        }
    }
}
