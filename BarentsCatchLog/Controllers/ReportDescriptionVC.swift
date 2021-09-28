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
    var ratio: Double?
    var raw: Double {
        guard let onBoard = onBoard, let ratio = ratio else {
            return 0
        }
        return (onBoard * ratio).rounded()
    }
    func divideByTrawls(count: Int) -> [Double] {
        var inTrawlFishes: [Double] = []
        switch count {
        case 1:
            inTrawlFishes.append(raw)
        case 2:
            let trawl1 = (raw * 0.55).rounded()
            inTrawlFishes.append(trawl1)
            let trawl2 = raw - trawl1
            inTrawlFishes.append(trawl2)
        default:
            print("fhdfkjdnf")
        
        }
        return inTrawlFishes
    }
    
    
}

class ReportDescriptionVC: UITableViewController {
    //MARK: - Public Properties
    var caughtFishes: [Fish]!
    var isOneTypeFish: Bool!
    
    //MARK: - Private Properties
    private var sections: [String] = []
    private var totalCatch: [TotalCatchByPeriod] = []
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
            sections.append(ReportDescriptionVCStrings.frzByGrades.rawValue)
            convertedCaughtFishes = caughtFishes.sorted(by: { ($0.date)?.compare($1.date!) == .orderedDescending})
            sections.append(ReportDescriptionVCStrings.frzOnBoard.rawValue)
            getTotalFrzFish(from: caughtFishes)
            sections.append(ReportDescriptionVCStrings.raw.rawValue)
            getRawFish(from: caughtFishes)
        default:
            sections.append(ReportDescriptionVCStrings.frzSpecies.rawValue)
            convertedCaughtFishes = caughtFishes.sorted(by: { $0.name! > $1.name! })
            divideByName(from: convertedCaughtFishes)
            sections.append(ReportDescriptionVCStrings.log.rawValue)
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
extension ReportDescriptionVC {
    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return CustomView.createHeaderForReportDescriptionVC(with: tableView.frame.width, and: 40, and: sections[section])
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
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIDs.reportDescriptionCell.rawValue, for: indexPath) as! ReportDescriptionCell
        
        cell.configureColors()
        
        switch isOneTypeFish {
        case true:
            switch indexPath.section {
            case 0:
                let fish = convertedCaughtFishes[indexPath.row]
                cell.configureCellAsLog(with: fish)
            case 1:
                let fish = caughtFishes.first
                cell.configureCellAsTotal(with: fish, weight: frzFish, isFrz: true)
            default:
                let fish = caughtFishes.first
                cell.configureCellAsTotal(with: fish, weight: rawFish, isFrz: false)
            }
        default:
            switch indexPath.section {
            case 0:
                let fish = totalCatch[indexPath.row]
                cell.configureCellAsTotalBySpecies(with: fish)
                
            default:
                let fish = convertedCaughtFishes[indexPath.row]
                cell.configureCellAsLog(with: fish)
            }
        }
        return cell
    }
    
}
