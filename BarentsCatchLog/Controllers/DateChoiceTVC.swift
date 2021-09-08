//
//  DateChoiceTVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 07.09.2021.
//

import UIKit
import CoreData

protocol DateChoiceTVCDelegate: AnyObject {
    func getNewPredicate(
        filter: DateChoiceTVC,
        didSelectPredicate predicate: NSCompoundPredicate?,
        and textLabel: String
    )
}

class DateChoiceTVC: UITableViewController {
    
    // MARK: - Дата Секция
    @IBOutlet weak var todayChoiceCell: UITableViewCell!
    @IBOutlet weak var yesterdayChoiceCell: UITableViewCell!
    
    // MARK: - Properties
    // передать в препер
    var coreDataStack: CoreDataStack!
    weak var delegate: DateChoiceTVCDelegate?
    var selectedPredicate: NSCompoundPredicate?
    var selectedTextLabel: String?
    
    // MARK: - Private Properties
    var dateFrom: Date?
    var dateTo: Date?
    
    // MARK: - Date Predicates
   
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        todayChoiceCell.textLabel?.text = "Сегодня"
        yesterdayChoiceCell.textLabel?.text = "Вчера"
    }
    
    // MARK: - IB Actions
    @IBAction func getReportBtnPressed(_ sender: UIBarButtonItem) {
        delegate?.getNewPredicate(filter: self,
                                  didSelectPredicate: selectedPredicate,
                                  and: selectedTextLabel!)
        dismiss(animated: true)    }
    
}
// MARK: - UITableViewDelegate
extension DateChoiceTVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell =  tableView.cellForRow(at: indexPath) else { return }
        
        switch cell {
        case todayChoiceCell:
            selectedPredicate = FormulaStack().getDatePredicate(for: Date())
            selectedTextLabel = todayChoiceCell.textLabel?.text
        default:
            selectedPredicate = FormulaStack().getDatePredicate(for: Date.yesterday)
            selectedTextLabel = yesterdayChoiceCell.textLabel?.text
        }
        cell.accessoryType = .checkmark
    }
    
}
