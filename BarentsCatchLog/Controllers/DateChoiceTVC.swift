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
        didSelectPredicate predicate: NSCompoundPredicate?
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
    
    // MARK: - Private Properties
    var dateFrom: Date?
    var dateTo: Date?
    
    // MARK: - Date Predicates
   
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - IB Actions
    @IBAction func getReportBtnPressed(_ sender: UIBarButtonItem) {
        delegate?.getNewPredicate(filter: self, didSelectPredicate: selectedPredicate)
        dismiss(animated: true)    }
    
}
// MARK: - UITableViewDelegate
extension DateChoiceTVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell =  tableView.cellForRow(at: indexPath) else { return }
        
        switch cell {
        // определяем сегодня
        case todayChoiceCell:
            dateFrom = Calendar.current.startOfDay(for: Date())
            print(dateFrom!)
            dateTo = Calendar.current.date(byAdding: .day, value: 1, to: dateFrom!)
            let fromPredicate = NSPredicate(format: "date >= %@", dateFrom! as NSDate)
            let toPredicate = NSPredicate(format: "date < %@",  dateTo! as NSDate)
            selectedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate, toPredicate])
            
        default:
            // определяем вчера
            dateFrom = Calendar.current.startOfDay(for: Date.yesterday)
            print(dateFrom!)
            dateTo = Calendar.current.date(byAdding: .day, value: 1, to: dateFrom!)
            let fromPredicate = NSPredicate(format: "date >= %@", dateFrom! as NSDate)
            let toPredicate = NSPredicate(format: "date < %@",  dateTo! as NSDate)
            selectedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate, toPredicate])
        }
        cell.accessoryType = .checkmark
    }
    
}
