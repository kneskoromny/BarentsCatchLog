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
    private let fishKey = "fish"
    
    private init() {}
    // работа с навесками
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
    // работа с объектами промысла
    func fetchInputFishes() -> [InputFish] {
        guard let data = userDefaults.object(forKey: fishKey) as? Data else { return [] }
        guard let inputFishes = try? JSONDecoder().decode([InputFish].self, from: data) else {return [] }
        return inputFishes
    }
    func save(inputFish: InputFish) {
        var inputFishes = fetchInputFishes()
        inputFishes.append(inputFish)
        guard let data = try? JSONEncoder().encode(inputFishes) else { return }
        userDefaults.set(data, forKey: fishKey)
    }
    func deleteInputFish(at index: Int) {
        var inputFishes = fetchInputFishes()
        inputFishes.remove(at: index)
        guard let data = try? JSONEncoder().encode(inputFishes) else { return }
        userDefaults.set(data, forKey: fishKey)
    }
}
