//
//  SceneCollectionViewController.swift
//  LearningMetal
//
//  Created by Kevin McKee on 3/17/19.
//  Copyright © 2019 Procore. All rights reserved.
//

import UIKit

enum SceneDescriptor: Int, CaseIterable {

    case inflatableDucky
    case fishes
    case teapot
    case gestures
    case arkit
    
    var sceneName: String? {
        switch self {
        case .inflatableDucky:
            return "Inflatable Ducky"
        case .fishes:
            return "Fishy"
        case .teapot:
            return "Teapot"
        case .gestures:
            return "Inflatable Ducky with Gesture Recognizers"
        case .arkit:
            return "ARKit"
        }
    }
}

class SceneCollectionViewController: UICollectionViewController {
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        guard let collectionView = collectionView, let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        coordinator.animate(alongsideTransition: { (context) in
            flowLayout.invalidateLayout()
            collectionView.layoutIfNeeded()
        }) { (context) in
            
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? SceneController, let indexPaths = collectionView.indexPathsForSelectedItems else {
            return
        }
        controller.sceneDescriptor = SceneDescriptor.allCases[indexPaths[0].row]
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SceneDescriptor.allCases.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let sceneDescriptor = SceneDescriptor.allCases[indexPath.row]
        let cellIdentifier = sceneDescriptor == .arkit ? "ARCell" : "Cell"

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? SceneCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.prepare(sceneDescriptor)
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension SceneCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return .zero
        }
        return flowLayout.headerReferenceSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var columns: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 3 : 2
        let orientation = UIApplication.shared.statusBarOrientation
        switch orientation {
        case .portrait, .portraitUpsideDown:
            columns = columns - 1
        default:
            break
        }
        let multiplier = (columns - 1)
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return .zero
        }
        
        let totalWidth = flowLayout.sectionInset.left + flowLayout.sectionInset.right +
            collectionView.contentInset.left + collectionView.contentInset.right + (flowLayout.minimumInteritemSpacing * multiplier)
        
        
        let width: CGFloat = CGFloat(floor((collectionView.frame.width - totalWidth) / columns))
        let height: CGFloat = width * 0.90 // The cells have a width x height ratio of 90%
        
        let size = CGSize(width: width, height: height)
        return size
    }
}
