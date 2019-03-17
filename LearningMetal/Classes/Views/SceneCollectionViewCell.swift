//
//  SceneCollectionViewCell.swift
//  LearningMetal
//
//  Created by Kevin McKee on 3/17/19.
//  Copyright © 2019 Procore. All rights reserved.
//

import UIKit

class SceneCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel?
    
    func prepare(_ descriptor: SceneDescriptor) {
        nameLabel?.text = descriptor.sceneName
    }
}
