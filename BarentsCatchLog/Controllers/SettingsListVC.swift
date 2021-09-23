//
//  SettingsListVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 22.09.2021.
//

import UIKit

class SettingsListVC: UITableViewController {
    // MARK: - Private Properties
    var sections = [SettingsListVCStrings.fishRatio.rawValue,
                    SettingsListVCStrings.grade.rawValue]
    var grades: [String] = []
    var inputFishes: [InputFish] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        grades = StorageManager.shared.fetchGrades()
        print("GradesCount: \(grades.count)")
        inputFishes = StorageManager.shared.fetchInputFishes()
        print("InputFishesCount: \(inputFishes.count)")
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
            return inputFishes.count
        default:
            return grades.count
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIDs.settingsListCell.rawValue, for: indexPath)

        switch indexPath.section {
        case 0:
            let inputFish = inputFishes[indexPath.row]
            cell.textLabel?.text = inputFish.fish
            let stringRatio = String(inputFish.ratio)
            cell.detailTextLabel?.text = stringRatio
        default:
            let grade = grades[indexPath.row]
            cell.textLabel?.text = grade
            cell.detailTextLabel?.isHidden = true
        }
        return cell
    }
    // MARK: - TableViewDelegate
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            switch indexPath.section {
            case 0:
                inputFishes.remove(at: indexPath.row)
                StorageManager.shared.deleteInputFish(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
            default:
                grades.remove(at: indexPath.row)
                StorageManager.shared.deleteGrade(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
            }
        }
    }
}
