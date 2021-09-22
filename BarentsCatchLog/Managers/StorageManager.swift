//
//  StorageManager.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 22.09.2021.
//

import Foundation

class StorageManager {
    
    static let shared = StorageManager()
    
    private let userDefaults = UserDefaults.standard
    private let gradeKey = "grade"
    
    private init() {}
    
    func fetchGrades() -> [String] {
            if let grades = userDefaults.value(forKey: gradeKey) as? [String] {
                return grades
            }
            return []
        }
    func save(grade: String) {
            var grades = fetchGrades()
            grades.append(grade)
            userDefaults.set(grades, forKey: gradeKey)
        }
    func deleteGrade(at index: Int) {
            var grades = fetchGrades()
            grades.remove(at: index)
            userDefaults.set(grades, forKey: gradeKey)
        }
}
