//
//  DealerFilter.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 10/5/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

struct DealerFilter {
    struct Selected {
        var brand: Brand?
        private var _model: String?
        var model: String? {
            return self._model
        }
        mutating func setModel(_ model: String?) -> Bool {
            guard let m = model,
                self.allModelsString != m else { return false }
            self._model = model
            return true
        }
        
        private var _year: String?
        var year: String? {
            return self._year
        }
        mutating func setYear(_ year: String?) -> Bool {
            guard let y = year,
                self.allYearsString != y else { return false }
            self._year = year
            return true
        }
        
        let allYearsString = "All Years"
        let allModelsString = "All Models"
        
        var hasAnySelected: Bool {
            return self.brand != nil ||
                self._model != nil ||
                self._year != nil
        }
    }
    
    var brands: [Brand]
    var models: [String]
    var years: [String]
    
    init(brands: [Brand], models: [String], years: [Int]) {
        self.selected = Selected()
        self.brands = brands
        self.models = ([self.selected.allModelsString] + models).filter { !$0.isEmpty }
        self.years = ([self.selected.allYearsString] + years.map { String($0) }).filter { !$0.isEmpty }
    }
    
    // MARK: - selected
    var selected: Selected
    var selectedIfNotEmpty: Selected? {
        guard self.hasAnySelected else { return nil }
        return self.selected
    }
    mutating func clearSelected() {
        self.selected = Selected()
    }
    mutating func apply(selected: Selected) {
        self.selected = selected
    }
    var hasAnySelected: Bool {
        return self.selected.hasAnySelected
    }
}
