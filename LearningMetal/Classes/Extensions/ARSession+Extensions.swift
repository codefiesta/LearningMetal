//
//  ARSession+Extensions.swift
//  LearningMetal
//
//  Created by Kevin McKee on 4/25/19.
//  Copyright © 2019 Procore. All rights reserved.
//

import ARKit

extension ARSession {
    
    func run() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}
