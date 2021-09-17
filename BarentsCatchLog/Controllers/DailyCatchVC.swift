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
    
    // нужен для подсчета суммы мороженой за день, если в пред день не было внесения
    private var sumFrzPerDay: Int?
    
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
        // получаем предыдущий день внесения улова
        guard let dayBeforeInputDay = Calendar.current.date(byAdding: .day,
                                                              value: -1,
                                                              to: choozenDate) else { return }
        
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
        let predicatesForCatchBeforeInput = Predicates().getPredicateFrom(name: fishName,
                                                       grade: fishGrade,
                                                       dateFrom: dayBeforeInputDay,
                                                       dateTo: dayBeforeInputDay)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicatesForCatchBeforeInput)
        fetchRequest.predicate = predicate
        
        do {
            catchForDayBeforeInput = try coreDataStack.managedContext.fetch(fetchRequest).first
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
        fishCatch.grade = choozenGrade
        fishCatch.date = choozenDate
        
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
        
        
        // логика по подсчету frzPerDay по внесенному типу рыбы, на тот случай, если вчера внесения не было
        let countRequest = NSFetchRequest<NSDictionary>(entityName: "Fish")
        // добавляем предикат по имени и навеске
        let predicatesForCount = Predicates().getPredicateFrom(name: fishName, grade: fishGrade)
        let predicateForCount = NSCompoundPredicate(andPredicateWithSubpredicates: predicatesForCount)
        countRequest.predicate = predicateForCount
        // указываем тип результата
        countRequest.resultType = .dictionaryResultType
      // создаем экземпляр NSExpressionDescription для запроса суммы
        let sumExpressionDesc = NSExpressionDescription()
        // даем имя, чтобы можно было прочитать его результат из словаря результатов
        sumExpressionDesc.name = "sumFrz"
      // создаем аргумент для подсчета по ключу Fish.perDay
        let specialCountExp = NSExpression(forKeyPath: #keyPath(Fish.perDay))
        // указываем тип выражения - сумма, какой аргумент считать - specialCountExp
        sumExpressionDesc.expression = NSExpression(forFunction: "sum:",
                                                    arguments: [specialCountExp])
        // задаем тип возвращаемого значения - Int32
        sumExpressionDesc.expressionResultType = .integer32AttributeType
      // в свойство начального запроса ставим созданный запрос суммы
        countRequest.propertiesToFetch = [sumExpressionDesc]
      
        do {
          let results =
            try coreDataStack.managedContext.fetch(countRequest)
          // возвращаемое значение массив, получаем первый элемент из него
          let resultDict = results.first
          // вытаскиваем значение из словаря по ключу и кастим до Int
          sumFrzPerDay = resultDict?["sumFrz"] as? Int ?? 0
            print("This is sumFrzPerDay: \(String(describing: sumFrzPerDay))")
          
        } catch let error as NSError {
          print("count not fetched \(error), \(error.userInfo)")
        }
        
        fishCatch.perDay = fishCatch.onBoard - (catchForDayBeforeInput?.onBoard ?? Double(sumFrzPerDay ?? 0))

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

// MARK: - AlertController 
extension DailyCatchVC {
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


