//
//  ReportDescriptionTVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 07.09.2021.
//

import UIKit

class ReportDescriptionTVC: UITableViewController {
    
    //MARK: - IB Outlets
    
    
    //MARK: - Public Properties
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM"
        return formatter
    }()
    var caughtFishes: [Fish]!
    var convertedCaughtFishes: [Fish]!
    var flag: Bool!
    var rawFish: Double?
    
    //MARK: - Private Properties
    private var sections = ["Готовая продукция"]

    //MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        convertedCaughtFishes = caughtFishes.sorted(by: { ($0.date)?.compare($1.date!) == .orderedDescending})
        if flag {
            sections.append("Вылов")
            getRawFish(from: caughtFishes)
        }
        
    }
    
    //MARK: - Private Methods
    // получаем вылов на борту из готовой на борту из переданного массива
    private func getRawFish(from fishes: [Fish]) {
        if let fish = caughtFishes.first {
            rawFish = (fishes.reduce(0) { sum, fish in
                sum + fish.perDay
            } * fish.ratio).rounded()
        }
    }
}
// MARK: - UITableViewDataSource, Delegate
extension ReportDescriptionTVC {
    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50)
        let headerView = UIView(frame: frame)
        
        // название в секции
        let nameLabel = UILabel()
        nameLabel.frame = CGRect(x: 0,
                                 y: 0,
                                 width: headerView.frame.width,
                                 height: headerView.frame.height - 5)
        nameLabel.text = sections[section]
        nameLabel.font = .systemFont(ofSize: 25)
        nameLabel.textAlignment = .center
        nameLabel.backgroundColor = UIColor(red: 72/255, green: 159/255, blue: 248/255, alpha: 1)
        nameLabel.textColor = .white
        
        headerView.addSubview(nameLabel)
        return headerView
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
           return convertedCaughtFishes.count
        default:
            return 1
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportDescriptionCell", for: indexPath) as! ReportChoiceCell
        switch indexPath.section {
        case 0:
            let fish = convertedCaughtFishes[indexPath.row]
            let convertedDate = dateFormatter.string(from: fish.date!)
            cell.dateLabel.text = convertedDate
            cell.nameLabel.text = fish.name
            cell.gradeLabel.text = fish.grade
            cell.perDayQuantityLabel.text = String(format: "%.0f", fish.perDay) + " кг"
            cell.perDayTypeLabel.text = "готовой"
        default:
            let fish = caughtFishes.first
            cell.dateLabel.isHidden = true
            cell.nameLabel.text = fish?.name
            if let fishRatio = fish?.ratio {
                cell.gradeLabel.text = "Коэффициент: \(fishRatio)"
            }
            cell.perDayQuantityLabel.text = String(format: "%.0f", rawFish!) + " кг"
            cell.perDayTypeLabel.text = "вылова"
        }

        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
}
