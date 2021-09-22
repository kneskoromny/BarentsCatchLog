//
//  LogTVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 12.09.2021.
//

import UIKit
import CoreData

class DailyCatch {
    let date: String?
    let month: String?
    var fishes: [Fish]?
    
    init(date: String, month: String, fishes: [Fish]) {
        self.date = date
        self.month = month
        self.fishes = fishes
    }
}

class LogVC: UITableViewController {
    
    // MARK: - Public Properties
    lazy var coreDataStack = CoreDataStack(modelName: IDs.modelID.rawValue)
    let tableRefreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(update(sender:)), for: .valueChanged)
        return control
    }()
    var dailyCatch = [DailyCatch]()
    var sortedDailyCatch = [DailyCatch]()
    
    // MARK: - Private Properties
    private var fishes: [Fish] = []
    private var updatedFishes: [Fish] = []
    private var isEditingTableView = true
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fishes = Requests.shared.getAllElementsRequest()
        let convertedFishes = fishes.sorted(by: {
            ($0.date)?.compare($1.date!) == .orderedDescending
        })
        
        divideByDate(from: convertedFishes)
        tableView.refreshControl = tableRefreshControl
    }
    
    // MARK: - IB Actions
    @IBAction func deleteLogRecordBtnPressed(_ sender: UIBarButtonItem) {
        tableView.setEditing(isEditingTableView, animated: true)
        isEditingTableView.toggle()
    }
    
    
    // MARK: - Private Methods
    private func divideByDate(from fishes: [Fish]) {
        var dividedFishes: [Fish] = []

        guard let firstFish = fishes.first else { return }
        var dateForComparsion = getDayForComparsion(from: firstFish)
        var monthForComparsion = getMonthForComparsion(from: firstFish)
        
        // оставил for in для пошагового отслеживания ошибок
        for fish in fishes {
            let currentFishDate = getDayForComparsion(from: fish)
            let currentFishMonth = getMonthForComparsion(from: fish)
            
            if currentFishDate == dateForComparsion {
                dividedFishes.append(fish)
            } else {
                switch dailyCatch.isEmpty {
                case true:
                    createDailyCatch(with: dateForComparsion, month: monthForComparsion, and: dividedFishes)
                default:
                    for dictionary in dailyCatch {
                        if dictionary.date == dateForComparsion {
                            dictionary.fishes?.append(fish)
                        } else {
                            createDailyCatch(with: dateForComparsion, month: monthForComparsion, and: dividedFishes)
                            break
                        }
                    }
                }
                dividedFishes.removeAll()
                dividedFishes.append(fish)
                dateForComparsion = currentFishDate
                monthForComparsion = currentFishMonth
            }
        }
        addLastElement(with: dateForComparsion, month: monthForComparsion, and: dividedFishes, to: dailyCatch)
        sortedDailyCatch = createSortedByDateArray(from: dailyCatch)
    }
    
    private func getDayForComparsion(from element: Fish) -> String? {
        var day: String?
        
        if let elementDate = element.date {
            let components = Calendar.current.dateComponents([.day], from: elementDate)
            day = String(describing: components.day!)
        }
        return day
    }
    
    private func getMonthForComparsion(from element: Fish) -> String? {
        var month: String?
        
        if let elementDate = element.date {
            let components = Calendar.current.dateComponents([.month], from: elementDate)
            month = String(describing: components.month!)
        }
        return month
    }
    
    private func createDailyCatch(with date: String?, month: String?, and fishes: [Fish]) {
        guard let date = date, let month = month else { return }
        let newDailyCatch = DailyCatch(date: date, month: month, fishes: fishes)
        dailyCatch.append(newDailyCatch)
    }
    
    private func addLastElement(with date: String?, month: String?, and fishes: [Fish], to dailyCatch: [DailyCatch]) {
        var iteration = 0
        var isAdded = false
        while iteration < dailyCatch.count {
                  if dailyCatch[iteration].date == date {
                      isAdded = true
                      for fish in fishes {
                          dailyCatch[iteration].fishes?.append(fish)
                      }
                      break
                  } else {
                      iteration += 1
                  }
              }
              if !isAdded {
                  createDailyCatch(with: date, month: month, and: fishes)
              }
    }
    private func createSortedByDateArray(from dictionaryArray: [DailyCatch]) -> [DailyCatch] {
        return dictionaryArray.sorted { catch1, catch2 in
            let date1 = Int(catch1.date!), date2 = Int(catch2.date!)
            return date1! > date2!
        }
    }
    
    @objc private func update(sender: UIRefreshControl) {
        updatedFishes = Requests.shared.getAllElementsRequest()
        
        let convertedFishesBeforeUpdating = createConvertedByDateSet(from: fishes)
        let convertedFishesAfterUpdating = createConvertedByDateSet(from: updatedFishes)
        
        let update = Array(convertedFishesBeforeUpdating.symmetricDifference(convertedFishesAfterUpdating))
        
        divideByDate(from: update)
        fishes = updatedFishes
        tableView.reloadData()
        sender.endRefreshing()
    }
    
    private func createConvertedByDateSet(from array: [Fish]) -> Set<Fish> {
        Set(array.sorted(by: { ($0.date)?.compare($1.date!) == .orderedDescending}))
    }
}
// MARK: - TableViewDataSource
extension LogVC {
    override func numberOfSections(in tableView: UITableView) -> Int {
        sortedDailyCatch.count
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let day = sortedDailyCatch[section].date
        let month = sortedDailyCatch[section].month
        
        return CustomView.createHeaderForLogVC(with: tableView.frame.width, height: 40, day: day, and: month)
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sortedDailyCatch[section].fishes?.count ?? 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIDs.logCell.rawValue, for: indexPath) as! LogCell
        let fish = sortedDailyCatch[indexPath.section].fishes?[indexPath.row]
        cell.configure(with: fish)
        
        return cell
    }
}
// MARK: - TableViewDelegate
extension LogVC {
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let fish = sortedDailyCatch[indexPath.section].fishes?[indexPath.row] else { return }
            let daily = sortedDailyCatch[indexPath.section]
            let indexSet = IndexSet(arrayLiteral: indexPath.section)
            
            if let index = sortedDailyCatch[indexPath.section].fishes?.firstIndex(of: fish) {
                if sortedDailyCatch[indexPath.section].fishes!.count > 1 {
                    sortedDailyCatch[indexPath.section].fishes?.remove(at: index)
                    tableView.deleteRows(at: [indexPath], with: .left)
                } else {
                    if let index2 = sortedDailyCatch.firstIndex(where: { dailyCatch in
                        dailyCatch === daily
                    }) {
                        sortedDailyCatch[indexPath.section].fishes?.remove(at: index)
                        tableView.deleteRows(at: [indexPath], with: .left)
                        sortedDailyCatch.remove(at: index2)
                        tableView.deleteSections(indexSet, with: .left)
                    }
                }
                coreDataStack.managedContext.delete(fish)
                coreDataStack.saveContext()
            }
        }
    }
}
// MARK: - AlertController
extension LogVC {
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

