//
//  UIViewController+Additions.swift
//  SimpleBrowser
//
//  Created by Laura Esaian on 02.06.2021.
//

import UIKit

extension UIViewController {
    func askForAction(title: String? = nil, message: String? = nil, action: (() -> ())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: NSLocalizedString("YES", comment: ""), style: .default) { _ in
            action?()
        }
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}
