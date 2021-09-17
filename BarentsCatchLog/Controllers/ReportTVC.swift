//
//  ReportTVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 07.09.2021.
//

import UIKit
import CoreData

protocol ReportChoiceTVCDelegate: AnyObject {
    func getNewPredicate(
        filter: ReportChoiceTVC,
        didSelectPredicate predicate: NSCompoundPredicate?,
        and textLabel: String
    )
}

class ReportTVC: UITableViewController {
    
    // MARK: - Public Properties
    lazy var coreDataStack = CoreDataStack(modelName: "BarentsCatchLog")
    var fetchRequest: NSFetchRequest<Fish>?
    
    
    // MARK: - Private Properties
    private let toDateChoiceID = "toDateChoiceTVC"
    private let toReportDescriptionID = "toReportDecriptionTVC"
    private var caughtFishes: [Fish] = []
    private var totalFrz: Double = 0
    private var detailTextLabel = "Всего"
    private var flag: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reportCell")
        fetchRequest = Fish.fetchRequest()
        fetchAndReload()
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == toDateChoiceID {
           guard let navController = segue.destination as? ReportChoiceTVCNC,
                let dateChoiceTVC = navController.topViewController as? ReportChoiceTVC else { return
                }
            dateChoiceTVC.coreDataStack = coreDataStack
            dateChoiceTVC.delegate = self
        } else if segue.identifier == toReportDescriptionID {
            guard let reportDecriptionTVC = segue.destination as? ReportDescriptionTVC else {
                return
            }
            flag = isOneFishType(fishes: caughtFishes)
            reportDecriptionTVC.caughtFishes = caughtFishes
            reportDecriptionTVC.flag = flag
        }
    }
    // MARK: - Private Methods
    private func fetchAndReload() {
        guard let fetchRequest = fetchRequest else { return }
        print("Working predicate is: \(String(describing: fetchRequest.predicate))")
        do {
            caughtFishes = try coreDataStack.managedContext.fetch(fetchRequest)
            print("caught fishes count from fetch \(caughtFishes.count)")
            totalFrz = 0
            caughtFishes.forEach { totalFrz += $0.perDay }
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    private func isOneFishType(fishes: [Fish]) -> Bool {
        let fishFromCatch = fishes.first
        let filteredFishes = fishes.filter { fish in
            fish.name == fishFromCatch?.name
        }
        return filteredFishes.count == fishes.count ? true : false
        
    }
}
// MARK: - UITableViewDataSource, UITableViewDelegate
extension ReportTVC {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "reportCell", for: indexPath)
        cell = UITableViewCell(style: .value1, reuseIdentifier: "reportCell")
        cell.accessoryType = .disclosureIndicator
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "Отчет"
            cell.detailTextLabel?.text = detailTextLabel
        default:
            cell.textLabel?.text = String(format: "%.0f", totalFrz) + " кг"
            cell.textLabel?.textColor = .systemGreen
            cell.detailTextLabel?.text = "Количество записей: \(caughtFishes.count)"
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
extension ReportTVC: ReportChoiceTVCDelegate {
    
    func getNewPredicate(filter: ReportChoiceTVC,
                         didSelectPredicate predicate: NSCompoundPredicate?,
                         and textLabel: String) {
        guard let fetchRequest = fetchRequest else { return }
        
            fetchRequest.predicate = nil
            fetchRequest.predicate = predicate
            detailTextLabel = textLabel
            
            fetchAndReload()
    }
}
// MARK: - AlertController
extension ReportTVC {
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
