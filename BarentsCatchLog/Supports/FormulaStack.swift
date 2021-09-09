//
//  FormulaStack.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 08.09.2021.
//

import Foundation
import CoreData

struct FormulaStack {
    
    // получаем предикат по указанной дате
    func getDatePredicate(for dateFrom: Date) -> NSCompoundPredicate? {
        
        let dateFrom = Calendar.current.startOfDay(for: dateFrom)
        let dateTo = Calendar.current.date(byAdding: .day, value: 1, to: dateFrom)
        let fromPredicate = NSPredicate(format: "date >= %@", dateFrom as NSDate)
        let toPredicate = NSPredicate(format: "date < %@",  dateTo! as NSDate)
        return NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate, toPredicate])
    }
    // предикат по названию, градации и дате
    func getNameGradeDatePredicate(for name: String, grade: String, date: Date) -> NSCompoundPredicate? {
        
        let namePredicate = NSPredicate(format: "%K == %@", #keyPath(Fish.name), name)
        let gradePredicate = NSPredicate(format: "%K == %@", #keyPath(Fish.grade), grade)
        
        let dateFrom = Calendar.current.startOfDay(for: date)
        let dateTo = Calendar.current.date(byAdding: .day, value: 1, to: dateFrom)
        let fromPredicate = NSPredicate(format: "date >= %@", dateFrom as NSDate)
        let toPredicate = NSPredicate(format: "date < %@",  dateTo! as NSDate)
        return NSCompoundPredicate(andPredicateWithSubpredicates: [namePredicate, gradePredicate, fromPredicate, toPredicate])
    }
    
    
}

