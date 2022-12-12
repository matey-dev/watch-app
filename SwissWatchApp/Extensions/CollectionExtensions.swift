//
//  CollectionExtensions.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/10/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return self.indices.contains(index) ? self[index] : nil
    }
    
    func firstElement<T>(_: T.Type) -> T? {
        return self.first(where: { $0 is T }) as? T
    }
}

extension Array where Element: Equatable {
    mutating func append(unique item: Element) {
        guard
            !self.contains(item)
            else { return }
        self.append(item)
    }
}

extension Array where Element: Hashable {
    func dict(values: [Any]) -> [AnyHashable: Any]? {
        return self.count == values.count
            ? Dictionary(uniqueKeysWithValues: zip(self, values))
            : nil
    }
    
    mutating func subtract(_ elements: [Element?]?) {
        self.removeAll(where: { elements?.contains($0) ?? false })
    }
    
    func subtracted(_ elements: [Element?]?) -> [Element] {
        var copySelf = self
        copySelf.subtract(elements)
        return copySelf
    }
}

extension Sequence where Element: Hashable {
    func containsAll(_ elements: [Element]) -> Bool {
        return Set(elements).isSubset(of: Set(self))
    }
    
    func containsAnyOf(_ elements: [Element]) -> Bool {
        return !Set(self).intersection(Set(elements)).isEmpty
    }
}

extension Array where Element: Hashable {
    mutating func makeUnique() {
        self = Array(Set(self))
    }
    
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            if !uniqueValues.contains(item) {
                uniqueValues += [item]
            }
        }
        return uniqueValues
    }
}
