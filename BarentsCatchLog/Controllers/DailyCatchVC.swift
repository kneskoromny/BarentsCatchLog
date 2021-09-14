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
    func valueDidChanged(to grade: String)
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
    let arrayForTableView = ["Дата", "Рыба", "Навеска"]
    
    private var catchForDayBeforeInput: Fish?
    
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
    
    //MARK: - Navigation
    // передаем делегатов в контроллеры
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == toDateIdentifier {
            if let dateVC = segue.destination as? DateVC {
                dateVC.choozenDate = choozenDate
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
        // получаем начало и окончание дня внесения улова
        guard let dayBeforeCurrentDay = Calendar.current.date(
                byAdding: .day,
                value: -1,
                to: choozenDate
        ) else { return }
        
        // создаем экземпляр класса в контексте
        let fishCatch = Fish(context: coreDataStack.managedContext)

        guard let fishName = choozenFish,
              let fishGrade = choozenGrade,
              let fishWeight = frozenOnBoardTF.text else {
            showAlert(title: "Пустые поля!",
                      message: "Необходимо заполнить все поля перед сохранением.")
            return }
        if fishWeight == "" {
            showAlert(title: "Пустые поля!",
                      message: "Необходимо заполнить все поля перед сохранением.")
            return
        }
        // запрос на существ рыбу с предикатами
        let fetchRequest: NSFetchRequest<Fish> = Fish.fetchRequest()
        fetchRequest.predicate = FormulaStack().getNameGradeDatePredicate(for: fishName, grade: fishGrade, date: dayBeforeCurrentDay)
        
        do {
            catchForDayBeforeInput = try coreDataStack.managedContext.fetch(fetchRequest).first
            print("""
                Вчерашняя рыба - это \(catchForDayBeforeInput?.name ?? "За день до внесения рыбы не было")
                Дата вчерашней рыбы - \(String(describing: catchForDayBeforeInput?.date!))
                Навеска - \(catchForDayBeforeInput?.grade ?? "За день до внесения рыбы не было")
                """
            )
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
        if let lastCatch = catchForDayBeforeInput?.onBoard,
           let doubleFishWeight = Double(fishWeight) {
            if doubleFishWeight < lastCatch {
                showAlert(title: "Внимание!",
                          message: "Количество вносимой продукции на борту меньше ранее внесенного.") {
                    self.frozenOnBoardTF.becomeFirstResponder()
                    self.frozenOnBoardTF.text = ""
                }
            }
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
        
        fishCatch.onBoard = Double(fishWeight)!
        fishCatch.perDay = fishCatch.onBoard - (catchForDayBeforeInput?.onBoard ?? 0)

        //showAlertBeforeSave(fishName: fishName, fishGrade: fishGrade, fishWeight: fishWeight)
        self.coreDataStack.saveContext()
        self.choozenDate = Date()
        self.choozenFish = nil
        self.choozenGrade = nil
        self.frozenOnBoardTF.text = nil
        self.tableView.reloadData()
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
// ПОДУМАТЬ КАК СДЕЛАТЬ ЧЕРЕЗ <T>
extension DailyCatchVC: DateVCDelegate {
    func dateDidChanged(to date: Date) {
        self.choozenDate = date
        self.tableView.reloadData()
    }
}
// MARK: - GradeTVC Delegate
extension DailyCatchVC: GradeTVCDelegate {
    func valueDidChanged(to grade: String) {
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

// MARK: - AlertController {
extension DailyCatchVC {
    func showAlertBeforeSave(fishName: String, fishGrade: String, fishWeight: String) {
        let alert = UIAlertController(title: "Подтвердите",
                                      message: """
                                        Вы вносите:
                                        \(fishName),
                                        навеска \(fishGrade)
                                        в количестве \(fishWeight) кг.
                                        """,
                                      preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "Верно",
                                       style: .default) { action in
            self.coreDataStack.saveContext()
            self.choozenDate = Date()
            self.choozenFish = nil
            self.choozenGrade = nil
            self.frozenOnBoardTF.text = nil
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alert.addAction(doneAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
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


