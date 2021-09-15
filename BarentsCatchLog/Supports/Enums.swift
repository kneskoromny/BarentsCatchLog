//
//  Helpers.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 28.08.2021.
//
import Foundation

enum FishTypes: String {
    case cod = "Треска б/г мороженая"
    case haddock = "Пикша б/г мороженая"
    case catfish = "Зубатка синяя б/г мороженая"
    case redfish = "Окунь золотистый б/г мороженый"
}

enum Ratios: Double {
    case cod = 1.5
    case haddock = 1.4
    case catfish = 1.65
    case redfish = 1.95
}

enum FishGrades: String {
    case lessThanHalf = "-0.5"
    case fromHalfToKilo = "0.5-1.0"
    case fromKiloToTwo = "1.0-2.0"
    case fromTwoToThree = "2.0-3.0"
    case fromThreeToFive = "3.0-5.0"
    case moreThanFive = "5.0+"
}

enum ReportTemplate {
    case template(id: String, grade: String, fish: String, dateFrom: Date, dateTo: Date)
}
