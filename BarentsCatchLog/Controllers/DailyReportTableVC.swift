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
    private var caughtFishesToday: [Fish] = []
    private var totalCodToday: [Fish] = []
    private var totalHaddockToday: [Fish] = []
    private var totalCatfishToday: [Fish] = []
    private var totalRedfishToday: [Fish] = []
    
    // добавить здесь "ВСЕГО" и описать в методах Table View поведение лейблов (считать по всем массивам)
    private let sections = [FishTypes.cod.rawValue,
                            FishTypes.haddock.rawValue,
                            FishTypes.catfish.rawValue,
                            FishTypes.redfish.rawValue]
    
    // MARK: - Life Cycle Override Methods
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
            caughtFishesToday = try coreDataStack.managedContext.fetch(catchRequest)
            
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
        print("\(caughtFishesToday.count) in TableView")
        
        totalCodToday = caughtFishesToday.filter { $0.name == FishTypes.cod.rawValue}
        totalHaddockToday = caughtFishesToday.filter { $0.name == FishTypes.haddock.rawValue }
        totalCatfishToday = caughtFishesToday.filter { $0.name == FishTypes.catfish.rawValue }
        totalRedfishToday = caughtFishesToday.filter { $0.name == FishTypes.redfish.rawValue }
    }
    
    // MARK: - Table View Override Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50)
        let headerView = UIView(frame: frame)
        
        // название в секции
        let nameLabel = UILabel()
        nameLabel.frame = CGRect(x: 0,
                                 y: 5,
                                 width: headerView.frame.width,
                                 height: headerView.frame.height - 5)
        nameLabel.text = sections[section]
        nameLabel.font = .systemFont(ofSize: 25)
        nameLabel.textAlignment = .center
        nameLabel.backgroundColor = .lightGray
        nameLabel.textColor = .black
        
        headerView.addSubview(nameLabel)
        return headerView
    }
    // Footer
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 80)
        let footerView = UIView(frame: frame)
        
        // готовая за сутки
        let frzPerDayLabel = UILabel()
        frzPerDayLabel.frame = CGRect(x: 0,
                                      y: 5,
                                      width: footerView.frame.width / 4,
                                      height: footerView.frame.height - 5)
        var frzSummPerDay: Double = 0
        switch sections[section] {
        case FishTypes.cod.rawValue:
            totalCodToday.forEach { frzSummPerDay += $0.frozenPerDay }
        case FishTypes.haddock.rawValue:
            totalHaddockToday.forEach { frzSummPerDay += $0.frozenPerDay }
        case FishTypes.catfish.rawValue:
            totalCatfishToday.forEach { frzSummPerDay += $0.frozenPerDay }
        default:
            totalRedfishToday.forEach { frzSummPerDay += $0.frozenPerDay }
        }
        frzPerDayLabel.text = "Готовая за сутки ВСЕГО: \(frzSummPerDay)"
        frzPerDayLabel.numberOfLines = 0
        frzPerDayLabel.font = .systemFont(ofSize: 12)
        frzPerDayLabel.textAlignment = .center
        
        // готовая на борту
        let frzOnBoardLabel = UILabel()
        frzOnBoardLabel.frame = CGRect(x: footerView.frame.width / 4,
                                      y: 5,
                                      width: footerView.frame.width / 4,
                                      height: footerView.frame.height - 5)
        var frzSummOnBoard: Double = 0
        switch sections[section] {
        case FishTypes.cod.rawValue:
            totalCodToday.forEach { frzSummOnBoard += $0.frozenBoard }
        case FishTypes.haddock.rawValue:
            totalHaddockToday.forEach { frzSummOnBoard += $0.frozenBoard }
        case FishTypes.catfish.rawValue:
            if let totalCatfishToday = totalCatfishToday.first {
                frzSummOnBoard = totalCatfishToday.frozenBoard
            }
        default:
            if let totalRedfishToday = totalRedfishToday.first {
                frzSummOnBoard = totalRedfishToday.frozenBoard
            }
        }
        frzOnBoardLabel.text = "Готовая на борту ВСЕГО: \(frzSummOnBoard)"
        frzOnBoardLabel.numberOfLines = 0
        frzOnBoardLabel.font = .systemFont(ofSize: 12)
        frzOnBoardLabel.textAlignment = .center
        
        // вылов за сутки
        let rawPerDayLabel = UILabel()
        rawPerDayLabel.frame = CGRect(x: (footerView.frame.width / 4) * 2,
                                      y: 5,
                                      width: footerView.frame.width / 4,
                                      height: footerView.frame.height - 5)
        var rawSummPerDay: Double = 0
        switch sections[section] {
        case FishTypes.cod.rawValue:
            rawSummPerDay = (frzSummPerDay * Ratios.cod.rawValue).rounded()
        case FishTypes.haddock.rawValue:
            rawSummPerDay = (frzSummPerDay * Ratios.haddock.rawValue).rounded()
        case FishTypes.catfish.rawValue:
            if let catfishRawPerDay = totalCatfishToday.first?.rawPerDay {
                rawSummPerDay = catfishRawPerDay
            }
        default:
            if let redfishRawPerDay = totalRedfishToday.first?.rawPerDay {
                rawSummPerDay = redfishRawPerDay
            }
        }
        rawPerDayLabel.text = "Вылов за сутки ВСЕГО: \(rawSummPerDay)"
        rawPerDayLabel.font = .systemFont(ofSize: 12)
        rawPerDayLabel.numberOfLines = 0
        rawPerDayLabel.textAlignment = .center
        
        // вылов на борту
        let rawOnBoardLabel = UILabel()
        rawOnBoardLabel.frame = CGRect(x: (footerView.frame.width / 4) * 3,
                                      y: 5,
                                      width: footerView.frame.width / 4,
                                      height: footerView.frame.height - 5)
        var rawSummOnBoard: Double = 0
        switch sections[section] {
        case FishTypes.cod.rawValue:
            rawSummOnBoard = (frzSummOnBoard * Ratios.cod.rawValue).rounded()
        case FishTypes.haddock.rawValue:
            rawSummOnBoard = (frzSummOnBoard * Ratios.haddock.rawValue).rounded()
        case FishTypes.catfish.rawValue:
            if let catfishRawPerDay = totalCatfishToday.first?.rawBoard {
                rawSummOnBoard = catfishRawPerDay
            }
        default:
            if let redfishRawPerDay = totalRedfishToday.first?.rawBoard {
                rawSummOnBoard = redfishRawPerDay
            }
        }
        rawOnBoardLabel.text = "Вылов за сутки ВСЕГО: \(rawSummOnBoard)"
        rawOnBoardLabel.font = .systemFont(ofSize: 12)
        rawOnBoardLabel.numberOfLines = 0
        rawOnBoardLabel.textAlignment = .center
        
        footerView.addSubview(frzPerDayLabel)
        footerView.addSubview(frzOnBoardLabel)
        footerView.addSubview(rawPerDayLabel)
        footerView.addSubview(rawOnBoardLabel)
        
        return footerView
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        80
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return totalCodToday.count
        case 1: return totalHaddockToday.count
        case 2: return totalCatfishToday.count
        default: return totalRedfishToday.count
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dailyReportCell", for: indexPath) as! DailyCatchCell
        switch indexPath.section {
        case 0:
            let fish = totalCodToday[indexPath.row]
            cell.nameLabel.text = fish.name
            cell.gradeLabel.text = fish.grade
            cell.frzPerDayLabel.text = "Готовая за сутки: \(fish.frozenPerDay)"
            cell.frzOnBoardLabel.text = "Готовая на борту: \(fish.frozenBoard)"
            cell.rawPerDayLabel.isHidden = true
            cell.rawOnBoardLabel.isHidden = true
            
        case 1:
            let fish = totalHaddockToday[indexPath.row]
            cell.nameLabel.text = fish.name
            cell.gradeLabel.text = fish.grade
            cell.frzPerDayLabel.text = "Готовая за сутки: \(fish.frozenPerDay)"
            cell.frzOnBoardLabel.text = "Готовая на борту: \(fish.frozenBoard)"
            cell.rawPerDayLabel.isHidden = true
            cell.rawOnBoardLabel.isHidden = true
            
        case 2:
            let fish = totalCatfishToday[indexPath.row]
            cell.nameLabel.text = fish.name
            cell.gradeLabel.text = fish.grade
            cell.frzPerDayLabel.text = "Готовая за сутки: \(fish.frozenPerDay)"
            cell.frzOnBoardLabel.text = "Готовая на борту: \(fish.frozenBoard)"
            cell.rawPerDayLabel.text = "Вылов за сутки: \(fish.rawPerDay)"
            cell.rawOnBoardLabel.text = "Вылов на борту: \(fish.rawBoard)"
        default:
            let fish = totalRedfishToday[indexPath.row]
            cell.nameLabel.text = fish.name
            cell.gradeLabel.text = fish.grade
            cell.frzPerDayLabel.text = "Готовая за сутки: \(fish.frozenPerDay)"
            cell.frzOnBoardLabel.text = "Готовая на борту: \(fish.frozenBoard)"
            cell.rawPerDayLabel.text = "Вылов за сутки: \(fish.rawPerDay)"
            cell.rawOnBoardLabel.text = "Вылов на борту: \(fish.rawBoard)"
        }
        return cell
    }   
}
