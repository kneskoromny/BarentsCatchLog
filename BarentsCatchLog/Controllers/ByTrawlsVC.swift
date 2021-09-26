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
    }
    
    // MARK: - Private Methods
    private func configureUI() {
        CustomView.createDesign(for: choozeDateBtn, with: .systemBlue, and: "Выбрать дату")
        CustomView.createDesign(for: calculateBtn, with: .systemGreen, and: "Разделить по тралам")
    }
}
// MARK: - TableViewDataSource
extension ByTrawlsVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIDs.byTrawlsCell.rawValue, for: indexPath)
        
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
