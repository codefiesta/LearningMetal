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
        case .building:
            break
        case .teapot:
            break
        case .cow:
            break
        }
        
        // Initialize our renderer with the view size
        sceneRenderer?.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
    }
}

// Gestures and hit detection
extension SceneController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        guard let location = touches.first?.location(in: view) else { return }
        print("Touches began @[\(location)]")
        
//        guard let scene = sceneRenderer?.scene else { return }
//        let node = scene.hitTest(at: location, in: view.bounds)
//        print("Hit at @[\(String(describing: node?.name))]")
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
//        guard let location = touches.first?.location(in: view), let previousLocation = touches.first?.previousLocation(in: view) else { return }
        
//        let x = location.x - previousLocation.x
//        let y = location.y - previousLocation.y
//        print("Touches moved [\(x), \(y)]")
        
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
    }

}

