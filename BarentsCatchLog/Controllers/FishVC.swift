//
//  FishTVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 06.09.2021.
//

import UIKit

class FishVC: UITableViewController {
    // MARK: - Public Properties
    var delegate: FishVCDelegate!
    
    // MARK: - Private Properties
    private var fishes: [InputFish] = []
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fishes = StorageManager.shared.fetchInputFishes()
    }
   
    // MARK: - Private Methods
    private func configure(for cell: UITableViewCell, with name: String) {
        cell.textLabel?.text = name
        cell.textLabel?.textColor = .systemGray
    }
    
    // MARK: - TableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fishes.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIDs.fishCell.rawValue, for: indexPath)
        let fish = fishes[indexPath.row]
        
        configure(for: cell, with: fish.fish)

        return cell
    }
    
    // MARK: - TableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fish = fishes[indexPath.row]
        delegate.fishDidChanged(to: fish)
        dismiss(animated: true)
    }
}
