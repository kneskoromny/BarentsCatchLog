//
//  ByTrawlsVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 26.09.2021.
//

import UIKit

class ByTrawlsVC: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet weak var choozeDateBtn: UIButton!
    @IBOutlet weak var trawlsQuantitySC: UISegmentedControl!
    @IBOutlet weak var calculateBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Public Properties
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-YYYY"
        return formatter
    }()
    
    // MARK: - Private Properties
    private var choozenDate = Date()
    private var trawlsQuantity = 1
    private var fishes: [Fish] = []
    private var totalCatch: [TotalCatchByPeriod] = []
    
    // проценты для расчета кол-ва в трале, зависят от кол-ва тралов
    private var firstTrawlPercent: Double?
    private var secondTrawlPercent: Double?
    private var thirdTrawlPercent: Double?
    private var fourthTrawlPercent: Double?
    private var fifthTrawlPercent: Double?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIDs.toDateFromChoice.rawValue {
            if let dateVC = segue.destination as? DateVC {
                dateVC.choozenDate = choozenDate
                dateVC.delegate = self
            }
        }
    }
    
    // MARK: - IB Actions
    @IBAction func choozeDateBtnPressed() {
        performSegue(withIdentifier: SegueIDs.toDateFromChoice.rawValue, sender: nil)
    }
    @IBAction func trawlsQuantitySCValueChanged(_ sender: Any) {
        switch trawlsQuantitySC.selectedSegmentIndex {
        case 0: trawlsQuantity = 1
        case 1: trawlsQuantity = 2
        case 2: trawlsQuantity = 3
        case 3: trawlsQuantity = 4
        default: trawlsQuantity = 5
        }
    }
    @IBAction func calculateBtnPressed() {
        fishes = Requests.shared.getAllElements(for: choozenDate)
        print("FISHES COUNT: \(fishes.count)")
        fishes.forEach { fish in
            print("FISHNAME: \(fish.name)")
        }
        divideByName(from: fishes)
        print("TOTAL CATCH COUNT: \(totalCatch.count)")
        totalCatch.forEach { totalCatch in
            print("Name: \(totalCatch.name), onBoard: \(totalCatch.onBoard), ratio: \(totalCatch.ratio), raw: \(totalCatch.raw)")
        }
        tableView.reloadData()
    }
    
    // MARK: - Private Methods
    private func configureUI() {
        CustomView.createDesign(for: choozeDateBtn, with: .systemBlue, and: "Выбрать дату")
        CustomView.createDesign(for: calculateBtn, with: .systemGreen, and: "Разделить по тралам")
    }
    private func divideByName(from fishes: [Fish]) {
        if let fish = fishes.first {
            var name = fish.name
            var total: Double = 0
            var ratio = fish.ratio

            fishes.forEach { currentFish in
                if currentFish.name == name {
                    total += currentFish.perDay
                } else {
                    let totalCatchByPeriod = TotalCatchByPeriod(name: name, onBoard: total, ratio: ratio)
                    totalCatch.append(totalCatchByPeriod)
                    total = currentFish.perDay
                    name = currentFish.name
                    ratio = currentFish.ratio
                }
            }
            let totalCatchByPeriod = TotalCatchByPeriod(name: name, onBoard: total, ratio: ratio)
            totalCatch.append(totalCatchByPeriod)
        }
    }
    private func divideBy(trawls: Int, from totalCatch: [TotalCatchByPeriod]) {
        switch trawls {
        case 1:
            for element in totalCatch {
                print("fdfadf")
            }
        default:
            print("fdef")
            
        }
    }
}
// MARK: - TableViewDataSource
extension ByTrawlsVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        trawlsQuantity
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // трал 1, трал 2
        "трал 1"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        totalCatch.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIDs.byTrawlsCell.rawValue, for: indexPath)
        let element = totalCatch[indexPath.row]
        
        cell.textLabel?.text = element.name
        if let onBoard = element.onBoard, let ratio = element.ratio {
            let rawOnBoard = (onBoard * ratio).rounded()
            cell.detailTextLabel?.text = String(rawOnBoard)
        }
        return cell
    }
}
// MARK: - DateVC Delegate
extension ByTrawlsVC: DateVCDelegate {
    func dateDidChanged(to date: Date) {
        self.choozenDate = date
        let convertedDate = dateFormatter.string(from: choozenDate)
        self.choozeDateBtn.setTitle(convertedDate, for: .normal)
    }
}
