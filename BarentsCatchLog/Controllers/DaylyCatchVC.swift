//
//  ViewController.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 26.08.2021.
//

import UIKit
import CoreData

class DaylyCatchVC: UIViewController {
    
    //MARK: - IB Outlets
    @IBOutlet weak var fishTypeTF: UITextField!
    @IBOutlet weak var fishGradeTF: UITextField!
    @IBOutlet weak var frozenOnBoardTF: UITextField!
    
    //MARK: - Public Properties
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMM"
        return formatter
    }()
    lazy var coreDataStack = CoreDataStack(modelName: "BarentsCatchLog")
    
    //MARK: - Private Properties
    let arrayForFishTypePicker = ["",
                          FishTypes.cod.rawValue,
                          FishTypes.haddock.rawValue,
                          FishTypes.catfish.rawValue,
                          FishTypes.redfish.rawValue]
    
    let arrayForGradePicker = ["",
                               FishGrades.lessThanHalf.rawValue,
                               FishGrades.fromHalfToKilo.rawValue,
                               FishGrades.fromKiloToTwo.rawValue,
                               FishGrades.fromTwoToThree.rawValue,
                               FishGrades.fromThreeToFive.rawValue,
                               FishGrades.moreThanFive.rawValue]
    
    let pickerView = UIPickerView()
    
    private var yesterdayCatch: Fish?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Готовая продукция за"
        
        fishTypeTF.inputView = pickerView
        fishGradeTF.inputView = pickerView
        pickerView.delegate = self
        pickerView.dataSource = self
        
        frozenOnBoardTF.keyboardType = .decimalPad
    }
    // убирает окна при нажатии на экран
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //MARK: - IB Actions
    @IBAction func saveBtnPressed() {
        
        let fishCatch = Fish(context: coreDataStack.managedContext)
        guard let fishName = fishTypeTF.text,
              let fishGrade = fishGradeTF.text,
              let fishWeight = frozenOnBoardTF.text else { return }
        
        // запрос на существ рыбу для получения кол-ва готовой и сырой на вчерашний день
        let fetchRequest: NSFetchRequest<Fish> = Fish.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(Fish.name), fishName)
        do {
            yesterdayCatch = try coreDataStack.managedContext.fetch(fetchRequest).first
            print(yesterdayCatch?.date)
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
        
        fishCatch.name = fishName
        fishCatch.grade = fishGrade
        fishCatch.date = Date()
        
        switch fishName {
        case FishTypes.cod.rawValue:
            fishCatch.ratio = Ratios.cod.rawValue
        case FishTypes.haddock.rawValue:
            fishCatch.ratio = Ratios.haddock.rawValue
        case FishTypes.catfish.rawValue:
            fishCatch.ratio = Ratios.catfish.rawValue
        default:
            fishCatch.ratio = Ratios.redfish.rawValue
        }
        
        fishCatch.frozenBoard = Double(fishWeight)!
        fishCatch.frozenPerDay = fishCatch.frozenBoard - (yesterdayCatch?.frozenBoard ?? 0)
        fishCatch.rawBoard = (Double(fishCatch.frozenBoard) * fishCatch.ratio).rounded()
        fishCatch.rawPerDay = fishCatch.rawBoard - (yesterdayCatch?.rawBoard ?? 0)

        
        coreDataStack.saveContext()
        
        // вызывать аларм контроллер
        fishTypeTF.text = ""
        fishGradeTF.text = ""
        frozenOnBoardTF.text = ""
        fishTypeTF.becomeFirstResponder()
    }
    @IBAction func showOnBoardBtnPressed() {
    }
    // очищает Core Data
    @IBAction func deleteDataBtnPressed() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Fish")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try coreDataStack.managedContext.execute(batchDeleteRequest)
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
    }
    
}

//MARK: - Picker View Data Source, Delegate
extension DaylyCatchVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if fishTypeTF.isFirstResponder {
            return arrayForFishTypePicker.count
        } else {
            return arrayForGradePicker.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if fishTypeTF.isFirstResponder {
            return arrayForFishTypePicker[row]
        } else {
            return arrayForGradePicker[row]
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if fishTypeTF.isFirstResponder {
            switch row {
            case 0: fishTypeTF.text = arrayForFishTypePicker[0]
            case 1: fishTypeTF.text = arrayForFishTypePicker[1]
            case 2: fishTypeTF.text = arrayForFishTypePicker[2]
            case 3: fishTypeTF.text = arrayForFishTypePicker[3]
            default: fishTypeTF.text = arrayForFishTypePicker[4]
            }
        } else {
            switch row {
            case 0: fishGradeTF.text = arrayForGradePicker[0]
            case 1: fishGradeTF.text = arrayForGradePicker[1]
            case 2: fishGradeTF.text = arrayForGradePicker[2]
            case 3: fishGradeTF.text = arrayForGradePicker[3]
            case 4: fishGradeTF.text = arrayForGradePicker[4]
            default: fishGradeTF.text = arrayForGradePicker[5]
            }
        }
    }
}
extension Date {
    static var yesterday: Date { return Date().dayBefore }
    
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var noon: Date {
            return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
        }
}

