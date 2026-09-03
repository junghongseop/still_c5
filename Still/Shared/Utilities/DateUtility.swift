//
//  DateUtility.swift
//  Still
//
//  Created by 정홍섭 on 8/26/26.
//

import Foundation

enum DateUtility {
    static var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }
    
    static func year(from dateString: String?) -> String? {
        guard let dateString else { return nil }
        
        return dateString
            .split(separator: "-")
            .first
            .map(String.init)
    }
}
