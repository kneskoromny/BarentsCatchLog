//
//  SettingsListVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 22.09.2021.
//

import UIKit

class SettingsListVC: UITableViewController {
    // MARK: - Private Properties
    var sections = [SettingsListVCStrings.userElements.rawValue,
                    SettingsListVCStrings.grade.rawValue]
    var userElements: [InputFish] = []
    var grades: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        grades = StorageManager.shared.fetchGrades()
        userElements = StorageManager.shared.fetchInputFishes()
    }
    
    // MARK: - Private Methods
    private func configure(for cell: UITableViewCell, with fish: InputFish) {
        cell.textLabel?.text = fish.fish
        let stringRatio = String(fish.ratio)
        cell.detailTextLabel?.text = stringRatio
    }
    private func configure(for cell: UITableViewCell, with grade: String) {
        cell.textLabel?.text = grade
        cell.detailTextLabel?.isHidden = true
    }
    private func deleteInputFish(at index: Int) {
        userElements.remove(at: index)
        StorageManager.shared.deleteInputFish(at: index)
    }
    private func deleteGrade(at index: Int) {
        grades.remove(at: index)
        StorageManager.shared.deleteGrade(at: index)
    }

    // MARK: - TableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section]
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return userElements.count
        default:
            return grades.count
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIDs.settingsListCell.rawValue, for: indexPath)
        
        switch indexPath.section {
        case 0:
            let inputFish = userElements[indexPath.row]
            configure(for: cell, with: inputFish)
        default:
            let grade = grades[indexPath.row]
            configure(for: cell, with: grade)
        }
        return cell
    }
    // MARK: - TableViewDelegate
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            switch indexPath.section {
            case 0:
                deleteInputFish(at: indexPath.row)
            default:
                deleteGrade(at: indexPath.row)
            }
            tableView.deleteRows(at: [indexPath], with: .left)
        }
    }
}
// MARK: - AlertController
extension SettingsListVC {
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
