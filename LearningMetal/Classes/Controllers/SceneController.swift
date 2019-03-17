//
//  SceneController.swift
//  LearningMetal
//
//  Created by Kevin McKee on 3/17/19.
//  Copyright © 2019 Procore. All rights reserved.
//

import MetalKit
import UIKit

class SceneController: UIViewController {

    var sceneDescriptor: SceneDescriptor?
    var sceneRenderer: SceneRenderer?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = sceneDescriptor?.sceneName
        prepareSceneRenderer()
    }

    /// Prepares the appropriate scene render to use based on the scene descriptor
    fileprivate func prepareSceneRenderer() {
        guard let descriptor = sceneDescriptor else { return }
        guard let mtkView = view as? MTKView, let device = MTLCreateSystemDefaultDevice() else {
            print("😢 Metal not available")
            return
        }
        mtkView.device = device
        
        switch descriptor {
        case .inflatableDucky:
            sceneRenderer = DuckyScene(mtkView)
            break
        case .fishes:
            sceneRenderer = FishScene(mtkView)
            break
        case .teapot:
            break
        }
        
        // Initialize our renderer with the view size
        sceneRenderer?.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
    }
}

// Gestures and hit detection
extension SceneController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let _ = touches.first?.location(in: view) else { return }
        super.touchesBegan(touches, with: event)
    }
}

