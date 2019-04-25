//
//  ARSceneController.swift
//  LearningMetal
//
//  Created by Kevin McKee on 4/25/19.
//  Copyright © 2019 Procore. All rights reserved.
//

import ARKit

class ARSceneController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView? {
        didSet {
            guard let sceneView = sceneView else { return }
            sceneView.delegate = self
            sceneView.debugOptions = [.showFeaturePoints]
            sceneView.scene = SCNScene()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ARKit"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneView?.session.run()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView?.session.pause()
    }
}

extension ARSceneController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
    }
}

extension ARSession {

    func run() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}
