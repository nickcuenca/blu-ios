//
//  AddExpenseView.swift
//  Blu
//
//  Created by Nicolas Cuenca on 3/27/25.
//

import SwiftUI

struct AddExpenseView: View {
    var participants: [String]
    var onAdd: (Expense) -> Void
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var amountText = ""
    @State private var paidBy = ""
    @State private var selectedParticipants: [String] = []
    @State private var splitType: SplitType = .equal
    @State private var customAmounts: [String: String] = [:]

    var totalAmount: Double? {
        Double(amountText)
    }

    var customSplitTotal: Double {
        selectedParticipants.reduce(0) { sum, person in
            sum + (Double(customAmounts[person] ?? "") ?? 0)
        }
    }

    var customSplitValid: Bool {
        guard let total = totalAmount else { return false }
        return abs(customSplitTotal - total) < 0.01
    }

    var isFormValid: Bool {
        guard !title.isEmpty,
              !amountText.isEmpty,
              !paidBy.isEmpty,
              !selectedParticipants.isEmpty else { return false }

        if splitType == .custom {
            return customSplitValid
        }

        return true
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Expense Info")) {
                    TextField("Title (e.g. Boba)", text: $title)
                    TextField("Amount", text: $amountText)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("Paid By")) {
                    Picker("Paid By", selection: $paidBy) {
                        ForEach(participants, id: \.self) {
                            Text($0)
                        }
                    }
                }

                Section(header: Text("Who Participated?")) {
                    ForEach(participants, id: \.self) { person in
                        Button(action: {
                            if selectedParticipants.contains(person) {
                                selectedParticipants.removeAll { $0 == person }
                            } else {
                                selectedParticipants.append(person)
                            }
                        }) {
                            HStack {
                                Text(person)
                                Spacer()
                                if selectedParticipants.contains(person) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }

                Section(header: Text("Split Type")) {
                    Picker("Split Type", selection: $splitType) {
                        Text("Equally").tag(SplitType.equal)
                        Text("Custom").tag(SplitType.custom)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                // MARK: - Custom Split UI
                if splitType == .custom && totalAmount != nil && !selectedParticipants.isEmpty {
                    Section(header: Text("Custom Amounts")) {
                        ForEach(selectedParticipants, id: \.self) { person in
                            HStack {
                                Text(person)
                                Spacer()
                                TextField("Amount", text: Binding(
                                    get: { customAmounts[person] ?? "" },
                                    set: { customAmounts[person] = $0 }
                                ))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                            }
                        }

                        HStack {
                            Text("Total Split:")
                            Spacer()
                            Text("$\(customSplitTotal, specifier: "%.2f")")
                                .foregroundColor(customSplitValid ? .green : .red)
                        }
                        .font(.caption)
                    }
                }

                Button("Add Expense") {
                    guard let amount = Double(amountText),
                          !title.isEmpty,
                          !paidBy.isEmpty,
                          !selectedParticipants.isEmpty else { return }

                    let breakdown: [String: Double]? = splitType == .custom
                        ? selectedParticipants.reduce(into: [:]) { dict, person in
                            if let value = Double(customAmounts[person] ?? "") {
                                dict[person] = value
                            }
                        }
                        : nil

                    let expense = Expense(
                        id: UUID(),
                        title: title,
                        amount: amount,
                        paidBy: paidBy,
                        splitType: splitType,
                        participants: selectedParticipants,
                        itemizedBreakdown: breakdown
                    )
                    onAdd(expense)
                    dismiss()
                }
                .disabled(!isFormValid)
            }
            .navigationTitle("New Expense")
        }
    }
}
