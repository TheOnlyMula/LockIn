//
//  Configs.swift
//  LockIn2
//
//  Created by Multazim Mesbah on 14/1/2026.
//

import SwiftUI

enum AppTheme {
    static let solidBackground = Color(uiColor: UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor(red: 14/255, green: 12/255, blue: 22/255, alpha: 1)
        } else {
            return UIColor(red: 227/255, green: 174/255, blue: 99/255, alpha: 1)
        }
    })

    static let foregroundTextColor = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark ? .white : .black
    })
}
