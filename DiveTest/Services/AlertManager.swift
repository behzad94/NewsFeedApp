//
//  AlertManager.swift
//  DiveTest
//
//  Created by DIAKO on 5/11/20.
//  Copyright © 2020 Diako. All rights reserved.
//

import UIKit

class AlertManager {
    static func showDeleteAllAlert(vc: UIViewController, acceptAction: @escaping (() -> Void)) {
        let alertVC = UIAlertController(title: nil, message: "Are you shure?", preferredStyle: .alert)
        let declineAction = UIAlertAction(title: "No", style: .default)
        let acceptAction = UIAlertAction(title: "Yes", style: .default) { _ in
            acceptAction()
        }
        alertVC.addAction(acceptAction)
        alertVC.addAction(declineAction)
        vc.present(alertVC, animated: true)
    }
}
