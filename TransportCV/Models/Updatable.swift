//
//  Updatable.swift
//  TransportCV
//
//  Created by Stanislav on 05.02.2020.
//  Copyright © 2020 OrbitalMan. All rights reserved.
//

import Foundation

protocol Updatable: AnyObject, Equatable {
    func update(with new: Self)
    func mayBeObsolete(with another: Self) -> Bool
}

extension Updatable {
    
    func mayBeObsolete(withOptional another: Self?) -> Bool {
        guard let another = another else { return true }
        return mayBeObsolete(with: another)
    }
    
}

extension Array where Element: Updatable {
    
    mutating func update(newElements: [Element],
                         onRemoving: (Element) -> () = { _ in },
                         onAdding: (Element) -> () = { _ in }) {
        var obsoleteElements: [Element] = []
        var addedElements = newElements
        for element in self {
            var updated = false
            let mayBeObsolete = element.mayBeObsolete(withOptional: newElements.first)
            for newElement in addedElements {
                if element == newElement {
                    if !(element === newElement) {
                        element.update(with: newElement)
                    }
                    addedElements.remove(at: addedElements.firstIndex(of: newElement)!)
                    updated = true
                    break
                }
            }
            if !updated, mayBeObsolete {
                obsoleteElements.append(element)
            }
        }
        obsoleteElements.forEach(onRemoving)
        removeAll(where: obsoleteElements.contains)
        append(contentsOf: addedElements)
        addedElements.forEach(onAdding)
    }
    
}

