//
//  DateVC.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 05.09.2021.
//

import UIKit

class DateVC: UIViewController {

    //@IBOutlet weak var datePicker: UIDatePicker!
    
    var delegate: DateVCDelegate!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        delegate.dateDidChanged(to: sender.date)
        dismiss(animated: true)
        
    }
}
