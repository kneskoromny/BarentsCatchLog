//
//  GradeTVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 05.09.2021.
//

import UIKit

class GradeVC: UITableViewController {
    // MARK: - Public Properties
    var delegate: GradeTVCDelegate!

    // MARK: - Private Properties
    private var grades: [String] = []
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        grades = Arrays.shared.grades
    }

    // MARK: - TableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        grades.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIDs.gradeCell.rawValue, for: indexPath)
        let grade = grades[indexPath.row]
        cell.textLabel?.text = grade
        cell.textLabel?.textColor = .systemGray

        return cell
    }
    // MARK: - TableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let grade = grades[indexPath.row]
        delegate.valueDidChanged(to: grade)
        dismiss(animated: true)
    }
}
