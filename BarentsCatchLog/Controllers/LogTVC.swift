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
    let fishes: [Fish]?
    
    init(date: String, fishes: [Fish]) {
        self.date = date
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
        var fishDate: String?
        if let date = fishes.first?.date {
            let components = Calendar.current.dateComponents([.day], from: date)
            fishDate = String(describing: components.day!)
        }
        for fish in fishes {
            var currentFishDate: String?
            if let date = fish.date {
                let components = Calendar.current.dateComponents([.day], from: date)
                currentFishDate = String(describing: components.day!)
            }
            print("Inside forIn - fishDate \(String(describing: fishDate))")
            print("Inside forIn - fish.date \(String(describing: currentFishDate))")
            if currentFishDate == fishDate {
                dividedFishes.append(fish)
            } else {
                
                let catchDaily = DailyCatch(date: fishDate!, fishes: dividedFishes)
                dailyCatch.append(catchDaily)
                dividedFishes.removeAll()
                dividedFishes.append(fish)
                fishDate = currentFishDate
            }
        }
    }

    // MARK: - TableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        //reversedMonthSymbols?.count ?? 1
        dailyCatch.count
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        dailyCatch[section].date!
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dailyCatch[section].fishes?.count ?? 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "logCell", for: indexPath)
        cell.textLabel?.text = dailyCatch[indexPath.section].fishes?[indexPath.row].name
        cell.detailTextLabel?.text = dailyCatch[indexPath.section].fishes?[indexPath.row].grade

        return cell
    }
}
