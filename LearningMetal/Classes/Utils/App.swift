//
//  App.swift
//  LearningMetal
//
//  Created by Kevin McKee on 3/17/19.
//  Copyright © 2019 Procore. All rights reserved.
//

import UIKit

// Helper to configure the app
struct App {
    
    static func launch() {
        prepareAppearance()
    }
    
    static func terminate() {
        CoreDataStack.shared.saveContext()
    }

    /// Prepares overall app appearance
    fileprivate static func prepareAppearance() {
        // Hide the back button titles
        UIBarButtonItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .highlighted)
    }
    
}
