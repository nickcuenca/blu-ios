//  MomentGridView.swift
//  Blu
//
//  Created by Nicolas Cuenca on 5/2/25.

import SwiftUI

struct MomentGridView: View {
    let sessionId: String
    let checkpointId: String
    @Binding var moments: [Moment]

    @State private var selectedMomentId: String?

    var body: some View {
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]

        VStack(alignment: .leading, spacing: 12) {
            Text("Moments")
                .font(.headline)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(moments) { moment in
                    Button {
                        selectedMomentId = moment.id
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            if let urlStr = moment.imageURL, let url = URL(string: urlStr) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 120)
                                        .clipped()
                                        .cornerRadius(8)
                                } placeholder: {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 120)
                                        .overlay(ProgressView())
                                }
                            } else {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 120)
                                    .overlay(Text("No Image").font(.caption))
                            }

                            Text(moment.caption)
                                .font(.caption)
                                .lineLimit(1)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .sheet(item: selectedMomentWrapper) { wrapper in
            MomentEditorView(
                sessionId: sessionId,
                checkpointId: checkpointId,
                moment: wrapper.moment,
                onDelete: {
                    moments.removeAll { $0.id == wrapper.moment.id }
                    selectedMomentId = nil
                },
                onUpdate: { newCaption in
                    if let index = moments.firstIndex(where: { $0.id == wrapper.moment.id }) {
                        moments[index].caption = newCaption
                    }
                }
            )
        }
    }

    private var selectedMomentWrapper: Binding<MomentIdentifiableWrapper?> {
        Binding<MomentIdentifiableWrapper?>(
            get: {
                guard let id = selectedMomentId,
                      let moment = moments.first(where: { $0.id == id }) else { return nil }
                return MomentIdentifiableWrapper(moment: moment)
            },
            set: { newValue in
                selectedMomentId = newValue?.moment.id
            }
        )
    }
}

struct MomentIdentifiableWrapper: Identifiable {
    let moment: Moment
    var id: String { moment.id }
}
