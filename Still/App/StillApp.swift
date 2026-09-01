//
//  StillApp.swift
//  Still
//
//  Created by 정홍섭 on 8/18/26.
//

import SwiftUI
import SwiftData

@main
struct StillApp: App {
    @State private var router = AppRouter()
    
    var body: some Scene {
        WindowGroup {
            StillTabView()
                .environment(router)
        }
        .modelContainer(for: MovieTicket.self)
    }
}
