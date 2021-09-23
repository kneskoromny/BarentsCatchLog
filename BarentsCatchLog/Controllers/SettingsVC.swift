//
//  SettingsVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 22.09.2021.
//

import UIKit

class SettingsVC: UIViewController {
    // MARK: - IB Outlets
    
    @IBOutlet weak var firstExplanationLabel: UILabel!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var ratioTF: UITextField!
    @IBOutlet weak var saveNameRatioBtn: UIButton!
    
    @IBOutlet weak var secondExplanationLabel: UILabel!
    @IBOutlet weak var gradeTF: UITextField!
    @IBOutlet weak var saveGradeBtn: UIButton!
    
    @IBOutlet weak var showDefaultsBtn: UIButton!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ratioTF.keyboardType = .decimalPad
        ratioTF.inputAccessoryView = createToolbar()
        gradeTF.inputAccessoryView = createToolbar()
        
//        CustomView.createDesign(for: saveNameRatioBtn, with: .systemBlue, and: "Сохранить")
//        CustomView.createDesign(for: saveGradeBtn, with: .systemBlue, and: "Сохранить")
//        CustomView.createDesign(for: showDefaultsBtn, with: .systemGreen, and: "Показать список")
        createUI()
    }
    
    // MARK: - IB Actions
    @IBAction func saveNameRatioBtnPressed() {
        guard let name = nameTF.text, let ratio = ratioTF.text else {
            showAlert()
            return }
        if name == "" || ratio == "" {
            showAlert()
            return
        }
        saveInputFish(with: name, and: ratio)
        nameTF.text = ""
        ratioTF.text = ""
        view.endEditing(true)
    }
    @IBAction func saveGradeBtnPressed() {
        guard let grade = gradeTF.text else {
            showAlert()
            return
        }
        if grade == "" {
            showAlert()
            return
        }
        print(grade)
        saveGrade(with: grade)
        gradeTF.text = ""
        
    }
    @IBAction func showDefaultsBtnPressed() {
    }
    
    // MARK: - Private Methods
    private func createUI() {
        CustomView.createDesign(for: firstExplanationLabel, with: """
            Внесите объекты промысла, с которыми работаете в данный момент.
            Если в процессе промысла появится новый, вы сможете добавить его отдельно.
            """)
        CustomView.createDesign(for: secondExplanationLabel, with: """
              Затем поочередно добавьте навески, они будут доступны для каждого объекта промысла.
            """)
        CustomView.createDesign(for: saveNameRatioBtn, with: .systemBlue, and: "Сохранить")
        CustomView.createDesign(for: saveGradeBtn, with: .systemBlue, and: "Сохранить")
        CustomView.createDesign(for: showDefaultsBtn, with: .systemGreen, and: "Показать внесенные данные")
    }
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
    private func saveInputFish(with name: String, and ratio: String) {
        guard let doubleRatio = Double(ratio) else { return }
        let inputFish = InputFish(fish: name, ratio: doubleRatio)
        StorageManager.shared.save(inputFish: inputFish)
    }
}
// MARK: - AlertController
extension SettingsVC {
    func showAlert(completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Внимание!",
                                      message: "Вы пытаетесь внести пустое значение.",
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
