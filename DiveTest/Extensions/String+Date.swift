//
//  String+Date.swift
//  DiveTest
//
//  Created by DIAKO on 5/12/20.
//  Copyright © 2020 smirnov. All rights reserved.
//

import Foundation

extension String {
    
    func StringDateToMediumDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        let date = dateFormatter.date(from: self)
        
        let mediumFormatter = DateFormatter()
        mediumFormatter.dateStyle = .medium
        let newDate = mediumFormatter.string(from: date!)
        return newDate
    }
}
