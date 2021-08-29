//
//  OnBoardVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 27.08.2021.
//

import UIKit
import CoreData

class OnBoardVC: UIViewController {
    
    //MARK: - IB Outlets
    // ПОСТОЯННЫЕ ЛЕЙБЛЫ
    @IBOutlet var fishTypes: [UILabel]!
    
    
    @IBOutlet var frozenPerDayLabels: [UILabel]!
    @IBOutlet var rawPerDayLabels: [UILabel]!
    @IBOutlet var frozenOnBoardLabels: [UILabel]!
    @IBOutlet var rawOnBoardLabels: [UILabel]!
    
    // ИЗМЕНЯЕМЫЕ ЛЕЙБЛЫ
    @IBOutlet weak var codFRZPerDay: UILabel!
    @IBOutlet weak var codRAWPerDay: UILabel!
    @IBOutlet weak var codFRZOnBoard: UILabel!
    @IBOutlet weak var codRAWOnBoard: UILabel!
    
    @IBOutlet weak var hadFRZPerDay: UILabel!
    @IBOutlet weak var hadRAWPerDay: UILabel!
    @IBOutlet weak var hadFRZOnBoard: UILabel!
    @IBOutlet weak var hadRAWOnBoard: UILabel!
    
    @IBOutlet weak var catFRZPerDay: UILabel!
    @IBOutlet weak var catRAWPerDay: UILabel!
    @IBOutlet weak var catFRZOnBoard: UILabel!
    @IBOutlet weak var catRAWOnBoard: UILabel!
    
    @IBOutlet weak var redFRZPerDay: UILabel!
    @IBOutlet weak var redRAWPerDay: UILabel!
    @IBOutlet weak var redFRZOnBoard: UILabel!
    @IBOutlet weak var redRAWOnBoard: UILabel!
    
    //MARK: - Public Properties
    lazy var coreDataStack = CoreDataStack(modelName: "BarentsCatchLog")
    var catches: [Fish] = []
    
    //MARK: - Private Properties
    private var fishNames = [FishTypes.cod.rawValue,
                             FishTypes.haddock.rawValue,
                             FishTypes.catfish.rawValue,
                             FishTypes.redfish.rawValue]

    //MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for iteration in 0..<fishNames.count {
            fishTypes.forEach { fishType in
                fishType.text = fishNames[iteration]
            } 
        }

        frozenPerDayLabels.forEach { frozenPerDayLabel in
            frozenPerDayLabel.text = "Готовая за сутки"
        }
        rawPerDayLabels.forEach { rawPerDayLabel in
            rawPerDayLabel.text = "Вылов за сутки"
        }
        frozenOnBoardLabels.forEach { frozenOnBoardLabel in
            frozenOnBoardLabel.text = "Готовая на борту"
        }
        rawOnBoardLabels.forEach { rawOnBoardLabel in
            rawOnBoardLabel.text = "Вылов на борту"
        }

        let catchRequest: NSFetchRequest<Fish> = Fish.fetchRequest()
        do {
            catches = try coreDataStack.managedContext.fetch(catchRequest)
            
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
       
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(catches.count)
    }
    
    private func showQuantityOrHideLabels(for mainLabel: UILabel, and secondaryLabel: UILabel) {
        for fish in catches {
            if mainLabel.text == fish.name {
                secondaryLabel.text = "\(fish.name!) - \(fish.frozenBoard) - \(fish.rawBoard)"
            }
        }
    }

}
