//
//  DateVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 05.09.2021.
//

import UIKit

class DateVC: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // MARK: - Public properties
    var delegate: DateVCDelegate!
    var choozenDate: Date!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.date = choozenDate
    }
    // MARK: - IB Actions
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        delegate.dateDidChanged(to: sender.date)
        dismiss(animated: true)
        
    }
}
