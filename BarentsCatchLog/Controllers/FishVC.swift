//
//  FishTVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 06.09.2021.
//

import UIKit

class FishVC: UITableViewController {
    // MARK: - Public Properties
    var delegate: FishTVCDelegate!
    
    // MARK: - Private Properties
    private var fishes = [FishTypes.cod.rawValue,
                          FishTypes.haddock.rawValue,
                          FishTypes.catfish.rawValue,
                          FishTypes.redfish.rawValue]
   
    // MARK: - Private Methods
    private func configure(for cell: UITableViewCell, with fish: String) {
        cell.textLabel?.text = fish
        cell.textLabel?.textColor = .systemGray
    }
    
    // MARK: - TableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fishes.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIDs.fishCell.rawValue, for: indexPath)
        let fish = fishes[indexPath.row]
        
        configure(for: cell, with: fish)

        return cell
    }
    
    // MARK: - TableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fish = fishes[indexPath.row]
        delegate.fishDidChanged(to: fish)
        dismiss(animated: true)
    }
}
