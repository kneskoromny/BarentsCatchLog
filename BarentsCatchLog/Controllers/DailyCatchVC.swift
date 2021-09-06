//
//  ViewController.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 26.08.2021.
//

import UIKit
import CoreData

protocol DateVCDelegate {
    func dateDidChanged(to date: Date)
}
protocol GradeTVCDelegate {
    func gradeDidChanged(to grade: String)
}
protocol FishTVCDelegate {
    func fishDidChanged(to fish: String)
}

class DailyCatchVC: UIViewController {
    
    //MARK: - IB Outlets
    //@IBOutlet weak var fishTypeTF: UITextField!
    //@IBOutlet weak var fishGradeTF: UITextField!
    @IBOutlet weak var frozenOnBoardTF: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: - Public Properties
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-YYYY"
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
    
    let arrayForTableView = ["Дата", "Рыба", "Навеска"]
    
    private let pickerView = UIPickerView()
    private let toolbar = UIToolbar()
    private var yesterdayCatch: Fish?
    
    private let cellIdentifier = "Cell"
    private let toDateIdentifier = "toDateVC"
    private let toGradeIdentifier = "toGradeTVC"
    private let toFishIdentifier = "toFishTVC"
    
    private var choozenDate = Date()
    private var choozenGrade: String?
    private var choozenFish: String?
    
    //MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.sizeToFit()
        toolbar.setItems([flexSpace, doneBtn], animated: true)
        
//        pickerView.delegate = self
//        pickerView.dataSource = self
        
        frozenOnBoardTF.keyboardType = .decimalPad
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == toDateIdentifier {
            if let dateVC = segue.destination as? DateVC {
                dateVC.delegate = self
            }
        } else if segue.identifier == toGradeIdentifier {
            if let navController = segue.destination as? GradeTVCNC {
                if let gradeTVC = navController.topViewController as? GradeTVC {
                    gradeTVC.delegate = self
                }
            }
        } else {
            if let navController = segue.destination as? FishTVCNC {
                if let fishTVC = navController.topViewController as? FishTVC {
                    fishTVC.delegate = self
                }
            }
        }
    }
    // убирает окна при нажатии на экран
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //MARK: - IB Actions
    @IBAction func saveBtnPressed() {
        // календарь с системной временной зоной
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.system
        
        // получаем начало и окончание вчерашнего дня
        let dateFrom = calendar.startOfDay(for: Date.yesterday)
        let dateTo = calendar.date(byAdding: .day, value: 1, to: dateFrom)
        // создаем экземпляр класса в контексте
        let fishCatch = Fish(context: coreDataStack.managedContext)
        guard let fishName = choozenFish,
              let fishGrade = choozenGrade,
              let fishWeight = frozenOnBoardTF.text else { return }
        
        // запрос на существ рыбу для получения кол-ва готовой и сырой на вчерашний день
        let fetchRequest: NSFetchRequest<Fish> = Fish.fetchRequest()
        // предикаты по названию и градации
        let namePredicate = NSPredicate(format: "%K == %@", #keyPath(Fish.name), fishName)
        let gradePredicate = NSPredicate(format: "%K == %@", #keyPath(Fish.grade), fishGrade)
        // предикаты по дате
        let fromPredicate = NSPredicate(format: "date >= %@", dateFrom as NSDate)
        let toPredicate = NSPredicate(format: "date < %@",  dateTo! as NSDate)
        // массив с предикатами
        let generalPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [namePredicate, gradePredicate, fromPredicate, toPredicate])
       
        fetchRequest.predicate = generalPredicate
        do {
            yesterdayCatch = try coreDataStack.managedContext.fetch(fetchRequest).first
            print("""
                Вчерашняя рыба - это \(yesterdayCatch?.name ?? "Вчера рыбы не было")
                Дата вчерашней рыбы - \(yesterdayCatch?.date)
                Навеска - \(yesterdayCatch?.grade ?? "Вчера рыбы не было")
                """
            )
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
        
        fishCatch.name = choozenFish
        print("Название внесенной рыбы - \(fishCatch.name!)")
        fishCatch.grade = choozenGrade
        print("Навеска внесенной рыбы - \(fishCatch.grade!)")
        fishCatch.date = choozenDate
        print("Дата внесенной рыбы - \(fishCatch.date!)")
        
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

        
        print(fishCatch)
        coreDataStack.saveContext()
        
        // вызывать аларм контроллер
        
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
    
    //MARK: - Public Methods
    @objc func doneAction() {
        view.endEditing(true)
    }  
}

//MARK: - Picker View Data Source, Delegate
//extension DailyCatchVC: UIPickerViewDelegate, UIPickerViewDataSource {
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        if fishTypeTF.isFirstResponder {
//            return arrayForFishTypePicker.count
//        } else {
//            return arrayForGradePicker.count
//        }
//    }
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        if fishTypeTF.isFirstResponder {
//            return arrayForFishTypePicker[row]
//        } else {
//            return arrayForGradePicker[row]
//        }
//    }
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//            switch row {
//            case 0: fishTypeTF.text = arrayForFishTypePicker[0]
//            case 1: fishTypeTF.text = arrayForFishTypePicker[1]
//            case 2: fishTypeTF.text = arrayForFishTypePicker[2]
//            case 3: fishTypeTF.text = arrayForFishTypePicker[3]
//            default: fishTypeTF.text = arrayForFishTypePicker[4]
//            }
//
//
//    }
//}
// MARK: - UITableViewDataSource
extension DailyCatchVC: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    arrayForTableView.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
    let object = arrayForTableView[indexPath.row]
    cell.textLabel?.text = object
    switch object {
    case "Дата":
        if choozenDate != Date() {
            let convertedDate = dateFormatter.string(from: choozenDate)
            cell.detailTextLabel?.text = String(describing: convertedDate)
        } else {
            cell.detailTextLabel?.text = "Сегодня"
        }
    case "Рыба":
        if choozenFish != nil {
            cell.detailTextLabel?.text = choozenFish
        } else {
            cell.detailTextLabel?.text = ""
        }
    default:
        if choozenGrade != nil {
            cell.detailTextLabel?.text = choozenGrade
        } else {
            cell.detailTextLabel?.text = ""
        }
    }
    return cell
  }
    
}
// MARK: - UITableViewDelegate
extension DailyCatchVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            performSegue(withIdentifier: toDateIdentifier, sender: nil)
        case 1:
            performSegue(withIdentifier: toFishIdentifier, sender: nil)
        default:
            performSegue(withIdentifier: toGradeIdentifier, sender: nil)
        }
    }
}
// MARK: - DateVC Delegate
extension DailyCatchVC: DateVCDelegate {
    func dateDidChanged(to date: Date) {
        self.choozenDate = date
        self.tableView.reloadData()
    }
}
// MARK: - GradeTVC Delegate
extension DailyCatchVC: GradeTVCDelegate {
    func gradeDidChanged(to grade: String) {
        self.choozenGrade = grade
        self.tableView.reloadData()
    }
}

// MARK: - FishTVC Delegate
extension DailyCatchVC: FishTVCDelegate {
    func fishDidChanged(to fish: String) {
        self.choozenFish = fish
        self.tableView.reloadData()
    }
}

// MARK: - Date
extension Date {
    static var yesterday: Date { return Date().dayBefore }
    static var dayBeforeYesterday: Date { return Date()}
    
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayBeforeYesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -2, to: noon)!
    }
    var noon: Date {
            return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
        }
}


