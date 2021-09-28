//
//  ByTrawlsVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 26.09.2021.
//

import UIKit

struct DividedFish {
    var name: String?
    var fishes: [Double]?
}

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
    private var trawls = ["Трал 1"]
    private var fishes: [Fish] = []
    private var totalCatch: [TotalCatchByPeriod] = []
    private var dividedFishes: [DividedFish] = []
    
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
        // сделать получше
        switch trawlsQuantitySC.selectedSegmentIndex {
        case 0:
            trawls = ["Трал 1"]
        case 1:
            addSectionTitle(sectionCount: 2)
        case 2:
            addSectionTitle(sectionCount: 3)
        case 3:
            addSectionTitle(sectionCount: 4)
        default:
            addSectionTitle(sectionCount: 5)
        }
    }
    @IBAction func calculateBtnPressed() {
        fishes = Requests.shared.getAllElements(for: choozenDate)
//        print("FISHES COUNT: \(fishes.count)")
        fishes.forEach { fish in
//            print("FISHNAME: \(fish.name)")
        }
        divideByName(from: fishes)
        //dividedFishes = divideBy(trawlsCount: trawls.count, from: totalCatch)
        createDividedFish(trawlsCount: trawls.count, from: totalCatch)
        dividedFishes.forEach { divFish in
            print("Name: \(divFish.name!), Fishes: \(divFish.fishes!)")
        }
        
        
//        print("TOTAL CATCH COUNT: \(totalCatch.count)")
        totalCatch.forEach { totalCatch in
//            print("Name: \(totalCatch.name), onBoard: \(totalCatch.onBoard), ratio: \(totalCatch.ratio), raw: \(totalCatch.raw)")
        }
        tableView.reloadData()
    }
    
    // MARK: - Private Methods
    private func addSectionTitle(sectionCount: Int) {
        trawls = ["Трал 1"]
        var number = 2
        while number <= sectionCount {
            trawls.append("Трал \(number)")
            number += 1
        }
        print(trawls)
    }
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
//    private func divideBy(trawlsCount: Int, from totalCatch: [TotalCatchByPeriod]) -> [DividedFish] {
//        var dividedFishes: [DividedFish] = []
//        switch trawls.count {
//        case 1:
//            for element in totalCatch {
//                let dividedFish = DividedFish(
//                    name: element.name,
//                    fishes: element.divideByTrawls(count: 1))
//                print(dividedFish)
//                dividedFishes.append(dividedFish)
//            }
//        case 2:
//            for element in totalCatch {
//                let dividedFish = DividedFish(
//                    name: element.name,
//                    fishes: element.divideByTrawls(count: 2))
//                print(dividedFish)
//                dividedFishes.append(dividedFish)
//            }
//        default:
//            print("fdef")
//
//        }
//        return dividedFishes
//    }
    private func createDividedFish(trawlsCount: Int, from totalCatch: [TotalCatchByPeriod]) {
        for element in totalCatch {
            let dividedFish = DividedFish(
                name: element.name,
                fishes: element.divideByTrawls(count: trawlsCount))
            print(dividedFish)
            dividedFishes.append(dividedFish)
    }
    }
}
// MARK: - TableViewDataSource
extension ByTrawlsVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        trawls.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        trawls[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dividedFishes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIDs.byTrawlsCell.rawValue, for: indexPath)
        let element = dividedFishes[indexPath.row]
        
        cell.textLabel?.text = element.name
        
        
        //let index = sections.firstIndex(of: "Трал 1")
        
        switch trawls[indexPath.section] {
        case "Трал 1":
            guard let fishes = element.fishes else { return cell}
            let strInTrawl = String(format: "%.0f", fishes[0])
            cell.detailTextLabel?.text = strInTrawl
        case "Трал 2":
            let strInTrawl = String(format: "%.0f", element.fishes![1])
            cell.detailTextLabel?.text = strInTrawl
        case "Трал 3":
            let strInTrawl = String(format: "%.0f", element.fishes![2])
            cell.detailTextLabel?.text = strInTrawl
        case "Трал 4":
            let strInTrawl = String(format: "%.0f", element.fishes![3])
            cell.detailTextLabel?.text = strInTrawl
        default:
            let strInTrawl = String(format: "%.0f", element.fishes![4])
            cell.detailTextLabel?.text = strInTrawl
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
