//
//  ReportTVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 07.09.2021.
//

import UIKit
import CoreData

class ReportTVC: UITableViewController {
    
    // MARK: - Public Properties
    lazy var coreDataStack = CoreDataStack(modelName: "BarentsCatchLog")
    var fetchRequest: NSFetchRequest<Fish>?
    
    
    // MARK: - Private Properties
    private let toDateChoiceID = "toDateChoiceTVC"
    private let toReportDescriptionID = "toReportDecriptionTVC"
    private var caughtFishes: [Fish] = []
    private var totalCatch: Double = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reportCell")
        fetchRequest = Fish.fetchRequest()
        fetchAndReload()
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == toDateChoiceID,
              let navController = segue.destination as? DateChoiceTVCNC,
              let dateChoiceTVC = navController.topViewController as? DateChoiceTVC else { return }
        dateChoiceTVC.coreDataStack = coreDataStack
        dateChoiceTVC.delegate = self
    }
    // MARK: - Private Methods
    private func fetchAndReload() {
        guard let fetchRequest = fetchRequest else { return }
        print(fetchRequest.predicate ?? "1 no predicate")
        do {
            caughtFishes = try coreDataStack.managedContext.fetch(fetchRequest)
            print(caughtFishes.count)
            totalCatch = 0
            caughtFishes.forEach { totalCatch += $0.rawPerDay }
            print(totalCatch)
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
}
// MARK: - Navigation


// MARK: - UITableViewDataSource, UITableViewDelegate
extension ReportTVC {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "reportCell", for: indexPath)
        cell = UITableViewCell(style: .value1, reuseIdentifier: "reportCell")
        cell.accessoryType = .disclosureIndicator
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "Отчет"
            cell.detailTextLabel?.text = "Всего"
        default:
            cell.textLabel?.text = String(format: "%.0f", totalCatch) + " кг"
            cell.textLabel?.textColor = .systemGreen
            cell.detailTextLabel?.text = "Количество тралов"
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            performSegue(withIdentifier: toDateChoiceID, sender: nil)
        default:
            performSegue(withIdentifier: toReportDescriptionID, sender: nil)
        }
    }
}
// MARK: - DateChoiceTVCDelegate
extension ReportTVC: DateChoiceTVCDelegate {
    
    func getNewPredicate(filter: DateChoiceTVC, didSelectPredicate predicate: NSCompoundPredicate?) {
        guard let fetchRequest = fetchRequest else { return }
        print(fetchRequest.predicate ?? "2 no predicate")
        fetchRequest.predicate = nil
        print(fetchRequest.predicate ?? "3 no predicate")
        fetchRequest.predicate = predicate
        print(fetchRequest.predicate ?? "4 no predicate")
        
        fetchAndReload()
    }
}
