//
//  AddReportTVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 09.09.2021.
//

import UIKit
import CoreData

class AddReportVC: UITableViewController {
    
    // MARK: - IB Outlets
    @IBOutlet weak var nameCell: UITableViewCell!
    @IBOutlet weak var reportIdTF: UITextField!
    
    @IBOutlet weak var fishNameCell: UITableViewCell!
    @IBOutlet weak var gradeCell: UITableViewCell!
    @IBOutlet weak var dateFromCell: UITableViewCell!
    @IBOutlet weak var dateToCell: UITableViewCell!
    
    @IBOutlet var cellCollection: [UITableViewCell]!
    
    // MARK: - Public properties
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-YYYY"
        return formatter
    }()
    lazy var coreDataStack = CoreDataStack(modelName: IDs.modelID.rawValue)
    var delegate: AddReportVCDelegate!
    
    // MARK: - Private properties
    private var choozenFish: String?
    private var choozenGrade: String?
    private var choozenDateFrom = Date()
    private var choozenDateTo =  Date()
    
    private var dateFromDidChanged = true
    private var dateToDidChanged = true
    
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLabels()
    }
  
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SegueIDs.toFishChoice.rawValue:
            if let navController = segue.destination as? FishTVCNC {
                if let fishTVC = navController.topViewController as? FishVC {
                    fishTVC.delegate = self
                }
            }
        case SegueIDs.toGradeChoice.rawValue:
            if let navController = segue.destination as? GradeTVCNC {
                if let gradeTVC = navController.topViewController as? GradeVC {
                    gradeTVC.delegate = self
                }
            }
        case SegueIDs.toDateFromChoice.rawValue:
            if let dateVC = segue.destination as? DateVC {
                dateVC.choozenDate = choozenDateFrom
                dateVC.delegate = self
            }
        default:
            if let dateVC = segue.destination as? DateVC {
                dateVC.choozenDate = choozenDateTo
                dateVC.delegate = self
            }
        }
    }
    // MARK: - IB Actions
    @IBAction func saveBtnPressed(_ sender: UIBarButtonItem) {
        guard let id = reportIdTF.text else {
            showAlert(title: "Внимание!", message: "У отчета должно быть название.")
            return }
        if id == "" {
            showAlert(title: "Внимание!", message: "Название должно состоять из символов.")
            return
        }
        let report = createReport(id: id,
                                  fish: choozenFish,
                                  grade: choozenGrade,
                                  dateFrom: choozenDateFrom,
                                  dateTo: choozenDateTo)
        delegate.newReportDidCreated(report: report)
        dismiss(animated: true)
    }
    @IBAction func cancelBtnPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    // MARK: - Private methods
    private func configureLabels() {
        fishNameCell.textLabel?.text = "Рыба"
        fishNameCell.detailTextLabel?.text = "Все"
        gradeCell.textLabel?.text = "Навеска"
        gradeCell.detailTextLabel?.text = "Все"
        dateFromCell.textLabel?.text = "Начало"
        dateFromCell.detailTextLabel?.text = dateFormatter.string(from: choozenDateFrom)
        dateToCell.textLabel?.text = "Конец"
        dateToCell.detailTextLabel?.text = dateFormatter.string(from: choozenDateTo)
        
        cellCollection.forEach { cell in
            cell.detailTextLabel?.textColor = .systemGray
        }
    }
    private func createReport(id: String, fish: String?, grade: String?, dateFrom: Date, dateTo: Date) -> Report {
        let report = Report(context: coreDataStack.managedContext)
        
        report.id = id
        if let fish = fish {
            report.fish = fish
        }
        if let grade = grade {
            report.grade = grade
        }
        report.dateFrom = choozenDateFrom
        report.dateTo = choozenDateTo

        coreDataStack.saveContext()
        return report
    }
}
    // MARK: - UITableViewDelegate
extension AddReportVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        switch cell {
        case fishNameCell:
            performSegue(withIdentifier: SegueIDs.toFishChoice.rawValue, sender: nil)
        case gradeCell:
            performSegue(withIdentifier: SegueIDs.toGradeChoice.rawValue, sender: nil)
        case dateFromCell:
            performSegue(withIdentifier: SegueIDs.toDateFromChoice.rawValue, sender: nil)
            dateFromDidChanged.toggle()
        default:
            performSegue(withIdentifier: SegueIDs.toDateToChoice.rawValue, sender: nil)
            dateToDidChanged.toggle()
        }
    }
}
// MARK: - AlertController {
extension AddReportVC {
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
// MARK: - GradeTVC Delegate
extension AddReportVC: GradeVCDelegate {
    func valueDidChanged(to grade: String) {
        gradeCell.detailTextLabel?.text = grade
        self.choozenGrade = grade
        self.tableView.reloadData()
    }
}
// MARK: - DateVC Delegate
// ПОДУМАТЬ КАК СДЕЛАТЬ ЧЕРЕЗ <T>
extension AddReportVC: DateVCDelegate {
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
extension AddReportVC: FishVCDelegate {
    func fishDidChanged(to input: InputFish) {
        fishNameCell.detailTextLabel?.text = input.fish
        self.choozenFish = input.fish
        self.tableView.reloadData()
    }
}



