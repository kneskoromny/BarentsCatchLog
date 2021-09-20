//
//  DateChoiceTVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 07.09.2021.
//

import UIKit
import CoreData

protocol AddReportVCDelegate {
    func newReportDidCreated(report: Report)
}

struct ReportTemplate {
    let id: String
    let fish: String?
    let dateFrom: Date
    let dateTo: Date
}

class ReportChoiceVC: UITableViewController {
    
    // MARK: - Properties
    var coreDataStack: CoreDataStack!
    weak var delegate: ReportChoiceVCDelegate?
    var selectedPredicate: NSCompoundPredicate?
    var selectedTextLabel: String?
    
    // MARK: - Private Properties
    private var reports: [Report] = []
    private var reportTemplates: [ReportTemplate] = []
    private var sections = ["Шаблоны", "Пользовательские"]
    private var isEditingTableView = true
    
    var dateFrom: Date?
    var dateTo: Date?
    
    // MARK: - Data For Predicates
    var fishPredicate: NSPredicate?
    var gradePredicate: NSPredicate?
    var dateFromPredicate: NSPredicate?
    var dateToPredicate: NSPredicate?
    
    var predicates: [NSPredicate]?
    
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getReportTemplates()
          
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let fetchRequest: NSFetchRequest<Report> = Report.fetchRequest()
        do {
            reports = try coreDataStack.managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
        print("\(reports.count) reports in viewWillAppear")
        print("\(reportTemplates.count) templates in viewWillAppear")
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navController = segue.destination as? AddReportTVCNC,
              let addReportTVC = navController.topViewController as? AddReportVC else { return }
        addReportTVC.delegate = self
    }
    // MARK: - IB Actions
    @IBAction func getReportBtnPressed(_ sender: UIBarButtonItem) {
        guard let selectedPredicate = selectedPredicate,
              let selectedTextLabel = selectedTextLabel else {
            showAlert(title: "Внимание!", message: "Не выбран тип отчета.")
            return
        }
        delegate?.getNewPredicate(filter: self,
                                  didSelectPredicate: selectedPredicate,
                                  and: selectedTextLabel)
        dismiss(animated: true)
        
    }
    
    @IBAction func deleteReportsBtnPressed(_ sender: UIBarButtonItem) {
        tableView.setEditing(isEditingTableView, animated: true)
        isEditingTableView.toggle()
    }
    // MARK: - Private Methods
    private func getPredicates(from report: Report) {
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
    }
    
    private func getPredicatesFromTemplate(from template: ReportTemplate) {
        var totalPredicates: [NSPredicate] = []
        
        if let fishFromTemplate = template.fish {
            fishPredicate = NSPredicate(format: "%K == %@", #keyPath(Fish.name), fishFromTemplate)
            totalPredicates.append(fishPredicate!)
        }
        
        let dateFrom = template.dateFrom
        let startOfDateFrom = Calendar.current.startOfDay(for: dateFrom)
        dateFromPredicate = NSPredicate(format: "date >= %@", startOfDateFrom as NSDate)
        totalPredicates.append(dateFromPredicate!)
        
        let dateTo = template.dateTo
        let startOfDateTo = Calendar.current.startOfDay(for: dateTo)
        let endOfDayTo = Calendar.current.date(byAdding: .day, value: 1, to: startOfDateTo)
        dateToPredicate = NSPredicate(format: "date < %@", endOfDayTo! as NSDate)
        totalPredicates.append(dateToPredicate!)
        
        selectedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: totalPredicates)
        selectedTextLabel = template.id
    }
    private func getReportTemplates()  {
        let todayTemplate = ReportTemplate(id: ReportTemplateIDs.allFishForToday.rawValue,
                                           fish: nil,
                                           dateFrom: Date(),
                                           dateTo: Date())
        reportTemplates.append(todayTemplate)
        
        let yesterdayTemplate = ReportTemplate(id: ReportTemplateIDs.allFishForYesterday.rawValue,
                                               fish: nil,
                                               dateFrom: Date.yesterday,
                                               dateTo: Date.yesterday)
        reportTemplates.append(yesterdayTemplate)
        
        let monday = Date.today().previous(.monday)
        let sunday = Date.today().next(.sunday)
        let thisWeekTemplate = ReportTemplate(id: ReportTemplateIDs.allFishForThisWeek.rawValue,
                                              fish: nil,
                                              dateFrom: monday,
                                              dateTo: sunday)
        reportTemplates.append(thisWeekTemplate)
        
        let todayCodTemplate = ReportTemplate(id: ReportTemplateIDs.allCodForToday.rawValue,
                                              fish: FishTypes.cod.rawValue,
                                              dateFrom: Date(),
                                              dateTo: Date())
        reportTemplates.append(todayCodTemplate)
        
        let yesterdayCodTemplate = ReportTemplate(id:ReportTemplateIDs.allCodForYesterday.rawValue,
                                                  fish: FishTypes.cod.rawValue,
                                                  dateFrom: Date.yesterday,
                                                  dateTo: Date.yesterday)
        reportTemplates.append(yesterdayCodTemplate)
        
        let todayHaddockTemplate = ReportTemplate(id:ReportTemplateIDs.allHaddockForToday.rawValue,
                                                  fish: FishTypes.haddock.rawValue,
                                                  dateFrom: Date(),
                                                  dateTo: Date())
        reportTemplates.append(todayHaddockTemplate)
        
        let yesterdayHaddockTemplate = ReportTemplate(id: ReportTemplateIDs.allHaddockForYesterday.rawValue,
                                                      fish: FishTypes.haddock.rawValue,
                                                      dateFrom: Date.yesterday,
                                                      dateTo: Date.yesterday)
        reportTemplates.append(yesterdayHaddockTemplate)
    }
    
}
// MARK: - TableViewDatasource
extension ReportChoiceVC {
    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section]
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return reportTemplates.count
        default:
            return reports.count
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reportCell", for: indexPath)
        cell.textLabel?.textColor = .systemGray
        switch indexPath.section {
        case 0:
            let reportTemplate = reportTemplates[indexPath.row]
            cell.textLabel?.text = reportTemplate.id
        default:
            let reportUser = reports[indexPath.row]
            cell.textLabel?.text = reportUser.id
        }
        return cell
    }
}
// MARK: - TableViewDelegate
extension ReportChoiceVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fetchRequest: NSFetchRequest<Report> = Report.fetchRequest()
        do {
            reports = try coreDataStack.managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
        guard let cell =  tableView.cellForRow(at: indexPath) else { return }
        
        switch indexPath.section {
        case 0:
            let reportTemplate = reportTemplates[indexPath.row]
            getPredicatesFromTemplate(from: reportTemplate)
        default:
            let reportUser = reports[indexPath.row]
            getPredicates(from: reportUser)
        }
        
        cell.accessoryType = .checkmark
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            switch indexPath.section {
            case 0:
                showAlert(title: "Внимание!", message: "Этот тип отчета удалить нельзя.")
            default:
                let report = reports[indexPath.row]
                reports.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
                coreDataStack.managedContext.delete(report)
                coreDataStack.saveContext()
            }
        }
    }
}
// MARK: - AddReportTVCDelegate
extension ReportChoiceVC: AddReportVCDelegate {
    func newReportDidCreated(report: Report) {
        reports.append(report)
        tableView.insertRows(at: [IndexPath(row: reports.count - 1, section: 1)],
                             with: .automatic)
    }
}
// MARK: - AlertController
extension ReportChoiceVC {
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "OK",
                                       style: .default) { action in
            if let completion = completion {
                completion()
            }
        }
        alert.addAction(doneAction)
        
        present(alert, animated: true)
    }
}
