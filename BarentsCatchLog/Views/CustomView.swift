//
//  HeaderView.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 22.09.2021.
//

import UIKit

class CustomView: UIView {
    
    static func createHeaderForReportDescriptionVC(with width: CGFloat, and height: CGFloat, and title: String?) -> UIView {
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
    
    static func createHeaderForLogVC(with width: CGFloat, height: CGFloat, day: String?, and month: String?) -> UIView {
        let headerView = UIView.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        
        let figureLabel = UILabel()
        figureLabel.frame = CGRect(x: 5, y: 0, width: 30, height: 20)
        if let day = day {
            figureLabel.text = day
        }
        figureLabel.textAlignment = .center
        figureLabel.font = .systemFont(ofSize: 16)
        figureLabel.textColor = .systemBlue
        
        let textLabel = UILabel()
        textLabel.frame = CGRect(x: 5, y: 20, width: 30, height: 20)
        if let month = month {
            if let monthFigure = Int(month) {
                textLabel.text = Arrays.shared.months[monthFigure - 1]
            }
        }
        textLabel.textAlignment = .center
        textLabel.font = .systemFont(ofSize: 14)
        textLabel.textColor = .systemBlue
        
        headerView.addSubview(textLabel)
        headerView.addSubview(figureLabel)
        
        return headerView
    }
    
    static func createDesign(for button: UIButton,
                             with color: UIColor,
                             and title: String) {
        button.layer.backgroundColor = color.cgColor
        button.layer.cornerRadius = button.frame.height / 3
        button.setTitleColor(.white, for: .normal)
        button.setTitle(title, for: .normal)
        
    
        button.layer.shadowColor = UIColor.systemGray.cgColor
        button.layer.shadowOffset = CGSize(width: 5, height: 5)
        button.layer.shadowRadius = 5
        button.layer.shadowOpacity = 1.0 
    
        
    }

}
