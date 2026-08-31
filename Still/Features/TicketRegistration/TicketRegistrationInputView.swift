//
//  TicketRegistrationInputView.swift
//  Still
//

import SwiftUI

struct TicketRegistrationInputView: View {
    @State private var viewModel: TicketRegistrationInputViewModel

    init(context: TicketRegistrationContext) {
        _viewModel = State(
            initialValue: TicketRegistrationInputViewModel(context: context)
        )
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        ZStack {
            StillColors.Surface.base
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    RegistrationHeader(
                        title: viewModel.headerTitle,
                        subtitle: viewModel.headerDescription
                    )

                    VStack(spacing: 20) {
                        RegistrationValueField(
                            title: "영화",
                            value: viewModel.movieTitle
                        )

                        RegistrationDatePicker(
                            title: viewModel.place == .theater
                                ? "관람일"
                                : "시청일",
                            selection: $viewModel.watchedDate
                        )

                        switch viewModel.place {
                        case .theater:
                            RegistrationOptionPicker(
                                title: "영화관",
                                placeholder: "영화관을 선택해 주세요",
                                selection: $viewModel.selectedTheater
                            )

                            RegistrationSeatPicker(
                                selectedRow: $viewModel.selectedSeatRow,
                                selectedNumber: $viewModel.selectedSeatNumber
                            )

                        case .home:
                            RegistrationOptionPicker(
                                title: "플랫폼",
                                placeholder: "플랫폼을 선택해 주세요",
                                selection: $viewModel.selectedPlatform
                            )
                        }
                    }
                }
                .padding(.top, 16)
                .padding(.horizontal, 24)
                .padding(.bottom, 12)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                Log.debug("Registration draft:", viewModel.draft)
            } label: {
                Text("입력한 정보로 등록")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(StillColors.Content.onAccent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(StillColors.Accent.strong)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(StillColors.Surface.base)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .toolbarVisibility(.visible, for: .navigationBar)
        .toolbarVisibility(.hidden, for: .tabBar)
    }
}

#Preview("Theater Movie") {
    NavigationStack {
        TicketRegistrationInputView(
            context: TicketRegistrationContext(
                place: .theater,
                draft: TicketRegistrationDraft(
                    movieTitle: "스파이더맨: 브랜드 뉴 데이",
                    theater: "CGV",
                    seat: "H열 09번"
                )
            )
        )
    }
}

#Preview("Home Movie") {
    NavigationStack {
        TicketRegistrationInputView(
            context: TicketRegistrationContext(
                place: .home,
                draft: TicketRegistrationDraft(
                    movieTitle: "패스트 라이브즈"
                )
            )
        )
    }
}
