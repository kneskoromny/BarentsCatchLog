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
    // передать в препер
    var coreDataStack: CoreDataStack!
    weak var delegate: ReportChoiceTVCDelegate?
    var selectedPredicate: NSCompoundPredicate?
    var selectedTextLabel: String?
    
    // MARK: - Private Properties
    private var dateFrom: Date?
    private var dateTo: Date?
    private var reports: [Report] = []
    
    private var isEditingTableView = true
    
    // MARK: - Date Predicates
   
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let fetchRequest: NSFetchRequest<Report> = Report.fetchRequest()
        do {
            reports = try coreDataStack.managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print(reports.count)
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
        guard let cell =  tableView.cellForRow(at: indexPath) else { return }

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
        print(reports.count)
    }
}
