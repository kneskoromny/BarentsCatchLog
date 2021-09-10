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
    
    // MARK: - Public properties
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-YYYY"
        return formatter
    }()
    // MARK: - Private properties
    private let toFishArrayIdentifier = "toFishNamesIdentifier"
    private let toGradeArrayIdentifier = "toGradeArrayIdentifier"
    private let toDateFromIdentifier = "toDateFromIdentifier"
    private let toDateToIdentifier = "toDateToIdentifier"
    
    private var choozenFish: String?
    private var choozenGrade: String?
    private var choozenDateFrom = Date()
    private var choozenDateTo =  Date()
    
    private var dateFromDidChanged = true
    private var dateToDidChanged = true
    
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        fishNameCell.textLabel?.text = "Рыба"
        fishNameCell.detailTextLabel?.text = "Все"
        gradeCell.textLabel?.text = "Навеска"
        gradeCell.detailTextLabel?.text = "Все"
        dateFromCell.textLabel?.text = "Начало"
        dateFromCell.detailTextLabel?.text = dateFormatter.string(from: choozenDateFrom)
        dateToCell.textLabel?.text = "Конец"
        dateToCell.detailTextLabel?.text = dateFormatter.string(from: choozenDateTo)
        
    }
  
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == toFishArrayIdentifier {
            if let navController = segue.destination as? FishTVCNC {
                if let fishTVC = navController.topViewController as? FishTVC {
                    fishTVC.delegate = self
                }
            }
        } else if segue.identifier == toGradeArrayIdentifier {
            if let navController = segue.destination as? GradeTVCNC {
                if let gradeTVC = navController.topViewController as? GradeTVC {
                    gradeTVC.delegate = self
                }
            }
        } else if segue.identifier == toDateFromIdentifier {
            if let dateVC = segue.destination as? DateVC {
                dateVC.choozenDate = choozenDateFrom
                dateVC.delegate = self
            }
        } else {
            if let dateVC = segue.destination as? DateVC {
                dateVC.choozenDate = choozenDateTo
                dateVC.delegate = self
            }
        }
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
        case dateFromCell:
            performSegue(withIdentifier: toDateFromIdentifier, sender: nil)
            dateFromDidChanged.toggle()
        default:
            performSegue(withIdentifier: toDateToIdentifier, sender: nil)
            dateToDidChanged.toggle()
        }
    }
}
// MARK: - GradeTVC Delegate
extension AddReportTVC: GradeTVCDelegate {
    func valueDidChanged(to grade: String) {
        gradeCell.detailTextLabel?.text = grade
        self.choozenGrade = grade
        self.tableView.reloadData()
    }
}
// MARK: - DateVC Delegate
// ПОДУМАТЬ КАК СДЕЛАТЬ ЧЕРЕЗ <T>
extension AddReportTVC: DateVCDelegate {
    func dateDidChanged(to date: Date) {
        let convertedDate = dateFormatter.string(from: date)
        
        if !dateFromDidChanged {
            choozenDateFrom = date
            dateFromCell.detailTextLabel?.text = convertedDate
            dateFromDidChanged.toggle()
        } else if !dateToDidChanged {
            choozenDateTo = date
            dateToCell.detailTextLabel?.text = convertedDate
            dateToDidChanged.toggle()
        }
        self.tableView.reloadData()
    }
}
// MARK: - FishTVC Delegate
extension AddReportTVC: FishTVCDelegate {
    func fishDidChanged(to fish: String) {
        fishNameCell.detailTextLabel?.text = fish
        self.choozenFish = fish
        self.tableView.reloadData()
    }
}


