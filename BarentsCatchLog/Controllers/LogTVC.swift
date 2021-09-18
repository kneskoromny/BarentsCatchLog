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
    var dailyCatch = [DailyCatch]()
    var sortedDailyCatch = [DailyCatch]()
    let tableRefreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(update(sender:)), for: .valueChanged)
        return control
    }()
    
    // MARK: - Private Properties
    private var fishes: [Fish] = []
    private var updatedFishes: [Fish] = []
    private var months = ["Янв", "Фев", "Мар", "Апр", "Май", "Июн",
                          "Июл", "Авг", "Сен", "Окт", "Ноя", "Дек"]
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let fetchRequest: NSFetchRequest<Fish> = Fish.fetchRequest()
        do {
            fishes = try coreDataStack.managedContext.fetch(fetchRequest)
            //print("fishes in LOG \(fishes.count)")
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
        //print("Its a fishes count - \(fishes.count)")
        let convertedFishes = fishes.sorted(by: { ($0.date)?.compare($1.date!) == .orderedDescending})
        
        divideByDate(from: convertedFishes)
        print("Its a dailyCatch count - \(dailyCatch.count)")
        //tableView.reloadData()
        dailyCatch.forEach { dailyCatch in
            //print("Its a dailyCatch  - \(dailyCatch.fishes?.first)")
        }
        tableView.refreshControl = tableRefreshControl
        
    }
    // MARK: - Private Methods
    // добавил 4 рыбы за сегодня, рефрешнул, добавил еще 2 рефрешнул и они добавились и отдельной секцией с числом и в число к другим
    private func divideByDate(from fishes: [Fish]) {
        var dividedFishes: [Fish] = []
        var fishDate: String?, fishMonth: String?
        //var isFishDidAdded = false
        if let date = fishes.first?.date {
            let components = Calendar.current.dateComponents([.day,.month], from: date)
            fishDate = String(describing: components.day!)
            fishMonth = String(describing: components.month!)
        }
        // не работает если вносишь один тип рыбы - РЕШЕНО ЧЕРЕЗ REFRESH CONTROL
        for fish in fishes {
            var currentFishDate: String?, currentFishMonth: String?
            if let date = fish.date {
                let components = Calendar.current.dateComponents([.day, .month], from: date)
                currentFishDate = String(describing: components.day!)
                currentFishMonth = String(describing: components.month!)
            }
            print("Inside forIn - fishDate \(String(describing: fishDate))")
            print("Inside forIn - fish.date \(String(describing: currentFishDate))")
            // даты 2х последующих рыб совпадают
            if currentFishDate == fishDate {
                dividedFishes.append(fish)
                // появляется другая дата
               } else {
                // первое внесение, dailyCatch пустой
                if dailyCatch.isEmpty {
                    guard let date = fishDate, let month = fishMonth else { return }
                    let catchDaily = DailyCatch(date: date, month: month, fishes: dividedFishes)
                    dailyCatch.append(catchDaily)
                    // рыба уже вносилась, dailyCatch содержит данные
                } else {
                    for element in dailyCatch {
                        // есть такая же дата
                        if element.date == fishDate {
                            element.fishes?.append(fish)
                            // такой даты нет
                        } else {
                            guard let date = fishDate, let month = fishMonth else { return }
                            let catchDaily = DailyCatch(date: date, month: month, fishes: dividedFishes)
                            dailyCatch.append(catchDaily)
                        }
                    }
                }
                dividedFishes.removeAll()
                dividedFishes.append(fish)
                fishDate = currentFishDate
                fishMonth = currentFishMonth
            }
        }
        print("Divided fishes count - \(dividedFishes.count)")
        // внесение последнего элемента массива fishes
        var iteration = 0
        var isAdded = false
        while iteration < dailyCatch.count {
            if dailyCatch[iteration].date == fishDate {
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
            guard let date = fishDate, let month = fishMonth else { return }
            let catchDaily = DailyCatch(date: date, month: month, fishes: dividedFishes)
            dailyCatch.append(catchDaily)
        }
        
        
        sortedDailyCatch = dailyCatch.sorted { catch1, catch2 in
            let date1 = Int(catch1.date!), date2 = Int(catch2.date!)
            return date1! > date2!
        }
    }
    // обновляет table view при свайпе вниз
    @objc private func update(sender: UIRefreshControl) {
        let fetchRequestForUpdate: NSFetchRequest<Fish> = Fish.fetchRequest()
        do {
            updatedFishes = try coreDataStack.managedContext.fetch(fetchRequestForUpdate)
            //print("UPDATED FISHES COUNT \(updatedFishes.count)")
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
        //print("FISHES COUNT - \(fishes.count)")
        
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
            textLabel.text = months[monthFigure - 1]
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

