//
//  AnalyseScanAssembly.swift
//  ScinCare
//
//  Created by Андрей Чернышев on 31.10.2024.
//

import UIKit
import AVFoundation

final class AnalyseScanAssembly {
    func scan(from: UIViewController, complete: @escaping (UIImage) -> Void) {
        let cameraAuthStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthStatus {
        case .authorized:
            startScanFlow(from: from, complete: complete)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] authorized in
                authorized ? self?.startScanFlow(from: from, complete: complete) : self?.notPermission(from: from)
            }
        default:
            notPermission(from: from)
        }
    }
}

// MARK: Private
private extension AnalyseScanAssembly {
    func startScanFlow(from: UIViewController, complete: @escaping (UIImage) -> Void) {
        let nc = NavigationController()
        nc.modalPresentationStyle = .fullScreen
        nc.setNavigationBarHidden(true, animated: false)
        
        let cameraVC = AnalyseCameraViewController.make { [weak nc] result in
            switch result {
            case .close:
                nc?.dismiss(animated: true)
            case .image(let image):
                let resizeVC = AnalyseImageResizeViewController.make(image: image) { [weak nc] result in
                    switch result {
                    case .image(let croppedImage):
                        from.dismiss(animated: true) {
                            complete(croppedImage)
                        }
                    case .retake, .back:
                        nc?.popViewController(animated: true)
                    }
                }
                nc?.pushViewController(resizeVC, animated: true)
            }
        }
        nc.setViewControllers([cameraVC], animated: false)
        
        from.present(nc, animated: true)
    }
    
    func notPermission(from: UIViewController) {
        let alert = UIAlertController(
            title: "AnalyseCamera.NotPermissions.Title".localized,
            message: "AnalyseCamera.NotPermissions.Text".localized,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK".localized, style: .cancel)
        alert.addAction(okAction)
        
        from.present(alert, animated: true)
    }
}
