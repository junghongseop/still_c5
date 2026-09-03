//
//  SettingView.swift
//  Still
//
//  Created by 정홍섭 on 8/19/26.
//

import SafariServices
import SwiftUI

struct SettingView: View {
    @State private var presentedLegalPage: LegalPage?

    private let termsOfServiceURL = URL(
        string: "https://sassy-cloth-fbe.notion.site/3d006046c66e8032b07ae228302d4e5f"
    )!
    private let privacyPolicyURL = URL(
        string: "https://sassy-cloth-fbe.notion.site/3d006046c66e8014948bea62057d910a"
    )!

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("설정")
                .foregroundStyle(StillColors.Content.primary)
                .font(.still(.display))
            
            VStack(alignment: .leading, spacing: 12) {
                Text("정보")
                    .font(.still(.title))
                    .foregroundStyle(StillColors.Content.primary)
                
                VStack(spacing: 0) {
                    Button {
                        presentedLegalPage = LegalPage(url: privacyPolicyURL)
                    } label: {
                        HStack {
                            Text("개인정보처리방침")
                                .font(.still(.headline))
                                .foregroundStyle(StillColors.Content.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(StillColors.Content.teriary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    
                    Rectangle()
                        .fill(StillColors.Border.subtle)
                        .frame(height: 1)
                    
                    Button {
                        presentedLegalPage = LegalPage(url: termsOfServiceURL)
                    } label: {
                        HStack {
                            Text("이용약관")
                                .font(.still(.headline))
                                .foregroundStyle(StillColors.Content.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(StillColors.Content.teriary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    
                    Rectangle()
                        .fill(StillColors.Border.subtle)
                        .frame(height: 1)
                    
                    HStack {
                        Text("앱 정보")
                            .font(.still(.headline))
                            .foregroundStyle(StillColors.Content.primary)
                        
                        Spacer()
                        
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-")
                            .font(.still(.label))
                            .foregroundStyle(StillColors.Content.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .background(StillColors.Surface.raised)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(StillColors.Border.subtle, lineWidth: 1)
                )
            }
        }
        .toolbarVisibility(.hidden, for: .tabBar)
        .screenLayoutStyle()
        .fullScreenCover(item: $presentedLegalPage) { page in
            SafariView(url: page.url)
                .ignoresSafeArea()
        }
    }
}

private struct LegalPage: Identifiable {
    let url: URL

    var id: URL { url }
}

private struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let viewController = SFSafariViewController(url: url)
        viewController.dismissButtonStyle = .close
        return viewController
    }

    func updateUIViewController(
        _ uiViewController: SFSafariViewController,
        context: Context
    ) {}
}

#Preview {
    SettingView()
}
