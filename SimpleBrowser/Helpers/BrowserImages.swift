//
//  BrowserImages.swift
//  SimpleBrowser
//
//  Created by Laura Esaian on 02.06.2021.
//

import UIKit

enum BrowserImages {
    case goBack
    case goForward

    func getImage() -> UIImage {
        switch self {
        case .goBack:
            return UIImage(systemName: "chevron.backward")!
        case .goForward:
            return UIImage(systemName: "chevron.forward")!
        }
    }
}
