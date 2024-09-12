//
//  DateItems.swift
//  IIDX
//
//  Created by umeme on 2022/08/24.
//  Copyright © 2022 umeme. All rights reserved.
//

import Foundation

enum DateItems {
    
    enum ThisMonth {
        struct Request {
            
            var year: Int
            var month: Int
            var day: Int
            var firstDay: Date
            var lastDay: Date
            
            init() {
                let calendar = Calendar(identifier: .gregorian)
                let date = calendar.dateComponents([.year, .month, .day], from: Date())
                year = date.year!
                month = date.month!
                day = date.day!
                
                // 月初
                firstDay = calendar.date(from: DateComponents(year: year, month: month))!
                let add1 = DateComponents(hour: 9)
                firstDay = calendar.date(byAdding: add1, to: firstDay)!
                
                // 月末
                var add2 = DateComponents(month: 1, day: -1)
                lastDay = calendar.date(byAdding: add2, to: firstDay)!
                add2 = DateComponents(hour: 23, minute: 59, second: 59)
                lastDay = calendar.date(byAdding: add2, to: lastDay)!
            }
        }
    }
    
    enum MoveMonth {
        struct Request {
            
            var year: Int
            var month: Int
            var firstDay: Date
            var lastDay: Date

            init(_ monthCounter: Int) {
                let calendar = Calendar(identifier: .gregorian)
                let date = calendar.date(byAdding: .month, value: monthCounter, to: Date())
                let newDate = calendar.dateComponents([.year, .month], from: date!)
                year = newDate.year!
                month = newDate.month!
                
                // 月初
                firstDay = calendar.date(from: DateComponents(year: year, month: month))!
                let add1 = DateComponents(hour: 9)
                firstDay = calendar.date(byAdding: add1, to: firstDay)!
                
                // 月末
                var add2 = DateComponents(month: 1, day: -1)
                lastDay = calendar.date(byAdding: add2, to: firstDay)!
                add2 = DateComponents(hour: 23, minute: 59, second: 59)
                lastDay = calendar.date(byAdding: add2, to: lastDay)!
            }
        }
    }
    
}
