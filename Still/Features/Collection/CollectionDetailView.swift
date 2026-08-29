//
//  CollectionDetailView.swift
//  Still
//
//  Created by 정홍섭 on 8/28/26.
//

import SwiftUI

struct CollectionDetailView: View {
    var body: some View {
        ZStack {
            Color.clear
                .background {
                    Image("spiderman")
                        .resizable()
                        .scaledToFill()
                }
                .clipped()
                .blur(radius: 5, opaque: true)
                .overlay {
                    StillColors.Surface.scrim
                }
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 95) {
                    MomentTicket(poster: "spiderman", logo: "logo")
                        .frame(maxWidth: 194)
                    
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("스파이더맨: 브랜드 뉴 데이")
                                .font(.system(size: 22, weight: .regular))
                                .foregroundColor(StillColors.Content.primary)
                            
                            Text("2026.08.14 · 극장 · ★ 4.5")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(StillColors.Content.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("그날의 한마디")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundColor(StillColors.Accent.primary)
                            
                            Text("오랜만에 극장에서 만난 영화.\n엔딩 크레딧까지 여운이 오래 남았다.")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(StillColors.Content.primary)
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(StillColors.Surface.raised)
                        .cornerRadius(22)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .inset(by: 0.5)
                                .stroke(StillColors.Border.subtle, lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity)
            }
            .padding(.top, 22)
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
        }
        .toolbarVisibility(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(Color(uiColor: .label))
                }
            }
        }
    }
}

#Preview {
    CollectionDetailView()
}
