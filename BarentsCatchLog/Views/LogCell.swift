//
//  LogCell.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 13.09.2021.
//

import UIKit

class LogCell: UITableViewCell {

    @IBOutlet weak var fishlabel: UILabel!
    @IBOutlet weak var frzBoardLabel: UILabel!
    @IBOutlet weak var gradeLabel: UILabel!
    
    func configure(with fish: Fish?) {
        
        fishlabel?.text = fish?.name
        if let perDay = fish?.perDay {
            let stringPerDay = String(format: "%.0f", perDay)
            frzBoardLabel.text = "\(stringPerDay) кг"
        }
        gradeLabel.text = fish?.grade
        
        gradeLabel.textColor = .systemGray
        frzBoardLabel.textColor = .systemGreen
    }
}
