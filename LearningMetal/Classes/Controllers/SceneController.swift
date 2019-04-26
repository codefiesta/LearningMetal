//
//  SceneController.swift
//  LearningMetal
//
//  Created by Kevin McKee on 3/17/19.
//  Copyright © 2019 Procore. All rights reserved.
//

import ARKit
import MetalKit
import UIKit

class SceneController: UIViewController {

    var sceneDescriptor: SceneDescriptor?
    var sceneRenderer: SceneRenderer?
    
    @IBOutlet weak var mtkView: MTKView? {
        didSet {
            guard let mtkView = mtkView, let device = MTLCreateSystemDefaultDevice() else {
                print("😢 Metal not available")
                return
            }
            mtkView.device = device
        }
    }

    @IBOutlet weak var arScnView: ARSCNView? {
        didSet {
            guard let arScnView = arScnView else { return }
            arScnView.delegate = self
            arScnView.debugOptions = [.showPhysicsFields, .showFeaturePoints]
            arScnView.scene = SCNScene()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = sceneDescriptor?.sceneName
        prepareSceneRenderer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let descriptor = sceneDescriptor else { return }
        switch descriptor {
        case .arkit:
            arScnView?.session.run()
        default:
            break
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let descriptor = sceneDescriptor else { return }
        
        switch descriptor {
        case .arkit:
            arScnView?.session.pause()
        default:
            break
        }
    }

    /// Prepares the appropriate scene render to use based on the scene descriptor
    fileprivate func prepareSceneRenderer() {
        guard let descriptor = sceneDescriptor else { return }
        
        guard let mtkView = mtkView else {
            print("😢 Metal not available")
            return
        }
        switch descriptor {
        case .inflatableDucky:
            sceneRenderer = DuckyScene(mtkView)
            break
        case .fishes:
            sceneRenderer = FishScene(mtkView)
            break
        case .teapot:
            sceneRenderer = TeapotScene(mtkView)
            break
        case .gestures:
            sceneRenderer = DuckyGesturesScene(mtkView)
        case .arkit:
            sceneRenderer = ARScene(mtkView, session: arScnView?.session)
            break
        }
        
        // Initialize our renderer with the view size
        sceneRenderer?.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
    }
}

extension SceneController: ARSCNViewDelegate {
    
}
