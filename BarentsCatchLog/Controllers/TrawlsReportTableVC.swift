//
//  TrawlsReportTableVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 31.08.2021.
//

import UIKit
import CoreData

class TrawlsReportTableVC: UITableViewController {
    
    //MARK: - Public Properties
    lazy var coreDataStack = CoreDataStack(modelName: "BarentsCatchLog")
    
    //MARK: - Private Properties
    private var trawls: [Trawl] = []
    private var caughtFishesToday: [Fish] = []
    private var totalCodToday: [Fish] = []
    private var totalHaddockToday: [Fish] = []
    private var totalCatfishToday: [Fish] = []
    private var totalRedfishToday: [Fish] = []

    //MARK: - Life Cycle Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.system
        
        let dateFrom = calendar.startOfDay(for: Date())
        let dateTo = calendar.date(byAdding: .day, value: 1, to: dateFrom)
        
        let fromPredicate = NSPredicate(format: "date >= %@", dateFrom as NSDate)
        let toPredicate = NSPredicate(format: "date < %@",  dateTo! as NSDate)
        let datePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate, toPredicate])
        print(datePredicate)
        
        // запрос на тралы
        let trawlRequest: NSFetchRequest<Trawl> = Trawl.fetchRequest()
        trawlRequest.predicate = datePredicate
        
        do {
            trawls = try coreDataStack.managedContext.fetch(trawlRequest)
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
        print("Trawls count: \(trawls.count)")
        // запрос на рыбу
        let fishRequest: NSFetchRequest<Fish> = Fish.fetchRequest()
        fishRequest.predicate = datePredicate
        
        do {
            caughtFishesToday = try coreDataStack.managedContext.fetch(fishRequest)
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
        print("Fishes count: \(caughtFishesToday.count)")
        
        totalCodToday = caughtFishesToday.filter { $0.name == FishTypes.cod.rawValue }
        totalHaddockToday = caughtFishesToday.filter { $0.name == FishTypes.haddock.rawValue }
        
        divideFish(by: trawls.count)
        trawls.forEach { trawl in
            print(trawl)
        }
    }

    // MARK: - Table View Life Cycle Override Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        trawls.count
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        150
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trawlCell", for: indexPath) as! TrawlDescriptionCell
        let trawl = trawls[indexPath.row]
        
        cell.shootTimeLabel.text = "\(trawl.timeShoot!) \(trawl.dateShoot!)"
        cell.shootPointLabel.text = "\(trawl.latitudeShoot!) \(trawl.longitudeShoot!)"
        cell.hoistTimeLabel.text = "\(trawl.timeHoist!) \(trawl.dateHoist!)"
        cell.hoistPointLabel.text = "\(trawl.latitudeHoist!) \(trawl.longitudeHoist!)"
        
        cell.catch1Label.text = "Треска: \(trawl.codRaw)"
        cell.catch2Label.text = "Пикша: \(trawl.hadRaw)"
        cell.catch3Label.text = "Зубатка: \(trawl.catRaw)"
        cell.catch4Label.text = "Окунь: \(trawl.redRaw)"
        
        return cell
    }

    // MARK: - Navigation Override Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let trawl = trawls[indexPath.row]
            let trawlDescriptionVC = segue.destination as! TrawlDescriptionVC
            trawlDescriptionVC.trawl = trawl
        }
    }
}
    // MARK: - Extensions
extension TrawlsReportTableVC {
    func divideFish(by trawlsCount: Int) {
        switch trawlsCount {
        case 1:
            let trawl = trawls.first
            caughtFishesToday.forEach { fish in
                if fish.name == FishTypes.cod.rawValue {
                    var frzSumPerDay: Double = 0
                    totalCodToday.forEach { frzSumPerDay += $0.frozenPerDay}
                    trawl?.codRaw = (frzSumPerDay * Ratios.cod.rawValue).rounded()
                } else if fish.name == FishTypes.haddock.rawValue {
                    var rawSumPerDay: Double = 0
                    totalHaddockToday.forEach { rawSumPerDay += $0.frozenPerDay}
                    trawl?.hadRaw = (rawSumPerDay * Ratios.haddock.rawValue).rounded()
                } else if fish.name == FishTypes.catfish.rawValue {
                    trawl?.catRaw = fish.rawPerDay
                } else {
                    trawl?.redRaw = fish.rawPerDay
                }
            }
        case 2:
            let firstTrawl = trawls[0], secondTrawl = trawls[1]
            caughtFishesToday.forEach { fish in
                if fish.name == FishTypes.cod.rawValue {
                    var frzSumPerDay: Double = 0
                    totalCodToday.forEach { frzSumPerDay += $0.frozenPerDay }
                    let rawPerDay = (frzSumPerDay * Ratios.cod.rawValue).rounded()
                    firstTrawl.codRaw = (rawPerDay * 0.55).rounded()
                    secondTrawl.codRaw = rawPerDay - firstTrawl.codRaw
                    
                } else if fish.name == FishTypes.haddock.rawValue {
                    var frzSumPerDay: Double = 0
                    totalHaddockToday.forEach { frzSumPerDay += $0.frozenPerDay }
                    let rawPerDay = (frzSumPerDay * Ratios.haddock.rawValue).rounded()
                    firstTrawl.hadRaw = (rawPerDay * 0.55).rounded()
                    secondTrawl.hadRaw = rawPerDay - firstTrawl.hadRaw
                    
                } else if fish.name == FishTypes.catfish.rawValue {
                    firstTrawl.catRaw = (fish.rawPerDay * 0.55).rounded()
                    secondTrawl.catRaw = fish.rawPerDay - firstTrawl.catRaw
                    
                } else {
                    firstTrawl.redRaw = (fish.rawPerDay * 0.55).rounded()
                    secondTrawl.redRaw = fish.rawPerDay - firstTrawl.redRaw
                }
            }
        case 3:
            let firstTrawl = trawls[0], secondTrawl = trawls[1], thirdTrawl = trawls[2]
            caughtFishesToday.forEach { fish in
                if fish.name == FishTypes.cod.rawValue {
                    var frzSumPerDay: Double = 0
                    totalCodToday.forEach { frzSumPerDay += $0.frozenPerDay }
                    let rawPerDay = (frzSumPerDay * Ratios.cod.rawValue).rounded()
                    firstTrawl.codRaw = (rawPerDay * 0.35).rounded()
                    secondTrawl.codRaw = (rawPerDay * 0.40).rounded()
                    thirdTrawl.codRaw = rawPerDay - firstTrawl.codRaw - secondTrawl.codRaw
                    
                } else if fish.name == FishTypes.haddock.rawValue {
                    var frzSumPerDay: Double = 0
                    totalHaddockToday.forEach { frzSumPerDay += $0.frozenPerDay }
                    let rawPerDay = (frzSumPerDay * Ratios.haddock.rawValue).rounded()
                    firstTrawl.hadRaw = (rawPerDay * 0.35).rounded()
                    secondTrawl.hadRaw = (rawPerDay * 0.40).rounded()
                    thirdTrawl.hadRaw = rawPerDay - firstTrawl.hadRaw - secondTrawl.hadRaw
                    
                } else if fish.name == FishTypes.catfish.rawValue {
                    firstTrawl.catRaw = (fish.rawPerDay * 0.35).rounded()
                    secondTrawl.catRaw = (fish.rawPerDay * 0.40).rounded()
                    thirdTrawl.catRaw = fish.rawPerDay - firstTrawl.catRaw - secondTrawl.catRaw
                    
                } else {
                    firstTrawl.redRaw = (fish.rawPerDay * 0.35).rounded()
                    secondTrawl.redRaw = (fish.rawPerDay * 0.40).rounded()
                    thirdTrawl.redRaw = fish.rawPerDay - firstTrawl.redRaw - secondTrawl.redRaw
                }
            }
        case 4:
            let firstTrawl = trawls[0], secondTrawl = trawls[1], thirdTrawl = trawls[2], fourthTrawl = trawls[3]
            caughtFishesToday.forEach { fish in
                if fish.name == FishTypes.cod.rawValue {
                    var frzSumPerDay: Double = 0
                    totalCodToday.forEach { frzSumPerDay += $0.frozenPerDay }
                    let rawPerDay = (frzSumPerDay * Ratios.cod.rawValue).rounded()
                    firstTrawl.codRaw = (rawPerDay * 0.35).rounded()
                    secondTrawl.codRaw = (rawPerDay * 0.30).rounded()
                    thirdTrawl.codRaw = (rawPerDay * 0.15).rounded()
                    fourthTrawl.codRaw = rawPerDay - firstTrawl.codRaw - secondTrawl.codRaw - thirdTrawl.codRaw
                    
                } else if fish.name == FishTypes.haddock.rawValue {
                    var frzSumPerDay: Double = 0
                    totalHaddockToday.forEach { frzSumPerDay += $0.frozenPerDay }
                    let rawPerDay = (frzSumPerDay * Ratios.haddock.rawValue).rounded()
                    firstTrawl.hadRaw = (rawPerDay * 0.35).rounded()
                    secondTrawl.hadRaw = (rawPerDay * 0.30).rounded()
                    thirdTrawl.hadRaw = (rawPerDay * 0.15).rounded()
                    fourthTrawl.hadRaw = rawPerDay - firstTrawl.hadRaw - secondTrawl.hadRaw - thirdTrawl.hadRaw
                    
                } else if fish.name == FishTypes.catfish.rawValue {
                    firstTrawl.catRaw = (fish.rawPerDay * 0.35).rounded()
                    secondTrawl.catRaw = (fish.rawPerDay * 0.30).rounded()
                    thirdTrawl.catRaw = (fish.rawPerDay * 0.15).rounded()
                    fourthTrawl.catRaw = fish.rawPerDay - firstTrawl.catRaw - secondTrawl.catRaw - thirdTrawl.catRaw
                    
                } else {
                    firstTrawl.redRaw = (fish.rawPerDay * 0.35).rounded()
                    secondTrawl.redRaw = (fish.rawPerDay * 0.30).rounded()
                    thirdTrawl.redRaw = (fish.rawPerDay * 0.15).rounded()
                    fourthTrawl.redRaw = fish.rawPerDay - firstTrawl.redRaw - secondTrawl.redRaw - thirdTrawl.redRaw
                }
            }
        default:
            print(trawlsCount)
        }
        coreDataStack.saveContext()
    }
}

