//
//  OnBoardVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 27.08.2021.
//

import UIKit
import CoreData

class DailyReportVC: UIViewController {
    
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
    var caughtFishes: [Fish] = []
    
    //MARK: - Private Properties
    private var fishNames = [FishTypes.cod.rawValue,
                             FishTypes.haddock.rawValue,
                             FishTypes.catfish.rawValue,
                             FishTypes.redfish.rawValue]

    //MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var index = 0
        fishTypes.forEach { fishType in
            fishType.text = fishNames[index]
            index += 1
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
            caughtFishes = try coreDataStack.managedContext.fetch(catchRequest)
            
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }

        for fish in caughtFishes {
            fishTypes.forEach { fishTypeLabel in
                if fishTypeLabel.text == fish.name {
                    
                    switch fishTypeLabel.text {
                    case FishTypes.cod.rawValue:
                        codFRZPerDay.text = String(fish.frozenPerDay)
                        codRAWPerDay.text = String(fish.rawPerDay)
                        codFRZOnBoard.text = String(fish.frozenBoard)
                        codRAWOnBoard.text = String(fish.rawBoard)
                    case FishTypes.haddock.rawValue:
                        hadFRZPerDay.text = String(fish.frozenPerDay)
                        hadRAWPerDay.text = String(fish.rawPerDay)
                        hadFRZOnBoard.text = String(fish.frozenBoard)
                        hadRAWOnBoard.text = String(fish.rawBoard)
                    case FishTypes.catfish.rawValue:
                        catFRZPerDay.text = String(fish.frozenPerDay)
                        catRAWPerDay.text = String(fish.rawPerDay)
                        catFRZOnBoard.text = String(fish.frozenBoard)
                        catRAWOnBoard.text = String(fish.rawBoard)
                    default:
                        redFRZPerDay.text = String(fish.frozenPerDay)
                        redRAWPerDay.text = String(fish.rawPerDay)
                        redFRZOnBoard.text = String(fish.frozenBoard)
                        redRAWOnBoard.text = String(fish.rawBoard)
                        
                    }
                }
            }
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(caughtFishes.count)
        
    }

}
