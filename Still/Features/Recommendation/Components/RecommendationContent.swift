//
//  RecommendationContent.swift
//  Still
//
//  Created by 정홍섭 on 8/30/26.
//

import SwiftUI

struct RecommendationContent: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            VStack(spacing: 10) {
                Image("name")
                
                Text("2024.02.22 · 2시간 13분")
                    .foregroundStyle(StillColors.Content.secondary)
                
                Text("미스터리 · 공포 · 스릴러")
                    .foregroundStyle(StillColors.Content.secondary)
            }
            .frame(maxWidth: .infinity)
            
            VStack(alignment: .leading, spacing: 32) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("줄거리")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(StillColors.Content.primary)
                    
                    Text("미국 LA, 거액의 의뢰를 받은 무당 화림과 봉길은 기이한 병이 대물림되는 집안의 장손을 만난다. 조상의 묫자리가 화근임을 알아챈 화림은 이장을 권하고, 돈 냄새를 맡은 최고의 풍수사 상덕과 장의사 영근이 합류한다. 절대 사람이 묻힐 수 없는 악지에 자리한 기이한 묘. 상덕은 불길한 기운을 느끼고 제안을 거절하지만, 화림의 설득으로 결국 파묘가 시작되고… 나와서는 안될 것이 나왔다.")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(StillColors.Content.secondary)
                        .lineLimit(nil)
                        .lineHeight(.exact(points: 22))
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .center, spacing: 14) {
                        Text("감독")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(StillColors.Accent.primary)
                        
                        Text("장재현")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(StillColors.Content.primary)
                    }
                    .frame(height: 32)
                    
                    HStack(alignment: .center, spacing: 14) {
                        Text("배우")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(StillColors.Accent.primary)
                        
                        Text("최민식 · 김고은 · 유해진 · 이도현")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(StillColors.Content.primary)
                    }
                    .frame(height: 32)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .background(StillColors.Surface.raised)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(StillColors.Border.subtle, lineWidth: 1)
                )
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("시청 가능한 곳")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(StillColors.Content.primary)

                        VStack(spacing: 0) {
                            Row("Netflix")
                            Row("TVING")
                        }
                        .background(StillColors.Surface.raised)
                        .cornerRadius(20)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 30)
    }
    
    private func Row(_ title: String) -> some View {
        HStack {
            HStack(spacing: 12) {
                Image(title.lowercased())
                    .resizable()
                    .frame(width: 32, height: 32)
                    .cornerRadius(8)
                    .scaledToFill()
                
                Text(title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(StillColors.Content.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 52)
            }
            
            Spacer()
            
            Button {
                // 이동 코드
            } label: {
                HStack(spacing: 4) {
                    Text("바로 보기")
                    
                    Image(systemName: "arrow.up.right")
                }
                .foregroundStyle(StillColors.Content.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
    }
}

#Preview {
    ScrollView {
        RecommendationContent()
    }
    .background(.black)
}
