//
//  SSDVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 26.08.2021.
//

import UIKit


class ByTrawlsVC: UIViewController {
    //MARK: - IB Outlets
    @IBOutlet weak var numberOfTrawlTF: UITextField!
    
    @IBOutlet weak var timeOfShootingTF: UITextField!
    @IBOutlet weak var latitudeOfShootingTF: UITextField!
    @IBOutlet weak var longitudeOfShootingTF: UITextField!
    
    @IBOutlet weak var timeOfHoistingTF: UITextField!
    @IBOutlet weak var latitudeOfHoistingTF: UITextField!
    @IBOutlet weak var longitudeOfHoistingTF: UITextField!
    
    //MARK: - Private Properties
    private let datePicker = UIDatePicker()
    private let toolbar = UIToolbar()
    
    //MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.datePickerMode = .dateAndTime
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.minuteInterval = 30
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.sizeToFit()
        toolbar.setItems([flexSpace, doneBtn], animated: true)
        
        numberOfTrawlTF.keyboardType = .decimalPad
        numberOfTrawlTF.placeholder = "1"

        timeOfShootingTF.inputView = datePicker
        timeOfShootingTF.inputAccessoryView = toolbar
        timeOfShootingTF.placeholder = "0109 1200"
        
        latitudeOfShootingTF.keyboardType = .decimalPad
        latitudeOfShootingTF.placeholder = "7500"
        
        longitudeOfShootingTF.keyboardType = .decimalPad
        longitudeOfShootingTF.placeholder = "04500"
        
        timeOfHoistingTF.inputView = datePicker
        timeOfHoistingTF.inputAccessoryView = toolbar
        timeOfHoistingTF.placeholder = "0109 1600"
        
        latitudeOfHoistingTF.keyboardType = .decimalPad
        latitudeOfHoistingTF.placeholder = "7505"
        
        longitudeOfHoistingTF.keyboardType = .decimalPad
        longitudeOfHoistingTF.placeholder = "04515"
    }
    
    // убирает окна при нажатии на экран
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //MARK: - IB Actions
    @IBAction func saveBtnPressed() {
        if let timeDateString = timeOfShootingTF.text {
            print(timeDateString)
            let timeDateArray = timeDateString.components(separatedBy: " ")
            
            print(timeDateArray)
        }
    }
    
    //MARK: - Public Methods
    @objc func dateChanged() {
        getDateFromPicker()
    }
    @objc func doneAction() {
        view.endEditing(true)
    }
    
    //MARK: - Private Methods
    private func getDateFromPicker() {
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMM HHmm"
        timeOfShootingTF.text = formatter.string(from: datePicker.date)
    }

}
