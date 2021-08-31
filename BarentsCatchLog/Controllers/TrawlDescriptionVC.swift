//
//  TrawlDescriptionVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 31.08.2021.
//

import UIKit

class TrawlDescriptionVC: UIViewController {

    @IBOutlet weak var trawlDescriptionLabel: UILabel!
    
    var trawl: Trawl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        trawlDescriptionLabel.text = """
            Трал № \(String(describing: trawl.id!))
            Время постановки: \(String(describing: trawl.timeShoot!)) \(String(describing: trawl.dateShoot!))
            Координаты постановки:\n \(String(describing: trawl.latitudeShoot!)) СШ \(String(describing: trawl.longitudeShoot!)) ВД
            Время подъема: \(String(describing: trawl.timeHoist!)) \(String(describing: trawl.dateHoist!))
            Координаты подъема:\n \(String(describing: trawl.latitudeHoist!)) СШ \(String(describing: trawl.longitudeHoist!)) ВД
            
            По ассортименту:
            Треска: \(trawl.codRaw)
            Пикша: \(trawl.hadRaw)
            Зубатка: \(trawl.catRaw)
            Окунь: \(trawl.redRaw)
            """
    }

}
