//
//  AlertController.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 14.09.2021.
//

import UIKit

class AlertController: UIAlertController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    // MARK: - Public Methods
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "OK",
                                       style: .default) { action in
            if let completion = completion {
                completion()
            }
        }
        alert.addAction(doneAction)
        present(alert, animated: true)
    }
 
}
