//
//  SSDVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 26.08.2021.
//

import UIKit
import CoreData


class ByTrawlsVC: UIViewController {
    //MARK: - IB Outlets
    @IBOutlet weak var numberOfTrawlTF: UITextField!
    
    @IBOutlet weak var timeOfShootingTF: UITextField!
    @IBOutlet weak var latitudeOfShootingTF: UITextField!
    @IBOutlet weak var longitudeOfShootingTF: UITextField!
    
    @IBOutlet weak var timeOfHoistingTF: UITextField!
    @IBOutlet weak var latitudeOfHoistingTF: UITextField!
    @IBOutlet weak var longitudeOfHoistingTF: UITextField!
    
    //MARK: - Public Properties
    lazy var coreDataStack = CoreDataStack(modelName: "BarentsCatchLog")
    
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
        let trawl = Trawl(context: coreDataStack.managedContext)
        var shootingTime: [String] = []
        var hoistingTime: [String] = []
        
        if let shootDateString = timeOfShootingTF.text {
            print(shootDateString)
            shootingTime = shootDateString.components(separatedBy: " ")
            print(shootingTime)
        }
        if let hoistDateString = timeOfHoistingTF.text {
            print(hoistDateString)
            hoistingTime = hoistDateString.components(separatedBy: " ")
            print(hoistingTime)
        }
        let dateShoot = shootingTime[0]
        let timeShoot = shootingTime[1]
        let dateHoist = hoistingTime[0]
        let timeHoist = hoistingTime[1]
        
        guard let id = numberOfTrawlTF.text,
              let latShoot = latitudeOfShootingTF.text,
              let lonShoot = longitudeOfShootingTF.text,
              let latHoist = latitudeOfHoistingTF.text,
              let lonHoist = longitudeOfHoistingTF.text else {
            
            self.showAlert()
            return
        }
        trawl.id = id
        trawl.date = Date()
        trawl.dateShoot = dateShoot
        trawl.timeShoot = timeShoot
        trawl.latitudeShoot = latShoot
        trawl.longitudeShoot = lonShoot
        trawl.dateHoist = dateHoist
        trawl.timeHoist = timeHoist
        trawl.latitudeHoist = latHoist
        trawl.longitudeHoist = lonHoist
        
        coreDataStack.saveContext()
        print(trawl)
    }
    
    @IBAction func deleteDataBtnPressed() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Trawl")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coreDataStack.managedContext.execute(batchDeleteRequest)
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
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
        if timeOfShootingTF.isFirstResponder {
            timeOfShootingTF.text = formatter.string(from: datePicker.date)
        }
        if timeOfHoistingTF.isFirstResponder {
            timeOfHoistingTF.text = formatter.string(from: datePicker.date)
        }
    }
    private func showAlert() {
        let alert = UIAlertController(title: "Повнимательнее!", message: "Заполните все поля для продолжения.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

}
