//
//  AddReportTVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 09.09.2021.
//

import UIKit

class AddReportTVC: UITableViewController {
    
    // MARK: - IB Outlets
    @IBOutlet weak var nameCell: UITableViewCell!
    
    @IBOutlet weak var fishNameCell: UITableViewCell!
    @IBOutlet weak var gradeCell: UITableViewCell!
    @IBOutlet weak var dateFromCell: UITableViewCell!
    @IBOutlet weak var dateToCell: UITableViewCell!
    
    // MARK: - Private properties
    private let toFishArrayIdentifier = "toFishNamesIdentifier"
    private let toGradeArrayIdentifier = "toGradeArrayIdentifier"
    private let toDatesIdentifier = "toDatesIdentifier"
    
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fishNameCell.textLabel?.text = "Рыба"
        fishNameCell.detailTextLabel?.text = "Все"
        gradeCell.textLabel?.text = "Навеска"
        gradeCell.detailTextLabel?.text = "Все"
        dateFromCell.textLabel?.text = "Начало"
        dateFromCell.detailTextLabel?.text = ""
        dateToCell.textLabel?.text = "Конец"
        dateToCell.detailTextLabel?.text = ""
        

    }
}
    // MARK: - UITableViewDelegate
extension AddReportTVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        switch cell {
        case fishNameCell:
            performSegue(withIdentifier: toFishArrayIdentifier, sender: nil)
        case gradeCell:
            performSegue(withIdentifier: toGradeArrayIdentifier, sender: nil)
        default:
            performSegue(withIdentifier: toDatesIdentifier, sender: nil)
        }
    }
}


