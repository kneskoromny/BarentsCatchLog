//
//  SettingsVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 22.09.2021.
//

import UIKit

class SettingsVC: UIViewController, UITextFieldDelegate {
    // MARK: - IB Outlets
    
    @IBOutlet weak var firstExplanationLabel: UILabel!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var ratioTF: UITextField!
    @IBOutlet weak var saveNameRatioBtn: UIButton!
    
    @IBOutlet weak var secondExplanationLabel: UILabel!
    @IBOutlet weak var gradeTF: UITextField!
    @IBOutlet weak var saveGradeBtn: UIButton!
    
    @IBOutlet weak var showDefaultsBtn: UIButton!
    
    @IBOutlet weak var controlBottomConstraint: NSLayoutConstraint!

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTF.delegate = self
        gradeTF.delegate = self
        ratioTF.keyboardType = .decimalPad
        ratioTF.inputAccessoryView = createToolbar()
        
        createUI()
        
       
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    override func touchesBegan( _ touches: Set<UITouch>, with event: UIEvent?) {
             super.touchesBegan(touches, with: event)
            view.endEditing(true)
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
        saveGrade(with: grade)
        gradeTF.text = ""
        
    }
    @IBAction func showDefaultsBtnPressed() {
    }
    
    // MARK: - Public Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y -= keyboardSize.height / 2
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    @objc func doneAction() {
        view.endEditing(true)
    }
    
    // MARK: - Private Methods
    func parseNumber(_ text: String) -> Double? {
        let fmtUS = NumberFormatter()
        fmtUS.locale = Locale(identifier: "en_US")
        if let number = fmtUS.number(from: text)?.doubleValue {
            return number
        }

        let fmtCurrent = NumberFormatter()
        fmtCurrent.locale = Locale.current
        if let number = fmtCurrent.number(from: text)?.doubleValue {
            return number
        }
        return nil
    }
    private func createUI() {
        CustomView.createDesign(for: firstExplanationLabel, with: """
            Поочередно внесите объекты промысла, с которыми планируете работать.
            Если в процессе промысла появится новый, вы сможете добавить его отдельно.
            """)
        CustomView.createDesign(for: secondExplanationLabel, with: """
              Поочередно добавьте навески, они будут доступны для каждого объекта промысла.
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
    
    private func saveGrade(with grade: String) {
        StorageManager.shared.save(grade: grade)
    }
    private func saveInputFish(with name: String, and ratio: String) {
        guard let doubleRatio = parseNumber(ratio) else { return }
        print("doubleRatio: \(doubleRatio)")
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
