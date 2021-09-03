//
//  DailyReportTableVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 30.08.2021.
//

import UIKit
import CoreData

class DailyReportTableVC: UITableViewController {
    
    // MARK: - Public Properties
    lazy var coreDataStack = CoreDataStack(modelName: "BarentsCatchLog")
    
    // MARK: - Private Properties
    private var caughtFishes: [Fish] = []
    private var totalCod: [Fish] = []
    private var totalHaddock: [Fish] = []
    private var totalCatfish: [Fish] = []
    private var totalRedfish: [Fish] = []
    
    private let sections = [FishTypes.cod.rawValue,
                            FishTypes.haddock.rawValue,
                            FishTypes.catfish.rawValue,
                            FishTypes.redfish.rawValue]
    
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // календарь с системной временной зоной
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.system
        
        // получаем начало и окончание сегодняшнего дня
        let dateFrom = calendar.startOfDay(for: Date())
        let dateTo = calendar.date(byAdding: .day, value: 1, to: dateFrom)
        // предикаты по дате
        let fromPredicate = NSPredicate(format: "date >= %@", dateFrom as NSDate)
        let toPredicate = NSPredicate(format: "date < %@",  dateTo! as NSDate)
        let datePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate, toPredicate])
        
        // запрос
        let catchRequest: NSFetchRequest<Fish> = Fish.fetchRequest()
        catchRequest.predicate = datePredicate
        do {
            caughtFishes = try coreDataStack.managedContext.fetch(catchRequest)
            
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
        print("\(caughtFishes.count) in TableView")
        
        totalCod = caughtFishes.filter { $0.name == FishTypes.cod.rawValue}
        totalHaddock = caughtFishes.filter { $0.name == FishTypes.haddock.rawValue }
        totalCatfish = caughtFishes.filter { $0.name == FishTypes.catfish.rawValue }
        totalRedfish = caughtFishes.filter { $0.name == FishTypes.redfish.rawValue }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    //    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        sections[section]
    //    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50)
        let headerView = UIView(frame: frame)
        
        // название в секции
        let nameLabel = UILabel()
        nameLabel.frame = CGRect(x: 10,
                                 y: 5,
                                 width: headerView.frame.width / 3,
                                 height: headerView.frame.height - 10)
        nameLabel.text = sections[section]
        nameLabel.font = .systemFont(ofSize: 16)
        nameLabel.backgroundColor = .lightGray
        nameLabel.textColor = .white
        
        // готовая за сутки в секции
        let frzWeightLabel = UILabel()
        frzWeightLabel.frame = CGRect(x: headerView.frame.width / 3 + 10,
                                      y: 5,
                                      width: headerView.frame.width / 3,
                                      height: headerView.frame.height - 10)
        var frzSumm: Double = 0
        switch nameLabel.text {
        case FishTypes.cod.rawValue:
            totalCod.forEach { frzSumm += $0.frozenBoard }
        case FishTypes.haddock.rawValue:
            totalHaddock.forEach { frzSumm += $0.frozenBoard }
        case FishTypes.catfish.rawValue:
            totalCatfish.forEach { frzSumm += $0.frozenBoard }
        default:
            totalRedfish.forEach { frzSumm += $0.frozenBoard }
        }
        frzWeightLabel.text = "Готовая за сутки: \(frzSumm)"
        frzWeightLabel.font = .systemFont(ofSize: 12)
        frzWeightLabel.backgroundColor = .darkGray
        frzWeightLabel.textColor = .white
        
        // вылов за сутки в секции
        let rawWeightLabel = UILabel()
        rawWeightLabel.frame = CGRect(x: (headerView.frame.width / 3) * 2 + 10,
                                      y: 5,
                                      width: headerView.frame.width / 3,
                                      height: headerView.frame.height - 10)
        var rawSumm: Double = 0
        switch nameLabel.text {
        case FishTypes.cod.rawValue:
            totalCod.forEach { rawSumm += $0.rawBoard }
        case FishTypes.haddock.rawValue:
            totalHaddock.forEach { rawSumm += $0.rawBoard }
        case FishTypes.catfish.rawValue:
            totalCatfish.forEach { rawSumm += $0.rawBoard }
        default:
            totalRedfish.forEach { rawSumm += $0.rawBoard }
        }
        rawWeightLabel.text = "Вылов за сутки: \(rawSumm)"
        rawWeightLabel.font = .systemFont(ofSize: 12)
        rawWeightLabel.backgroundColor = .black
        rawWeightLabel.textColor = .white
        
        headerView.addSubview(nameLabel)
        headerView.addSubview(frzWeightLabel)
        headerView.addSubview(rawWeightLabel)
        
        return headerView
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return totalCod.count
        case 1: return totalHaddock.count
        case 2: return totalCatfish.count
        default: return totalRedfish.count
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        switch indexPath.section {
        case 0:
            let fish = totalCod[indexPath.row]
            cell.textLabel?.text = fish.name
            cell.detailTextLabel?.text = fish.grade
        case 1:
            let fish = totalHaddock[indexPath.row]
            cell.textLabel?.text = fish.name
            cell.detailTextLabel?.text = fish.grade
        case 2:
            let fish = totalCatfish[indexPath.row]
            cell.textLabel?.text = fish.name
            cell.detailTextLabel?.text = fish.grade
        default:
            let fish = totalRedfish[indexPath.row]
            cell.textLabel?.text = fish.name
            cell.detailTextLabel?.text = fish.grade
        }
        return cell
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let indexPath = tableView.indexPathForSelectedRow {
            print(indexPath)
            var fish: Fish?
            switch indexPath.section {
            case 0: fish = totalCod[indexPath.row]
            case 1: fish = totalHaddock[indexPath.row]
            case 2: fish = totalCatfish[indexPath.row]
            default: fish = totalRedfish[indexPath.row]
            }
            let fullDescriptionVC = segue.destination as! FullDescriptionVC
            fullDescriptionVC.fish = fish
        }
        
    }
    
    
}
