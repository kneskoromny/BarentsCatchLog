//
//  AddReportTVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 09.09.2021.
//

import UIKit
import CoreData

class AddReportTVC: UITableViewController {
    
    // MARK: - IB Outlets
    @IBOutlet weak var nameCell: UITableViewCell!
    @IBOutlet weak var reportIdTF: UITextField!
    
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
    lazy var coreDataStack = CoreDataStack(modelName: "BarentsCatchLog")
    
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
    // MARK: - IB Actions
    @IBAction func saveBtnPressed(_ sender: UIBarButtonItem) {
        // показывать алерт
        let report = Report(context: coreDataStack.managedContext)
        
        guard let id = reportIdTF.text else {
            showAlert(title: "Внимание!", message: "У отчета должно быть название.")
            return }
        if id == "" {
            showAlert(title: "Внимание!", message: "Название должно состоять из символов.")
            return
        }
        report.id = id
        if let fish = choozenFish {
            report.fish = fish
        }
        if let grade = choozenGrade {
            report.grade = grade
        }
        report.dateFrom = choozenDateFrom
        report.dateTo = choozenDateTo
        
        print(report)
        showAlertBeforeSaveReport(id: id, fish: choozenFish ?? "вся рыба", grade: choozenGrade ?? "любая навеска", dateFrom: choozenDateFrom, dateTo: choozenDateTo)
    }
    @IBAction func cancelBtnPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
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
// MARK: - AlertController {
extension AddReportTVC {
    func showAlertBeforeSaveReport(id: String,
                                   fish: String,
                                   grade: String,
                                   dateFrom: Date,
                                   dateTo: Date) {
        let convertedDateFrom = dateFormatter.string(from: dateFrom)
        let convertedDateTo = dateFormatter.string(from: dateTo)
        
        let alert = UIAlertController(title: "Подтвердите создание отчета.",
                                      message: """
                                        Название: \(id),
                                        Рыба: \(fish),
                                        Навеска: \(grade),
                                        с \(convertedDateFrom) по \(convertedDateTo).
                                        """,
                                      preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "Верно",
                                       style: .default) { action in
            self.coreDataStack.saveContext()
            
            self.reportIdTF.text = nil
            self.choozenFish = nil
            self.choozenGrade = nil
            self.choozenDateFrom = Date()
            self.choozenDateTo = Date()
            
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alert.addAction(doneAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
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



