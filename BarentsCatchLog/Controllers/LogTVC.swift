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
    let fishes: [Fish]?
    
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
    private var monthSymbols = Calendar.current.monthSymbols
    private let month = Calendar.current.dateComponents([.month], from: Date()).month!
    private var reversedMonthSymbols: [String]?
    private var months = ["Янв", "Фев", "Мар", "Апр", "Май", "Июн",
                          "Июл", "Авг", "Сен", "Окт", "Ноя", "Дек"]
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let fetchRequest: NSFetchRequest<Fish> = Fish.fetchRequest()
        do {
            fishes = try coreDataStack.managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
        print("Its a fishes count - \(fishes.count)")
        let convertedFishes = fishes.sorted(by: { ($0.date)?.compare($1.date!) == .orderedDescending})
    
        divideByDate(from: convertedFishes)
        print("Its a dailyCatch count - \(dailyCatch.count)")
        
        monthSymbols.removeSubrange(month..<monthSymbols.count)
        reversedMonthSymbols = monthSymbols.reversed()
        
    }
    
    // MARK: - Private Methods
    private func divideByDate(from fishes: [Fish]) {
        var dividedFishes: [Fish] = []
        var fishDate: String?, fishMonth: String?
        if let date = fishes.first?.date {
            let components = Calendar.current.dateComponents([.day,.month], from: date)
            fishDate = String(describing: components.day!)
            fishMonth = String(describing: components.month!)
        }
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
                dividedFishes.removeAll()
                dividedFishes.append(fish)
                fishDate = currentFishDate
                fishMonth = currentFishMonth
            }
        }
    }

    // MARK: - TableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        //reversedMonthSymbols?.count ?? 1
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
        //figureLabel.backgroundColor = UIColor(red: 72/255, green: 159/255, blue: 248/255, alpha: 1)
        
        
        let textLabel = UILabel()
        textLabel.frame = CGRect(x: 5, y: 20, width: 30, height: 20)
        if let monthFigure = Int(dailyCatch[section].month!) {
            textLabel.text = months[monthFigure - 1]
        }
        textLabel.textAlignment = .center
        textLabel.font = .systemFont(ofSize: 14)
        textLabel.textColor = UIColor(red: 72/255, green: 159/255, blue: 248/255, alpha: 1)
        //textLabel.backgroundColor = UIColor(red: 72/255, green: 159/255, blue: 248/255, alpha: 1)
        
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
        cell.fishlabel?.text = dailyCatch[indexPath.section].fishes?[indexPath.row].name
        if let perDay = dailyCatch[indexPath.section].fishes?[indexPath.row].perDay {
            cell.frzBoardLabel.text = String(format: "%.0f", perDay) + " кг"
        }
        
        return cell
    }
}
