//
//  ReportDescriptionTVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 07.09.2021.
//

import UIKit

struct TotalCatchByPeriod {
    var name: String?
    var onBoard: Double?
}

class ReportDescriptionTVC: UITableViewController {
    //MARK: - Public Properties
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM"
        return formatter
    }()
    var caughtFishes: [Fish]!
    var isOneTypeFish: Bool!
    
    //MARK: - Private Properties
    private var sections: [String] = []
    private var totalCatch = [TotalCatchByPeriod]()
    private var convertedCaughtFishes: [Fish] = []
    private var rawFish: Double?
    private var frzFish: Double?

    //MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareTableViewDependingInputData()
    }
    
    //MARK: - Private Methods
    private func prepareTableViewDependingInputData() {
        switch isOneTypeFish {
        case true:
            sections.append("Готовая по навескам")
            convertedCaughtFishes = caughtFishes.sorted(by: { ($0.date)?.compare($1.date!) == .orderedDescending})
            sections.append("Готовая всего")
            getTotalFrzFish(from: caughtFishes)
            sections.append("Вылов")
            getRawFish(from: caughtFishes)
        default:
            sections.append("Готовая по видам за период")
            convertedCaughtFishes = caughtFishes.sorted(by: { $0.name! > $1.name! })
            divideByName(from: convertedCaughtFishes)
            sections.append("Записи за период")
        }
    }
    private func getRawFish(from fishes: [Fish]) {
        if let fish = caughtFishes.first {
            rawFish = (fishes.reduce(0) { sum, fish in
                sum + fish.perDay
            } * fish.ratio).rounded()
        }
    }
    private func getTotalFrzFish(from fishes: [Fish]) {
        frzFish = fishes.reduce(0) {sum, fish in
            sum + fish.perDay
        }
    }
    private func divideByName(from fishes: [Fish]) {
        if let fish = fishes.first {
            var name = fish.name
            var total: Double = 0

            fishes.forEach { currentFish in
                if currentFish.name == name {
                    total += currentFish.perDay
                } else {
                    let totalCatchByPeriod = TotalCatchByPeriod(name: name, onBoard: total)
                    totalCatch.append(totalCatchByPeriod)
                    total = currentFish.perDay
                    name = currentFish.name
                }
            }
            let totalCatchByPeriod = TotalCatchByPeriod(name: name, onBoard: total)
            totalCatch.append(totalCatchByPeriod)
        }
    }
}
// MARK: - UITableViewDataSource, Delegate
extension ReportDescriptionTVC {
    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40)
        let headerView = UIView(frame: frame)
        
        let nameLabel = UILabel()
        nameLabel.frame = CGRect(x: 0,
                                 y: 0,
                                 width: headerView.frame.width,
                                 height: headerView.frame.height - 5)
        nameLabel.text = sections[section]
        nameLabel.font = .systemFont(ofSize: 20)
        //nameLabel.textAlignment = .center
        //nameLabel.backgroundColor = UIColor(red: 72/255, green: 159/255, blue: 248/255, alpha: 1)
        nameLabel.textColor = .systemBlue
        
        headerView.addSubview(nameLabel)
        return headerView
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows: Int
        switch isOneTypeFish {
        case true:
            switch section {
            case 0: rows = convertedCaughtFishes.count
            default: rows = 1
            }
        default:
            switch section {
            case 0: rows = totalCatch.count
            default: rows = convertedCaughtFishes.count
            }
        }
        return rows
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportDescriptionCell", for: indexPath) as! ReportChoiceCell
        cell.dateLabel.textColor = .systemBlue
        cell.gradeLabel.textColor = .systemGray
        cell.perDayQuantityLabel.textColor = .systemGreen
        cell.perDayTypeLabel.textColor = .systemGreen
        switch isOneTypeFish {
        case true:
            switch indexPath.section {
            case 0:
                let fish = convertedCaughtFishes[indexPath.row]
                let convertedDate = dateFormatter.string(from: fish.date!)
                cell.dateLabel.text = convertedDate
                cell.nameLabel.text = fish.name
                cell.gradeLabel.text = fish.grade
                cell.perDayQuantityLabel.text = String(format: "%.0f", fish.perDay) + " кг"
                cell.perDayTypeLabel.text = "готовой"
            case 1:
                let fish = caughtFishes.first
                cell.dateLabel.isHidden = true
                cell.nameLabel.text = fish?.name
                cell.gradeLabel.isHidden = true
                cell.perDayQuantityLabel.text = String(format: "%.0f", frzFish!) + " кг"
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
        default:
            switch indexPath.section {
            case 0:
                let fish = totalCatch[indexPath.row]
                cell.dateLabel.isHidden = true
                cell.nameLabel.text = fish.name
                cell.gradeLabel.isHidden = true
                cell.perDayQuantityLabel.text = String(format: "%.0f", fish.onBoard!) + " кг"
                cell.perDayTypeLabel.text = "готовой"
            default:
                let fish = convertedCaughtFishes[indexPath.row]
                let convertedDate = dateFormatter.string(from: fish.date!)
                cell.dateLabel.text = convertedDate
                cell.nameLabel.text = fish.name
                cell.gradeLabel.text = fish.grade
                cell.perDayQuantityLabel.text = String(format: "%.0f", fish.perDay) + " кг"
                cell.perDayTypeLabel.text = "готовой"
            }
        }
        return cell
    }
    
}
