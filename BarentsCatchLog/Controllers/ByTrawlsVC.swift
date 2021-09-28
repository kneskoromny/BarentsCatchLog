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
    private let trawlsQuantity = 1
    private var trawls: [String] = []
    private var fishes: [Fish] = []
    private var totalCatch: [TotalCatchByPeriod] = []
    private var dividedFishes: [DividedFish] = []
    private var isFirstCalculate = true
    
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
        let sectionCount = trawlsQuantitySC.selectedSegmentIndex + 1
        addSectionTitle(sectionCount: sectionCount)
    }
    @IBAction func calculateBtnPressed() {
        if isFirstCalculate {
            fishes = Requests.shared.getAllElements(for: choozenDate)
            divideByName(from: fishes)
            createDividedFish(trawlsCount: trawls.count, from: totalCatch)
            tableView.reloadData()
            toggleBoolean()
            animateButton(with: .systemRed, and: "Сбросить")
        } else {
            cleanArrays()
            tableView.reloadData()
            toggleBoolean()
            animateButton(with: .systemGreen, and: "Разделить по тралам")
        }
    }
    
    // MARK: - Private Methods
    private func toggleBoolean() {
        //tableView.isHidden.toggle()
        isFirstCalculate.toggle()
    }
    private func cleanArrays() {
        fishes.removeAll()
        totalCatch.removeAll()
        dividedFishes.removeAll()
    }
    private func animateButton(with color: UIColor, and text: String) {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut]) { [weak self] in
            self?.calculateBtn.backgroundColor = color
            self?.calculateBtn.setTitle(text, for: .normal)
        }
    }
    private func addSectionTitle(sectionCount: Int) {
        trawls = []
        var number = 1
        while number <= sectionCount {
            trawls.append("Трал \(number)")
            number += 1
        }
    }
    private func configureUI() {
        CustomView.createDesign(for: choozeDateBtn, with: .systemBlue, and: "Выбрать дату")
        CustomView.createDesign(for: calculateBtn, with: .systemGreen, and: "Разделить по тралам")
        addSectionTitle(sectionCount: trawlsQuantity)
        //tableView.isHidden = true
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
    private func createDividedFish(trawlsCount: Int, from totalCatch: [TotalCatchByPeriod]) {
        for element in totalCatch {
            let dividedFish = DividedFish(
                name: element.name,
                fishes: element.divideByTrawls(count: trawlsCount))
            print(dividedFish)
            dividedFishes.append(dividedFish)
        }
    }
    private func getWeightDependingTrawl(number: Int, from array: [Double]?) -> String  {
        guard let catches = array else { return "" }
        return String(format: "%.0f", catches[number])
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
        
        switch trawls[indexPath.section] {
        case "Трал 1":
            cell.detailTextLabel?.text = getWeightDependingTrawl(number: 0,
                                                                 from: element.fishes)
        case "Трал 2":
            cell.detailTextLabel?.text = getWeightDependingTrawl(number: 1,
                                                                 from: element.fishes)
        case "Трал 3":
            cell.detailTextLabel?.text = getWeightDependingTrawl(number: 2,
                                                                 from: element.fishes)
        case "Трал 4":
            cell.detailTextLabel?.text = getWeightDependingTrawl(number: 3,
                                                                 from: element.fishes)
        default:
            cell.detailTextLabel?.text = getWeightDependingTrawl(number: 4,
                                                                 from: element.fishes)
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
