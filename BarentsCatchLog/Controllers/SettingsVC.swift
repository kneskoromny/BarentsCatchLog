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
        CustomView.createDesign(for: saveNameRatioBtn, with: .systemBlue, and: "Сохранить")
        CustomView.createDesign(for: saveGradeBtn, with: .systemBlue, and: "Сохранить")
        CustomView.createDesign(for: showDefaultsBtn, with: .systemGreen, and: "Показать список")

    }
    
    // MARK: - IB Actions
    @IBAction func saveNameRatioBtnPressed() {
    }
    @IBAction func saveGradeBtnPressed() {
    }
    @IBAction func showDefaultsBtnPressed() {
    }
    

}
