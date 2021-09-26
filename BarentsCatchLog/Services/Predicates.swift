//
//  Predicates.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 17.09.2021.
//

import Foundation
import CoreData

struct Predicates {
    static let shared = Predicates()
    
    func getPredicateFrom(name: String, grade: String, dateFrom: Date? = nil, dateTo: Date? = nil) -> [NSPredicate] {
        var predicates: [NSPredicate] = []
        let namePredicate = NSPredicate(format: "%K == %@", #keyPath(Fish.name), name)
        predicates.append(namePredicate)
        
        let gradePredicate = NSPredicate(format: "%K == %@", #keyPath(Fish.grade), grade)
        predicates.append(gradePredicate)
        
        if let dateFrom = dateFrom {
            let dateFrom = Calendar.current.startOfDay(for: dateFrom)
            let fromPredicate = NSPredicate(format: "date >= %@", dateFrom as NSDate)
            predicates.append(fromPredicate)
        }
        if let dateTo = dateTo {
            let dateToStart = Calendar.current.startOfDay(for: dateTo)
            let dateToEnd = Calendar.current.date(byAdding: .day, value: 1, to: dateToStart)
            let toPredicate = NSPredicate(format: "date < %@",  dateToEnd! as NSDate)
            predicates.append(toPredicate)
        }
        
        return predicates
    }
    func getNewPredicateFrom(name: String? = nil, grade: String? = nil, dateFrom: Date? = nil, dateTo: Date? = nil) -> [NSPredicate] {
        var predicates: [NSPredicate] = []
        if let name = name {
            let namePredicate = NSPredicate(format: "%K == %@", #keyPath(Fish.name), name)
            predicates.append(namePredicate)
        }
        if let grade = grade {
            let gradePredicate = NSPredicate(format: "%K == %@", #keyPath(Fish.grade), grade)
            predicates.append(gradePredicate)
        }
        
        if let dateFrom = dateFrom {
            let dateFrom = Calendar.current.startOfDay(for: dateFrom)
            let fromPredicate = NSPredicate(format: "date >= %@", dateFrom as NSDate)
            predicates.append(fromPredicate)
        }
        if let dateTo = dateTo {
            let dateToStart = Calendar.current.startOfDay(for: dateTo)
            let dateToEnd = Calendar.current.date(byAdding: .day, value: 1, to: dateToStart)
            let toPredicate = NSPredicate(format: "date < %@",  dateToEnd! as NSDate)
            predicates.append(toPredicate)
        }
        
        return predicates
    }
}
