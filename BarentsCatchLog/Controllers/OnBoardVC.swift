//
//  OnBoardVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 27.08.2021.
//

import UIKit
import CoreData

class OnBoardVC: UIViewController {
    // названия рыб
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var thirdLabel: UILabel!
    @IBOutlet weak var fourthLabel: UILabel!
    
    // кол-во рыбы
    @IBOutlet weak var firstQuantity: UILabel!
    @IBOutlet weak var secondQuantity: UILabel!
    @IBOutlet weak var thirdQuantity: UILabel!
    @IBOutlet weak var fourthQuantity: UILabel!
    
    lazy var coreDataStack = CoreDataStack(modelName: "BarentsCatchLog")
    
    var catches: [Fish] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstLabel.text = FishTypes.cod.rawValue
        secondLabel.text = FishTypes.haddock.rawValue
        thirdLabel.text = FishTypes.catfish.rawValue
        fourthLabel.text = FishTypes.redfish.rawValue

        let catchRequest: NSFetchRequest<Fish> = Fish.fetchRequest()
        do {
            catches = try coreDataStack.managedContext.fetch(catchRequest)
            
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
        showQuantityOrHideLabels(for: firstLabel, and: firstQuantity)
        //print(firstLabel.text)
        showQuantityOrHideLabels(for: secondLabel, and: secondQuantity)
        //print(secondLabel.text)
        showQuantityOrHideLabels(for: thirdLabel, and: thirdQuantity)
        showQuantityOrHideLabels(for: fourthLabel, and: fourthQuantity)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print(catches.count)
    }
    
    private func showQuantityOrHideLabels(for mainLabel: UILabel, and secondaryLabel: UILabel) {
        for fish in catches {
            print(fish.name)
            if mainLabel.text == fish.name {
                secondaryLabel.text = "\(fish.name!) - \(fish.frozenBoard) - \(fish.rawBoard)"
            }
        }
    }

}
