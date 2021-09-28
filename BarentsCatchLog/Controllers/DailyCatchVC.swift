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
protocol GradeVCDelegate {
    func valueDidChanged(to grade: String)
}
protocol FishVCDelegate {
    func fishDidChanged(to fish: InputFish)
}

class DailyCatchVC: UIViewController {
    
    //MARK: - IB Outlets
    @IBOutlet weak var frozenOnBoardTF: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var saveBtn: UIButton!
    
    
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
    private var choozenFish: InputFish?
    private var sumFrzPerDay: Int?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        checkTemplates()
        
        frozenOnBoardTF.textColor = .systemGreen
        frozenOnBoardTF.inputAccessoryView = createToolbar()
        frozenOnBoardTF.keyboardType = .decimalPad
        CustomView.createDesign(for: saveBtn, with: .systemBlue, and: "Сохранить")
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
        guard let fishName = choozenFish?.fish, let fishGrade = choozenGrade, let fishWeight = frozenOnBoardTF.text else {
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
    @IBAction func deleteAllDataBtnPressed(_ sender: UIBarButtonItem) {
        showAlert(title: "Внимание!", message: "Вы удаляете все записи. Это действие нельзя отменить.") {
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Fish")
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try self.coreDataStack.managedContext.execute(batchDeleteRequest)
            } catch let error as NSError {
                print("Fetch error: \(error) description: \(error.userInfo)")
            }
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
    private func createInstance(name: String, grade: String, date: Date, weight: String) {
        let fishCatch = Fish(context: coreDataStack.managedContext)
        fishCatch.name = name
        fishCatch.grade = grade
        fishCatch.date = date
        if let fishRatio = choozenFish?.ratio {
            fishCatch.ratio = fishRatio
        }
        if let doubleWeight = Double(weight) {
            // изменил
            fishCatch.perDay = doubleWeight
        }
        // изменил
        fishCatch.onBoard = fishCatch.perDay + (Double(sumFrzPerDay ?? 0))
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
        view.endEditing(true)
    }
    private func configure(for cell: UITableViewCell, from object: String) {
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
            cell.detailTextLabel?.text = choozenFish?.fish
        default:
            cell.detailTextLabel?.text = choozenGrade
        }
    }
}

// MARK: - TableViewDataSource
extension DailyCatchVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrayForTableView.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIDs.dailyCatchCell.rawValue, for: indexPath)
        let object = arrayForTableView[indexPath.row]
        
        configure(for: cell, from: object)

        return cell
    }
}
// MARK: - TableViewDelegate
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
// MARK: - Create User Input Template
private func createCodTemplate() {
    let codTemplate = InputFish(fish: FishTypes.cod.rawValue, ratio: Ratios.cod.rawValue)
    StorageManager.shared.save(inputFish: codTemplate)
}
private func createHaddockTemplate() {
    let haddockTemplate = InputFish(fish: FishTypes.haddock.rawValue, ratio: Ratios.haddock.rawValue)
    StorageManager.shared.save(inputFish: haddockTemplate)
}
private func createGradeTemplate() {
    let gradeTemplate = Grades.withoutGrade.rawValue
    StorageManager.shared.save(grade: gradeTemplate)
}
private func isFishTemplate(fish: String, in array: [InputFish]) -> Bool {
    let filteredArray = array.filter { input in
        input.fish == fish
    }
    return !filteredArray.isEmpty ? true : false
}
private func isGradeTemplate(grade: String, in array: [String]) -> Bool {
    let filteredArray = array.filter { inputGrade in
        inputGrade == grade
    }
    return !filteredArray.isEmpty ? true : false
}
private func checkTemplates() {
    let fetchedFishes = StorageManager.shared.fetchInputFishes()
    let isCodTemplate = isFishTemplate(fish: FishTypes.cod.rawValue, in: fetchedFishes)
    if !isCodTemplate {
        createCodTemplate()
    }
    let isHaddockTemplate = isFishTemplate(fish: FishTypes.haddock.rawValue, in: fetchedFishes)
    if !isHaddockTemplate {
        createHaddockTemplate()
    }
    let fetchedGrades = StorageManager.shared.fetchGrades()
    let isGradeTemplate = isGradeTemplate(grade: Grades.withoutGrade.rawValue, in: fetchedGrades)
    if !isGradeTemplate {
        createGradeTemplate()
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
extension DailyCatchVC: GradeVCDelegate {
    func valueDidChanged(to grade: String) {
        self.choozenGrade = grade
        self.tableView.reloadData()
    }
}

// MARK: - FishTVC Delegate
extension DailyCatchVC: FishVCDelegate {
    func fishDidChanged(to fish: InputFish) {
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
        let cancel = UIAlertAction(title: "Отмена", style: .cancel) { action in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(doneAction)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
}



