//
//  RegistrationSeatPicker.swift
//  Still
//

import SwiftUI

struct RegistrationSeatPicker: View {
    @Binding var selectedRow: String?
    @Binding var selectedNumber: Int?

    @State private var isPickerPresented = false
    @State private var draftRow: String?
    @State private var draftNumber: Int?

    var body: some View {
        RegistrationField(title: "좌석") {
            Button {
                draftRow = selectedRow
                draftNumber = selectedNumber
                isPickerPresented = true
            } label: {
                HStack(spacing: 12) {
                    Text(selectedSeatTitle)
                        .font(.still(.body))
                        .foregroundStyle(
                            hasSelectedSeat
                                ? StillColors.Content.primary
                                : StillColors.Content.teriary
                        )

                    Spacer()

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(StillColors.Content.secondary)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .sheet(isPresented: $isPickerPresented) {
            RegistrationPickerSheet(
                title: "좌석 선택",
                isConfirmationDisabled: draftRow == nil || draftNumber == nil,
                onCancel: { isPickerPresented = false },
                onConfirm: {
                    selectedRow = draftRow
                    selectedNumber = draftNumber
                    isPickerPresented = false
                }
            ) {
                HStack(spacing: 12) {
                    Picker("좌석 열", selection: $draftRow) {
                        Text("열 선택")
                            .font(.still(.body))
                            .foregroundStyle(StillColors.Content.primary)
                            .tag(nil as String?)

                        ForEach(SeatSelection.availableRows, id: \.self) { row in
                            Text("\(row)열")
                                .font(.still(.body))
                                .foregroundStyle(StillColors.Content.primary)
                                .tag(row as String?)
                        }
                    }
                    .pickerStyle(.wheel)
                    .environment(\.colorScheme, .dark)
                    .foregroundStyle(StillColors.Content.primary)
                    .tint(StillColors.Content.primary)
                    .frame(maxWidth: .infinity)

                    Picker("좌석 번호", selection: $draftNumber) {
                        Text("번호 선택")
                            .font(.still(.body))
                            .foregroundStyle(StillColors.Content.primary)
                            .tag(nil as Int?)

                        ForEach(SeatSelection.availableNumbers, id: \.self) { number in
                            Text("\(number)번")
                                .font(.still(.body))
                                .foregroundStyle(StillColors.Content.primary)
                                .tag(number as Int?)
                        }
                    }
                    .pickerStyle(.wheel)
                    .environment(\.colorScheme, .dark)
                    .foregroundStyle(StillColors.Content.primary)
                    .tint(StillColors.Content.primary)
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 24)
            }
        }
    }

    private var hasSelectedSeat: Bool {
        selectedRow != nil && selectedNumber != nil
    }

    private var selectedSeatTitle: String {
        guard let selectedRow, let selectedNumber else {
            return "좌석을 선택해 주세요"
        }

        return "\(selectedRow)열 \(selectedNumber)번"
    }
}
