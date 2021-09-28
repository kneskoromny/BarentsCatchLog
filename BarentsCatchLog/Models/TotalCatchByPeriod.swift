//
//  TotalCatchByPeriod.swift
//  BarentsCatchLog
//
//  Created by Кирилл Нескоромный on 28.09.2021.
//

import Foundation

struct TotalCatchByPeriod {
    var name: String?
    var onBoard: Double?
    var ratio: Double?
    var raw: Double {
        guard let onBoard = onBoard, let ratio = ratio else {
            return 0
        }
        return (onBoard * ratio).rounded()
    }
    func divideByTrawls(count: Int) -> [Double] {
        var inTrawlFishes: [Double] = []
        switch count {
        case 1:
            inTrawlFishes.append(raw)
        case 2:
            let trawl1 = (raw * 0.55).rounded()
            inTrawlFishes.append(trawl1)
            let trawl2 = raw - trawl1
            inTrawlFishes.append(trawl2)
        case 3:
            let trawl1 = (raw * 0.35).rounded()
            inTrawlFishes.append(trawl1)
            let trawl2 = (raw * 0.40).rounded()
            inTrawlFishes.append(trawl2)
            let trawl3 = raw - trawl1 - trawl2
            inTrawlFishes.append(trawl3)
        case 4:
            let trawl1 = (raw * 0.35).rounded()
            inTrawlFishes.append(trawl1)
            let trawl2 = (raw * 0.30).rounded()
            inTrawlFishes.append(trawl2)
            let trawl3 = (raw * 0.15).rounded()
            inTrawlFishes.append(trawl3)
            let trawl4 = raw - trawl1 - trawl2 - trawl3
            inTrawlFishes.append(trawl4)
        default:
            let trawl1 = (raw * 0.20).rounded()
            inTrawlFishes.append(trawl1)
            let trawl2 = (raw * 0.15).rounded()
            inTrawlFishes.append(trawl2)
            let trawl3 = (raw * 0.25).rounded()
            inTrawlFishes.append(trawl3)
            let trawl4 = (raw * 0.30).rounded()
            inTrawlFishes.append(trawl4)
            let trawl5 = raw - trawl1 - trawl2 - trawl3 - trawl4
            inTrawlFishes.append(trawl5)
        
        }
        return inTrawlFishes
    }
}
