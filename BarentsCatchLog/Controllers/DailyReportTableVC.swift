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
    
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get the current calendar with local time zone
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.system
        
        // Get today's beginning & end
        let dateFrom = calendar.startOfDay(for: Date()) // eg. 2016-10-10 00:00:00
        print(dateFrom)
        let dateTo = calendar.date(byAdding: .day, value: 1, to: dateFrom)
        print(dateTo)
        
        let fromPredicate = NSPredicate(format: "date >= %@", dateFrom as NSDate)
        let toPredicate = NSPredicate(format: "date < %@",  dateTo! as NSDate)
        
        let datePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate, toPredicate])
        print(datePredicate)
        
        // запрос
        let catchRequest: NSFetchRequest<Fish> = Fish.fetchRequest()
        catchRequest.predicate = datePredicate
        do {
            caughtFishes = try coreDataStack.managedContext.fetch(catchRequest)
            
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
        print("\(caughtFishes.count) in TableView")
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return caughtFishes.count
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        let fish = caughtFishes[indexPath.row]
        print(fish.date)
        
        cell.textLabel?.text = fish.name
        return cell
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let fish = caughtFishes[indexPath.row]
            
            let fullDescriptionVC = segue.destination as! FullDescriptionVC
            fullDescriptionVC.fish = fish
        }
    }
    
    
}
