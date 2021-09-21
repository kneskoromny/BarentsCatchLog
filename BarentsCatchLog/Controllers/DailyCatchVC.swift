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
    lazy var coreDataStack = CoreDataStack(modelName: IDs.modelID.rawValue)
    
    //MARK: - Private Properties
    let arrayForTableView = [DailyCatchVCStrings.date.rawValue,
                             DailyCatchVCStrings.fish.rawValue,
                             DailyCatchVCStrings.grade.rawValue]
    
    private var isOnBoardWeightGreater = false
    private var choozenDate = Date()
    private var choozenGrade: String?
    private var choozenFish: String?
    private var sumFrzPerDay: Int?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        frozenOnBoardTF.textColor = .systemGreen
        frozenOnBoardTF.inputAccessoryView = createToolbar()
        frozenOnBoardTF.keyboardType = .decimalPad
    }
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SegueIDs.toDateFromChoice.rawValue:
            if let dateVC = segue.destination as? DateVC {
                dateVC.choozenDate = choozenDate
                dateVC.delegate = self
            }
        case SegueIDs.toGradeChoice.rawValue:
            if let navController = segue.destination as? GradeTVCNC {
                if let gradeTVC = navController.topViewController as? GradeVC {
                    gradeTVC.delegate = self
                }
            }
        default:
            if let navController = segue.destination as? FishTVCNC {
                if let fishTVC = navController.topViewController as? FishVC {
                    fishTVC.delegate = self
                }
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //MARK: - IB Actions
    @IBAction func saveBtnPressed() {
        guard let fishName = choozenFish, let fishGrade = choozenGrade, let fishWeight = frozenOnBoardTF.text else {
            showAlert(title: "Пустые поля!",
                      message: "Необходимо заполнить все поля перед сохранением.")
            return
        }
        if fishWeight == "" {
            showAlert(title: "Пустые поля!",
                      message: "Необходимо заполнить все поля перед сохранением.")
            return
        }
        sumFrzPerDay = Requests.shared.getAttributeCountRequest(for: fishName, and: fishGrade)
        
        checkOnBoardWeight(between: sumFrzPerDay, and: fishWeight)
        if isOnBoardWeightGreater {
            showAlert(title: "Что-то не так!",
                      message: "Проверьте данные. Вносимое количество не может быть меньше, чем внесено ранее.") {
                self.frozenOnBoardTF.becomeFirstResponder()
                self.frozenOnBoardTF.text = ""
            }
            return
        }
        
        createInstance(name: fishName, grade: fishGrade, date: choozenDate, weight: fishWeight)
        refreshUI()
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
    
    //MARK: - Private Methods
    private func checkOnBoardWeight(between onBoardFish: Int?, and inputFish: String) {
        if let onBoardFish = onBoardFish {
            let doubleOnBoard = Double(onBoardFish)
            let doubleInputFish = Double(inputFish)
            if let doubleInputFish = doubleInputFish {
                isOnBoardWeightGreater = doubleOnBoard > doubleInputFish ? true : false
            }
        }
    }
    private func getRatio(for fish: FishTypes.RawValue) -> Ratios.RawValue {
        var ratio = Ratios.cod.rawValue
        switch fish {
        case FishTypes.cod.rawValue:
            ratio = Ratios.cod.rawValue
        case FishTypes.haddock.rawValue:
            ratio = Ratios.haddock.rawValue
        case FishTypes.catfish.rawValue:
            ratio = Ratios.catfish.rawValue
        default:
            ratio = Ratios.redfish.rawValue
        }
        return ratio
    }
    private func createInstance(name: String, grade: String, date: Date, weight: String) {
        let fishCatch = Fish(context: coreDataStack.managedContext)
        fishCatch.name = name
        fishCatch.grade = grade
        fishCatch.date = date
        fishCatch.ratio = getRatio(for: name)
        if let doubleWeight = Double(weight) {
            fishCatch.onBoard = doubleWeight
        }
        fishCatch.perDay = fishCatch.onBoard - (Double(sumFrzPerDay ?? 0))
        coreDataStack.saveContext()
    }
    private func refreshUI() {
        choozenDate = Date()
        choozenFish = nil
        choozenGrade = nil
        frozenOnBoardTF.text = nil
        tableView.reloadData()
    }
    private func createToolbar() -> UIToolbar {
        let toolBar = UIToolbar()
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.items = [flexSpace, doneBtn]
        toolBar.sizeToFit()
        
        return toolBar
    }
    @objc private func doneAction() {
        print("DONE")
        view.endEditing(true)
    }
}

// MARK: - UITableViewDataSource
extension DailyCatchVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrayForTableView.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIDs.dailyCatchCell.rawValue, for: indexPath)
        let object = arrayForTableView[indexPath.row]
        cell.textLabel?.text = object
        cell.detailTextLabel?.textColor = .systemGray
        switch object {
        case DailyCatchVCStrings.date.rawValue:
            if choozenDate != Date() {
                let convertedDate = dateFormatter.string(from: choozenDate)
                cell.detailTextLabel?.text = String(describing: convertedDate)
            } else {
                cell.detailTextLabel?.text = "Сегодня"
            }
        case DailyCatchVCStrings.fish.rawValue:
            if choozenFish != nil {
                cell.detailTextLabel?.text = choozenFish
            } else {
                //убрать
                //cell.detailTextLabel?.text = ""
            }
        default:
            if choozenGrade != nil {
                cell.detailTextLabel?.text = choozenGrade
            } else {
                //cell.detailTextLabel?.text = ""
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
            performSegue(withIdentifier: SegueIDs.toDateFromChoice.rawValue, sender: nil)
        case 1:
            performSegue(withIdentifier: SegueIDs.toFishChoice.rawValue, sender: nil)
        default:
            performSegue(withIdentifier: SegueIDs.toGradeChoice.rawValue, sender: nil)
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


