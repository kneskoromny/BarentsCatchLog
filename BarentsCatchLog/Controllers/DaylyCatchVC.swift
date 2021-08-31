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
    @IBOutlet weak var frozenOnBoardTF: UITextField!
    
    //MARK: - Public Properties
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMM"
        return formatter
    }()
    lazy var coreDataStack = CoreDataStack(modelName: "BarentsCatchLog")
    
    //MARK: - Private Properties
    let arrayForPicker = ["",
                          FishTypes.cod.rawValue,
                          FishTypes.haddock.rawValue,
                          FishTypes.catfish.rawValue,
                          FishTypes.redfish.rawValue]
    
    let pickerView = UIPickerView()
    
    private var yesterdayCatch: Fish?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Готовая продукция за"
        
        fishTypeTF.inputView = pickerView
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
        guard let fishName = fishTypeTF.text, let fishWeight = frozenOnBoardTF.text else { return }
        
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
        fishCatch.rawBoard = Double(fishCatch.frozenBoard) * fishCatch.ratio
        fishCatch.rawPerDay = fishCatch.rawBoard - (yesterdayCatch?.rawBoard ?? 0)

        
        coreDataStack.saveContext()
        
        // вызывать аларм контроллер
        fishTypeTF.text = ""
        frozenOnBoardTF.text = ""
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
        return arrayForPicker.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        arrayForPicker[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row {
        case 0: fishTypeTF.text = arrayForPicker[0]
        case 1: fishTypeTF.text = arrayForPicker[1]
        case 2: fishTypeTF.text = arrayForPicker[2]
        case 3: fishTypeTF.text = arrayForPicker[3]
        default: fishTypeTF.text = arrayForPicker[4]
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

