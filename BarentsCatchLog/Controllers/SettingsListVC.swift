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

    override func viewDidLoad() {
        super.viewDidLoad()
        grades = StorageManager.shared.fetchGrades()
        print(grades.count)
    }

    // MARK: - Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return grades.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIDs.settingsListCell.rawValue, for: indexPath)

        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "пусто"
        default:
            let grade = grades[indexPath.row]
            cell.textLabel?.text = grade
            cell.detailTextLabel?.isHidden = true
        }

        return cell
    }
}
