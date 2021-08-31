//
//  TrawlsReportTableVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 31.08.2021.
//

import UIKit
import CoreData

class TrawlsReportTableVC: UITableViewController {
    
    lazy var coreDataStack = CoreDataStack(modelName: "BarentsCatchLog")
    var trawls: [Trawl] = []
    var fishes: [Fish] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Get the current calendar with local time zone
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.system
        
        // Get today's beginning & end
        let dateFrom = calendar.startOfDay(for: Date()) // eg. 2016-10-10 00:00:00
        let dateTo = calendar.date(byAdding: .day, value: 1, to: dateFrom)
        
        let fromPredicate = NSPredicate(format: "date >= %@", dateFrom as NSDate)
        let toPredicate = NSPredicate(format: "date < %@",  dateTo! as NSDate)
        let datePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate, toPredicate])
        print(datePredicate)
        
        // запрос на тралы
        let trawlRequest: NSFetchRequest<Trawl> = Trawl.fetchRequest()
        
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
            fishes = try coreDataStack.managedContext.fetch(fishRequest)
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
        print("Fishes count: \(fishes.count)")
        
        divideFish(by: trawls.count)
        trawls.forEach { trawl in
            print(trawl)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        trawls.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trawlCell", for: indexPath)
        let trawl = trawls[indexPath.row]
        
        cell.textLabel?.text = trawl.id
        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let trawl = trawls[indexPath.row]
            let trawlDescriptionVC = segue.destination as! TrawlDescriptionVC
            trawlDescriptionVC.trawl = trawl
        }
    }
}
extension TrawlsReportTableVC {
    func divideFish(by trawlsCount: Int) {
        
        switch trawlsCount {
        case 1:
            let trawl = trawls.first
            fishes.forEach { fish in
                if fish.name == FishTypes.cod.rawValue {
                    trawl?.codRaw = fish.rawPerDay
                } else if fish.name == FishTypes.haddock.rawValue {
                    trawl?.hadRaw = fish.rawPerDay
                } else if fish.name == FishTypes.catfish.rawValue {
                    trawl?.catRaw = fish.rawPerDay
                } else {
                    trawl?.redRaw = fish.rawPerDay
                }
            }
        case 2:
            let firstTrawl = trawls[0], secondTrawl = trawls[1]
            fishes.forEach { fish in
                if fish.name == FishTypes.cod.rawValue {
                    firstTrawl.codRaw = (fish.rawPerDay * 0.55).rounded()
                    secondTrawl.codRaw = fish.rawPerDay - firstTrawl.codRaw
                    
                } else if fish.name == FishTypes.haddock.rawValue {
                    firstTrawl.hadRaw = (fish.rawPerDay * 0.55).rounded()
                    secondTrawl.hadRaw = fish.rawPerDay - firstTrawl.hadRaw
                    
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
            fishes.forEach { fish in
                if fish.name == FishTypes.cod.rawValue {
                    firstTrawl.codRaw = (fish.rawPerDay * 0.35).rounded()
                    secondTrawl.codRaw = (fish.rawPerDay * 0.40).rounded()
                    thirdTrawl.codRaw = fish.rawPerDay - firstTrawl.codRaw - secondTrawl.codRaw
                    
                } else if fish.name == FishTypes.haddock.rawValue {
                    firstTrawl.hadRaw = (fish.rawPerDay * 0.35).rounded()
                    secondTrawl.hadRaw = (fish.rawPerDay * 0.40).rounded()
                    thirdTrawl.hadRaw = fish.rawPerDay - firstTrawl.hadRaw - secondTrawl.hadRaw
                    
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
            fishes.forEach { fish in
                if fish.name == FishTypes.cod.rawValue {
                    firstTrawl.codRaw = (fish.rawPerDay * 0.35).rounded()
                    secondTrawl.codRaw = (fish.rawPerDay * 0.30).rounded()
                    thirdTrawl.codRaw = (fish.rawPerDay * 0.15).rounded()
                    fourthTrawl.codRaw = fish.rawPerDay - firstTrawl.codRaw - secondTrawl.codRaw - thirdTrawl.codRaw
                    
                } else if fish.name == FishTypes.haddock.rawValue {
                    firstTrawl.hadRaw = (fish.rawPerDay * 0.35).rounded()
                    secondTrawl.hadRaw = (fish.rawPerDay * 0.30).rounded()
                    thirdTrawl.hadRaw = (fish.rawPerDay * 0.15).rounded()
                    fourthTrawl.hadRaw = fish.rawPerDay - firstTrawl.hadRaw - secondTrawl.hadRaw - thirdTrawl.hadRaw
                    
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

