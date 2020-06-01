//
//  FilterInfo.swift
//  FearlessVideoFilter
//
//  Created by 김기현 on 2020/05/15.
//  Copyright © 2020 Hackday2020. All rights reserved.
//

import Foundation

// MARK: - FilterAPI
struct FilterAPI: Codable {
    let header: Header
    let body: FilterBody
}

struct FilterBody: Codable {
    let filters: [Filter]?
    let clipNo: Int?
}

struct Filter: Codable, Comparable {
    let filterSrl: Int?
    let startPosition: Int?
    let endPosition: Int?
    
    init(filterSrl: Int?, startPosition: Int?, endPosition: Int?) {
        self.filterSrl = filterSrl
        self.startPosition = startPosition
        self.endPosition = endPosition
    }
    
    static func < (lhs: Filter, rhs: Filter) -> Bool {
        if let left = lhs.startPosition,
            let right = rhs.startPosition,
            left < right {
            return true
        }
        return false
    }
    
    // 해당 시간(초)에 해당하는 필터 구간을 binary search로 찾아서 리턴.
    // 반드시 postprocessedData()로 데이터 후처리 후에 호출할 것.
    static func filteringSection(at seconds: Double, of filterArray: [Filter]) -> (Double, Double)? {
        var lowIndex = 0
        var highIndex = filterArray.count - 1
        
        while lowIndex <= highIndex {
            let midIndex = (lowIndex + highIndex) / 2
            guard let start = filterArray[midIndex].startPosition,
                let end = filterArray[midIndex].endPosition else { return nil }
            
            if seconds > Double(start) && seconds < Double(end) {
                return (Double(start), Double(end))
            } else if seconds < Double(start) {
                highIndex = midIndex - 1
            } else {
                lowIndex = midIndex + 1
            }
        }
        return nil
    }
    
    // 필터 구간들의 배열을 오름차순 정렬하고 invalid한 필터 구간을 제거한 배열을 리턴.
    static func postprocessedData(filterArray: [Filter]) -> [Filter] {
        let sortedFilters = filterArray.sorted()
        let validFilters = removeInvalidData(filterArray: sortedFilters)
        let processedFilters = combineOverlappingData(filterArray: validFilters)
        return processedFilters
    }
    
    static private func removeInvalidData(filterArray: [Filter]) -> [Filter] {
        return filterArray.compactMap {
            if let start = $0.startPosition,
                let end = $0.endPosition,
                start < end {
                return $0
            }
            return nil
        }
    }
    
    static private func combineOverlappingData(filterArray: [Filter]) -> [Filter] {
        if filterArray.isEmpty {
            return filterArray
        }
        
        var index = 1
        var processedFilters: [Filter] = []
        var tempFilter: Filter = filterArray[0]
        
        while (index < filterArray.count) {
            if let prevStart = tempFilter.startPosition,
                let prevEnd = tempFilter.endPosition,
                let nextStart = filterArray[index].startPosition,
                var nextEnd = filterArray[index].endPosition,
                prevEnd > nextStart {
                
                if prevEnd > nextEnd {
                    nextEnd = prevEnd
                }
                let combinedFilter = Filter(filterSrl: tempFilter.filterSrl, startPosition: prevStart, endPosition: nextEnd)
                tempFilter = combinedFilter
                index += 1
            } else {
                processedFilters.append(tempFilter)
                tempFilter = filterArray[index]
                index += 1
            }
        }
        processedFilters.append(tempFilter)
        
        return processedFilters
    }
}
