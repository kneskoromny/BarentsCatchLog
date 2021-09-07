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
    
    let arrayForTableView = ["Дата", "Рыба", "Навеска"]
    
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
        
        frozenOnBoardTF.keyboardType = .decimalPad
    }
    // передаем делегатов в контроллеры
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
        
        // получаем начало и окончание дня внесения улова
        guard let dayBeforeCurrentDay = calendar.date(
                byAdding: .day,
                value: -1,
                to: choozenDate
        ) else { return }
        let dateFrom = calendar.startOfDay(for: dayBeforeCurrentDay)
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
   
}

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
            cell.detailTextLabel?.text = ">"
        }
    default:
        if choozenGrade != nil {
            cell.detailTextLabel?.text = choozenGrade
        } else {
            cell.detailTextLabel?.text = ">"
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
// ПОДУМАТЬ КАК СДЕЛАТЬ ЧЕРЕЗ <T>
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
    static var dayBeforeYesterday: Date { return Date().dayBeforeYesterday }
    
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

