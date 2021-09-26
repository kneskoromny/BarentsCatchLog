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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
