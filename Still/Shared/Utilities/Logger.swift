//
//  Logger.swift
//  Still
//
//  Created by 정홍섭 on 8/21/26.
//

import Foundation

enum Log {
    static func debug(
        _ message: Any...,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        let msg = message.map { "\($0)" }.joined(separator: " ")
        
        print("🐞 [\(fileName):\(line)] \(function) → \(msg)")
        #endif
    }
}
