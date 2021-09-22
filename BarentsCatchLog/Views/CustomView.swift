//
//  HeaderView.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 22.09.2021.
//

import UIKit

class CustomView: UIView {
    
    static func createViewForHeader(with width: CGFloat, and height: CGFloat, and title: String?) -> UIView {
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        let headerView = UIView(frame: frame)
        
        let nameLabel = UILabel()
        nameLabel.frame = CGRect(x: 20,
                                 y: 0,
                                 width: headerView.frame.width - 20,
                                 height: headerView.frame.height - 5)
        nameLabel.text = title
        nameLabel.font = .systemFont(ofSize: 20)
        nameLabel.textColor = .systemBlue
        
        headerView.addSubview(nameLabel)
        return headerView
    }

}
