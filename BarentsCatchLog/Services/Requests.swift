//
//  Requests.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 17.09.2021.
//

import Foundation
import CoreData

struct Requests {
    
    var coreDataStack = CoreDataStack(modelName: IDs.modelID.rawValue)
    static let shared = Requests()
    
    func getAllElementsRequest() -> [Fish] {
        var elements: [Fish] = []
        
        let fetchRequest: NSFetchRequest<Fish> = Fish.fetchRequest()
        do {
            elements = try coreDataStack.managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
        return elements
    }
    
    // запрос на подсчет аттрибута frzPerDay по указанному типу рыбы
    func getAttributeCountRequest(for fish: String, and grade: String) -> Int {
        var result = 0
        let countRequest = NSFetchRequest<NSDictionary>(entityName: "Fish")
        
        let predicatesForCount = Predicates.shared.getPredicateFrom(name: fish, grade: grade)
        let predicateForCount = NSCompoundPredicate(andPredicateWithSubpredicates: predicatesForCount)
        countRequest.predicate = predicateForCount
        
        countRequest.resultType = .dictionaryResultType
        
        let sumExpressionDesc = NSExpressionDescription()
        sumExpressionDesc.name = "sumFrz"
        let specialCountExp = NSExpression(forKeyPath: #keyPath(Fish.perDay))
        sumExpressionDesc.expression = NSExpression(forFunction: "sum:",
                                                    arguments: [specialCountExp])
        sumExpressionDesc.expressionResultType = .integer32AttributeType
        countRequest.propertiesToFetch = [sumExpressionDesc]
      
        do {
          let results =
            try coreDataStack.managedContext.fetch(countRequest)
          let resultDict = results.first
          result = resultDict?["sumFrz"] as? Int ?? 0
            print("This is sumFrzPerDay: \(String(describing: result))")
          
        } catch let error as NSError {
          print("count not fetched \(error), \(error.userInfo)")
        }
        return result
    }
    // запрос на наличие экземпляра
    func getElementAvailabilityRequest(for fish: String, grade: String, dateFrom: Date, dateTo: Date) -> Fish? {
        var result: Fish?
        let fetchRequest: NSFetchRequest<Fish> = Fish.fetchRequest()
        let predicatesForCatchBeforeInput = Predicates.shared.getPredicateFrom(name: fish,
                                                       grade: grade,
                                                       dateFrom: dateFrom,
                                                       dateTo: dateTo)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicatesForCatchBeforeInput)
        fetchRequest.predicate = predicate
        
        do {
            result = try coreDataStack.managedContext.fetch(fetchRequest).first
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
        return result
    }
    // запрос на всю рыбу за один день
    func getAllElements(for date: Date) -> [Fish] {
        var elements: [Fish] = []
        
        let fetchRequest: NSFetchRequest<Fish> = Fish.fetchRequest()
        let predicatesForCatch = Predicates.shared.getNewPredicateFrom(dateFrom: date, dateTo: date)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicatesForCatch)
        fetchRequest.predicate = predicate
        
        do {
            elements = try coreDataStack.managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
        return elements
        
    }
    
    
}
