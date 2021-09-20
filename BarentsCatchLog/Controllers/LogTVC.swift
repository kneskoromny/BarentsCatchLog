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

class LogTVC: UITableViewController {
    // MARK: - Public Properties
    lazy var coreDataStack = CoreDataStack(modelName: "BarentsCatchLog")
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
    
    // MARK: - Private Methods
    private func divideByDate(from fishes: [Fish]) {
        var dividedFishes: [Fish] = []

        guard let firstFish = fishes.first else { return }
        var dateForComparsion = getDayForComparsion(from: firstFish)
        print("StartDateForComparsion: \(dateForComparsion)")
        var monthForComparsion = getMonthForComparsion(from: firstFish)
        print("StartMmonthForComparsion: \(monthForComparsion)")
        
        fishes.forEach { fish in
            
            let currentFishDate = getDayForComparsion(from: fish)
            print("currentFishDate: \(currentFishDate)")
            let currentFishMonth = getMonthForComparsion(from: fish)
            print("currentFishMonth: \(currentFishMonth)")
            // даты 2х последующих рыб совпадают
            if currentFishDate == dateForComparsion {
                dividedFishes.append(fish)
                // появляется другая дата
            } else {
                switch dailyCatch.isEmpty {
                // первое внесение, dailyCatch пустой
                case true:
                    createDailyCatch(with: dateForComparsion, month: monthForComparsion, and: dividedFishes)
                // рыба уже вносилась, dailyCatch содержит данные
                default:
                    dailyCatch.forEach { dailyCatch in
                        // есть такая же дата
                        if dailyCatch.date == dateForComparsion {
                            dailyCatch.fishes?.append(fish)
                            print("dailyCatchFishesCount: \(dailyCatch.fishes?.count)")
                            // такой даты нет
                        } else {
                            createDailyCatch(with: dateForComparsion, month: monthForComparsion, and: dividedFishes)
                        }
                    }
                }
                dividedFishes.removeAll()
                dividedFishes.append(fish)
                dateForComparsion = currentFishDate
                print("NewDateForComparsion: \(dateForComparsion)")
                monthForComparsion = currentFishMonth
                print("NewMmonthForComparsion: \(monthForComparsion)")
            }
        }
        // внесение последнего элемента массива fishes
        var iteration = 0
        var isAdded = false
        while iteration < dailyCatch.count {
            if dailyCatch[iteration].date == dateForComparsion {
                isAdded = true
                for fish in dividedFishes {
                    dailyCatch[iteration].fishes?.append(fish)
                }
                break
            } else {
                iteration += 1
            }
            
        }
        if !isAdded {
            createDailyCatch(with: dateForComparsion, month: monthForComparsion, and: dividedFishes)
        }
        sortedDailyCatch = dailyCatch.sorted { catch1, catch2 in
            let date1 = Int(catch1.date!), date2 = Int(catch2.date!)
            return date1! > date2!
        }
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
    // обновляет table view при свайпе вниз
    @objc private func update(sender: UIRefreshControl) {
        updatedFishes = Requests.shared.getAllElementsRequest()
        
        let convFishes = Set(fishes.sorted(by: { ($0.date)?.compare($1.date!) == .orderedDescending}))
        let convUpdFishes = Set(updatedFishes.sorted(by: { ($0.date)?.compare($1.date!) == .orderedDescending}))
        let update = Array(convFishes.symmetricDifference(convUpdFishes))
        //print("UPDATE COUNT - \(update.count)")
        divideByDate(from: update)
        fishes = updatedFishes
        tableView.reloadData()
        sender.endRefreshing()
    }
}
// MARK: - TableViewDataSource
extension LogTVC {
    override func numberOfSections(in tableView: UITableView) -> Int {
        sortedDailyCatch.count
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        
        let figureLabel = UILabel()
        figureLabel.frame = CGRect(x: 5, y: 0, width: 30, height: 20)
        figureLabel.text = sortedDailyCatch[section].date!
        figureLabel.textAlignment = .center
        figureLabel.font = .systemFont(ofSize: 16)
        figureLabel.textColor = UIColor(red: 72/255, green: 159/255, blue: 248/255, alpha: 1)
        
        let textLabel = UILabel()
        textLabel.frame = CGRect(x: 5, y: 20, width: 30, height: 20)
        if let monthFigure = Int(sortedDailyCatch[section].month!) {
            textLabel.text = Arrays.shared.months[monthFigure - 1]
        }
        textLabel.textAlignment = .center
        textLabel.font = .systemFont(ofSize: 14)
        textLabel.textColor = UIColor(red: 72/255, green: 159/255, blue: 248/255, alpha: 1)
        
        headerView.addSubview(textLabel)
        headerView.addSubview(figureLabel)
        
        return headerView
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sortedDailyCatch[section].date!
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sortedDailyCatch[section].fishes?.count ?? 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "logCell", for: indexPath) as! LogCell
        let fish = sortedDailyCatch[indexPath.section].fishes?[indexPath.row]
        cell.fishlabel?.text = fish?.name
        if let perDay = fish?.perDay {
            cell.frzBoardLabel.text = String(format: "%.0f", perDay) + " кг"
        }
        cell.gradeLabel.text = fish?.grade
        
        return cell
    }
}
// MARK: - TableViewDelegate
extension LogTVC {
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
                        //print("1")
                        tableView.deleteRows(at: [indexPath], with: .left)
                        //print("3")
                        sortedDailyCatch.remove(at: index2)
                        //print("2")
                        tableView.deleteSections(indexSet, with: .left)
                        //print("4")
                    }
                }
                coreDataStack.managedContext.delete(fish)
                coreDataStack.saveContext()
            }
        }
    }
}
// MARK: - AlertController
extension LogTVC {
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

