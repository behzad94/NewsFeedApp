//
//  Colors.swift
//  DiveTest
//
//  Created by DIAKO on 5/11/20.
//  Copyright © 2020 Diako. All rights reserved.
//
import Foundation
import UIKit

struct Colors {
    static let mainColor = UIColor(r: 239, g: 77, b: 145)
    static let secondaryColor = UIColor(r: 248, g: 5, b: 86)
}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}

