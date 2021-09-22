//
//  SettingsVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 22.09.2021.
//

import UIKit

class SettingsVC: UIViewController {
    // MARK: - IB Outlets
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var ratioTF: UITextField!
    @IBOutlet weak var saveNameRatioBtn: UIButton!
    
    @IBOutlet weak var gradeTF: UITextField!
    @IBOutlet weak var saveGradeBtn: UIButton!
    
    @IBOutlet weak var showDefaultsBtn: UIButton!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ratioTF.keyboardType = .decimalPad
        ratioTF.inputAccessoryView = createToolbar()
        gradeTF.inputAccessoryView = createToolbar()
        
        CustomView.createDesign(for: saveNameRatioBtn, with: .systemBlue, and: "Сохранить")
        CustomView.createDesign(for: saveGradeBtn, with: .systemBlue, and: "Сохранить")
        CustomView.createDesign(for: showDefaultsBtn, with: .systemGreen, and: "Показать список")
        
    }
    
    // MARK: - IB Actions
    @IBAction func saveNameRatioBtnPressed() {
    }
    @IBAction func saveGradeBtnPressed() {
        guard let grade = gradeTF.text else {
            showAlert(title: "Внимание!", message: "Вы пытаетесь внести пустое значение.")
            return
        }
        if grade == "" {
            showAlert(title: "Внимание!", message: "Вы пытаетесь внести пустое значение.")
            return
        }
        print(grade)
        saveGrade(with: grade)
        gradeTF.text = ""
    }
    @IBAction func showDefaultsBtnPressed() {
    }
    
    // MARK: - Private Methods
    private func createToolbar() -> UIToolbar {
        let toolBar = UIToolbar()
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.items = [flexSpace, doneBtn]
        toolBar.sizeToFit()
        
        return toolBar
    }
    @objc private func doneAction() {
        view.endEditing(true)
    }
    private func saveGrade(with grade: String) {
        StorageManager.shared.save(grade: grade)
    }
}
// MARK: - AlertController
extension SettingsVC {
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
