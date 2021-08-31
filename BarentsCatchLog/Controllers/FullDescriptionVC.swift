//
//  FullDescriptionVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 30.08.2021.
//

import UIKit

class FullDescriptionVC: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ratioLabel: UILabel!
    @IBOutlet weak var frzPerDayLabel: UILabel!
    @IBOutlet weak var rawPerDayLabel: UILabel!
    @IBOutlet weak var frzOnBoardLabel: UILabel!
    @IBOutlet weak var rawOnBoardLabel: UILabel!
    
    var fish: Fish!
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        //formatter.timeStyle = .medium
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = fish.name
        //dateLabel.text = "Сводка за: \(String(describing: fish.date!))"
        dateLabel.text = "Сводка за: \(Date())"
        ratioLabel.text = "Коэффициент - \(fish.ratio)"
        frzPerDayLabel.text = "Готовой за сутки - \(fish.frozenPerDay)"
        rawPerDayLabel.text = "Вылов за сутки - \(fish.rawPerDay)"
        frzOnBoardLabel.text = "Готовой на борту - \(fish.frozenBoard)"
        rawOnBoardLabel.text = "Вылов на борту - \(fish.rawBoard)"
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
