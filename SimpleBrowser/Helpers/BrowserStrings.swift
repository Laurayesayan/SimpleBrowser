//
//  BrowserStrings.swift
//  SimpleBrowser
//
//  Created by Laura Esaian on 01.06.2021.
//

import Foundation

enum BrowserStrings {
    case searchBarPlaceholder
    case generalError
    case startingPage
    
    func getString() -> String {
        switch self {
        case .searchBarPlaceholder:
            return NSLocalizedString("SEARCH_BAR_PLACEHOLDER", comment: "")
        case .generalError:
            return NSLocalizedString("GENERAL_ERROR_TITLE", comment: "")
        case .startingPage:
            return "https://www.google.com"
        }
    }
}
