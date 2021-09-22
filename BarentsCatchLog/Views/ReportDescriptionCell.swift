//
//  ReportDescriptionCell.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 08.09.2021.
//

import UIKit

class ReportDescriptionCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var perDayQuantityLabel: UILabel!
    @IBOutlet weak var perDayTypeLabel: UILabel!
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        return formatter
    }()
    
    func configureColors() {
        dateLabel.textColor = .systemBlue
        gradeLabel.textColor = .systemGray
        perDayQuantityLabel.textColor = .systemGreen
        perDayTypeLabel.textColor = .systemGreen
    }
    func configureCellAsLog(with fish: Fish) {
        let convertedDate = dateFormatter.string(from: fish.date!)
        dateLabel.text = convertedDate
        nameLabel.text = fish.name
        gradeLabel.text = fish.grade
        let stringPerDay = String(format: "%.0f", fish.perDay)
        perDayQuantityLabel.text = "\(stringPerDay) кг"
        perDayTypeLabel.text = "готовой"
    }
    func configureCellAsTotal(with fish: Fish?, weight: Double?, isFrz: Bool) {
        dateLabel.isHidden = true
        nameLabel.text = fish?.name
        if let weight = weight {
            let stringWeight = String(format: "%.0f", weight)
            perDayQuantityLabel.text = "\(stringWeight) кг"
        }
        switch isFrz {
        case true:
            gradeLabel.isHidden = true
            perDayTypeLabel.text = "готовой"
        default:
            if let fishRatio = fish?.ratio {
                gradeLabel.text = "Коэффициент: \(fishRatio)"
            }
            perDayTypeLabel.text = "вылова"
        }
    }
    func configureCellAsTotalBySpecies(with fish: TotalCatchByPeriod) {
        dateLabel.isHidden = true
        nameLabel.text = fish.name
        gradeLabel.isHidden = true
        if let fishOnBoard = fish.onBoard {
            let stringOnBoard = String(format: "%.0f", fishOnBoard)
            perDayQuantityLabel.text = "\(stringOnBoard ) кг"
        }
        perDayTypeLabel.text = "готовой"
    }


}
