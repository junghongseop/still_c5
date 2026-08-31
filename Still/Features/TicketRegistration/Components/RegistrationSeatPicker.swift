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

    private let rows = (65...90).compactMap {
        UnicodeScalar($0).map { String(Character($0)) }
    }
    private let numbers = Array(1...99)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("좌석")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(StillColors.Content.secondary)

            Button {
                draftRow = selectedRow
                draftNumber = selectedNumber
                isPickerPresented = true
            } label: {
                HStack(spacing: 12) {
                    Text(selectedSeatTitle)
                        .font(.system(size: 17, weight: .regular))
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
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 64)
                .background(StillColors.Surface.raised)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(StillColors.Border.subtle, lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
        }
        .sheet(isPresented: $isPickerPresented) {
            NavigationStack {
                HStack(spacing: 12) {
                    Picker("좌석 열", selection: $draftRow) {
                        Text("열 선택")
                            .foregroundStyle(StillColors.Content.primary)
                            .tag(nil as String?)

                        ForEach(rows, id: \.self) { row in
                            Text("\(row)열")
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
                            .foregroundStyle(StillColors.Content.primary)
                            .tag(nil as Int?)

                        ForEach(numbers, id: \.self) { number in
                            Text("\(number)번")
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.clear)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("좌석 선택")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(StillColors.Content.primary)
                    }

                    ToolbarItem(placement: .cancellationAction) {
                        Button("취소") {
                            isPickerPresented = false
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("완료") {
                            selectedRow = draftRow
                            selectedNumber = draftNumber
                            isPickerPresented = false
                        }
                        .disabled(draftRow == nil || draftNumber == nil)
                    }
                }
            }
            .presentationDetents([.height(360)])
            .presentationBackground(StillColors.Surface.base)
            .presentationDragIndicator(.hidden)
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
