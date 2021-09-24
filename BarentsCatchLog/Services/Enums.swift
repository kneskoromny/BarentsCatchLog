//
//  Helpers.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 28.08.2021.
//

enum IDs: String {
    case modelID = "BarentsCatchLog"
}
// для создания шаблонов
enum FishTypes: String {
    case cod = "Треска б/г мороженая"
    case haddock = "Пикша б/г мороженая"
}

enum Ratios: Double {
    case cod = 1.5
    case haddock = 1.4
}

enum Grades: String {
    case withoutGrade = "без навески"
}

enum DailyCatchVCStrings: String {
    case date = "Дата"
    case fish = "Объект"
    case grade = "Навеска"
}

enum SettingsListVCStrings: String {
    case userElements = "Пользовательские объекты промысла"
    case grade = "Навески"
}

enum ReportDescriptionVCStrings: String {
    case frzByGrades = "Готовая по навескам"
    case frzOnBoard = "Готовая всего"
    case raw = "Вылов"
    case frzSpecies = "Готовая по видам за период"
    case log = "Записи за период"
}

enum ReportTemplateIDs: String {
    case allFishForToday = "Все позиции за сегодня"
    case allFishForYesterday = "Вся позиции за вчера"
    case allFishForThisWeek = "Все позиции за эту неделю"
    case allCodForToday = "Вся треска за сегодня"
    case allCodForYesterday = "Вся треска за вчера"
    case allHaddockForToday = "Вся пикша за сегодня"
    case allHaddockForYesterday = "Вся пикша за вчера"
}

enum SegueIDs: String {
    case toFishChoice = "toFishNamesIdentifier"
    case toGradeChoice = "toGradeArrayIdentifier"
    case toDateFromChoice = "toDateFromIdentifier"
    case toDateToChoice = "toDateToIdentifier"
    case toReportChoice = "toReportChoiceTVC"
    case toReportDescription = "toReportDecriptionTVC"
}

enum CellIDs: String {
    case dailyCatchCell = "Cell"
    case gradeCell = "gradeCell"
    case fishCell = "fishCell"
    case reportCell = "reportCell"
    case reportChoiceCell = "reportChoiceCell"
    case reportDescriptionCell = "ReportDescriptionCell"
    case logCell = "logCell"
    case settingsListCell = "settingsListCell"
}
