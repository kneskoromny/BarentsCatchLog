//
//  DateChoiceTVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 07.09.2021.
//

import UIKit
import CoreData

protocol AddReportTVCDelegate {
    func newReportDidCreated(report: Report)
}
class ReportChoiceTVC: UITableViewController {
    
    // MARK: - Properties
    var coreDataStack: CoreDataStack!
    weak var delegate: ReportChoiceTVCDelegate?
    var selectedPredicate: NSCompoundPredicate?
    var selectedTextLabel: String?
    
    // MARK: - Private Properties
    private var reports: [Report] = []
    private var isEditingTableView = true
    
    // MARK: - Data For Predicates
    var fishPredicate: NSPredicate?
    var gradePredicate: NSPredicate?
    var dateFromPredicate: NSPredicate?
    var dateToPredicate: NSPredicate?
    
    var predicates: [NSPredicate]?
   
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let fetchRequest: NSFetchRequest<Report> = Report.fetchRequest()
        do {
            reports = try coreDataStack.managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
        print("\(reports.count) in viewWillAppear")
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navController = segue.destination as? AddReportTVCNC,
              let addReportTVC = navController.topViewController as? AddReportTVC else { return }
        addReportTVC.delegate = self
    }
    // MARK: - IB Actions
    @IBAction func getReportBtnPressed(_ sender: UIBarButtonItem) {
        delegate?.getNewPredicate(filter: self,
                                  didSelectPredicate: selectedPredicate,
                                  and: selectedTextLabel!)
        dismiss(animated: true)    }
    
    @IBAction func deleteReportsBtnPressed(_ sender: UIBarButtonItem) {
        tableView.setEditing(isEditingTableView, animated: true)
        isEditingTableView.toggle()
    }
    // MARK: - Private Methods
    private func getPredicates(from report: Report) {
        print(report)
        var totalPredicates: [NSPredicate] = []
        
        if let fishFromReport = report.fish {
            fishPredicate = NSPredicate(format: "%K == %@", #keyPath(Fish.name), fishFromReport)
            totalPredicates.append(fishPredicate!)
        }
        if let gradeFromReport = report.grade {
            gradePredicate = NSPredicate(format: "%K == %@", #keyPath(Fish.grade), gradeFromReport)
            totalPredicates.append(gradePredicate!)
        }
        if let dateFrom = report.dateFrom {
            let startOfDateFrom = Calendar.current.startOfDay(for: dateFrom)
            dateFromPredicate = NSPredicate(format: "date >= %@", startOfDateFrom as NSDate)
            totalPredicates.append(dateFromPredicate!)
        }
        if let dateTo = report.dateTo {
            let startOfDateTo = Calendar.current.startOfDay(for: dateTo)
            let endOfDayTo = Calendar.current.date(byAdding: .day, value: 1, to: startOfDateTo)
            dateToPredicate = NSPredicate(format: "date < %@", endOfDayTo! as NSDate)
            totalPredicates.append(dateToPredicate!)
        }
        selectedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: totalPredicates)
        selectedTextLabel = report.id
        
        print("Total predicates count - \(totalPredicates.count)")
        print("Predicates: fish - \(String(describing: fishPredicate)), grade - \(String(describing: gradePredicate)), dateFrom - \(String(describing: dateFromPredicate)), dateTo - \(String(describing: dateToPredicate))")
        
    }
}
// MARK: -UITableViewDatasource
extension ReportChoiceTVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        reports.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reportCell", for: indexPath)
        let report = reports[indexPath.row]
        
        cell.textLabel?.text = report.id

        return cell
    }
}
// MARK: - UITableViewDelegate
extension ReportChoiceTVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fetchRequest: NSFetchRequest<Report> = Report.fetchRequest()
        do {
            reports = try coreDataStack.managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
        
        guard let cell =  tableView.cellForRow(at: indexPath) else { return }
        let report = reports[indexPath.row]
        print("report in didSelectRow: \(report)")
        getPredicates(from: report)

        cell.accessoryType = .checkmark
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let report = reports[indexPath.row]
            reports.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            coreDataStack.managedContext.delete(report)
            coreDataStack.saveContext()
        }
    }
}
// MARK: - AddReportTVCDelegate
extension ReportChoiceTVC: AddReportTVCDelegate {
    func newReportDidCreated(report: Report) {
        reports.append(report)
        tableView.insertRows(at: [IndexPath(row: reports.count - 1, section: 0)],
                             with: .automatic)
    }
}
