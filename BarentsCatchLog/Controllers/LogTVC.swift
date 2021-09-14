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
    
    // MARK: - Private Properties
    private var fishes: [Fish] = []
    private var months = ["Янв", "Фев", "Мар", "Апр", "Май", "Июн",
                          "Июл", "Авг", "Сен", "Окт", "Ноя", "Дек"]
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let fetchRequest: NSFetchRequest<Fish> = Fish.fetchRequest()
        do {
            fishes = try coreDataStack.managedContext.fetch(fetchRequest)
            print("fishes in LOG \(fishes.count)")
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
        print("Its a fishes count - \(fishes.count)")
        let convertedFishes = fishes.sorted(by: { ($0.date)?.compare($1.date!) == .orderedDescending})

        divideByDate(from: convertedFishes)
        print("Its a dailyCatch count - \(dailyCatch.count)")
        tableView.reloadData()
        dailyCatch.forEach { dailyCatch in
            print("Its a dailyCatch  - \(dailyCatch.fishes?.first)")

        }
    }
    
    // MARK: - Private Methods
    private func divideByDate(from fishes: [Fish]) {
        var dividedFishes: [Fish] = []
        var fishDate: String?, fishMonth: String?
        var isFishDidAdded = false
        if let date = fishes.first?.date {
            let components = Calendar.current.dateComponents([.day,.month], from: date)
            fishDate = String(describing: components.day!)
            fishMonth = String(describing: components.month!)
        }
        // не работает если вносишь один тип рыбы
            for fish in fishes {
                var currentFishDate: String?, currentFishMonth: String?
                if let date = fish.date {
                    let components = Calendar.current.dateComponents([.day, .month], from: date)
                    currentFishDate = String(describing: components.day!)
                    currentFishMonth = String(describing: components.month!)
                }
                print("Inside forIn - fishDate \(String(describing: fishDate))")
                print("Inside forIn - fish.date \(String(describing: currentFishDate))")
                if currentFishDate == fishDate {
                    dividedFishes.append(fish)
                } else {
                    let catchDaily = DailyCatch(date: fishDate!, month: fishMonth!, fishes: dividedFishes)
                    dailyCatch.append(catchDaily)
                    isFishDidAdded.toggle()
                    dividedFishes.removeAll()
                    dividedFishes.append(fish)
                    isFishDidAdded.toggle()
                    fishDate = currentFishDate
                    fishMonth = currentFishMonth
                }
            }
        if !dividedFishes.isEmpty && !isFishDidAdded {
            let catchDaily = DailyCatch(date: fishDate!, month: fishMonth!, fishes: dividedFishes)
            dailyCatch.append(catchDaily)
        }
        }
    }


    // MARK: - TableViewDataSource
extension LogTVC {
    override func numberOfSections(in tableView: UITableView) -> Int {
        dailyCatch.count
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
                
        let figureLabel = UILabel()
        figureLabel.frame = CGRect(x: 5, y: 0, width: 30, height: 20)
        figureLabel.text = dailyCatch[section].date!
        figureLabel.textAlignment = .center
        figureLabel.font = .systemFont(ofSize: 16)
        figureLabel.textColor = UIColor(red: 72/255, green: 159/255, blue: 248/255, alpha: 1)
    
        let textLabel = UILabel()
        textLabel.frame = CGRect(x: 5, y: 20, width: 30, height: 20)
        if let monthFigure = Int(dailyCatch[section].month!) {
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
        dailyCatch[section].date!
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dailyCatch[section].fishes?.count ?? 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "logCell", for: indexPath) as! LogCell
        let fish = dailyCatch[indexPath.section].fishes?[indexPath.row]
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
            guard let fish = dailyCatch[indexPath.section].fishes?[indexPath.row] else { return }
            let daily = dailyCatch[indexPath.section]
            let indexSet = IndexSet(arrayLiteral: indexPath.section)
            
            if let index = dailyCatch[indexPath.section].fishes?.firstIndex(of: fish) {
                if dailyCatch[indexPath.section].fishes!.count > 1 {
                    dailyCatch[indexPath.section].fishes?.remove(at: index)
                    tableView.deleteRows(at: [indexPath], with: .left)
                } else {
                    if let index2 = dailyCatch.firstIndex(where: { dailyCatch in
                        dailyCatch === daily
                    }) {
                        dailyCatch[indexPath.section].fishes?.remove(at: index)
                        print("1")
                        tableView.deleteRows(at: [indexPath], with: .left)
                        print("3")
                        dailyCatch.remove(at: index2)
                        print("2")
                        tableView.deleteSections(indexSet, with: .left)
                        print("4")
                    }
                }
                coreDataStack.managedContext.delete(fish)
                coreDataStack.saveContext()
            }
            
        }
    }
}
