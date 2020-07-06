//
//  Trie.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 06.07.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import Foundation

class Trie<CollectionType: Collection> where CollectionType.Element: Hashable {
  
  typealias Node = TrieNode<CollectionType.Element>
  
  private let root = Node(key: nil, parent: nil)
  
  init() {}
  
  func insert(_ collection: CollectionType, shop: ShopData) {
    var current = root
    
    for element in collection {
      if current.children[element] == nil {
        current.children[element] = Node(key: element, parent: current)
      }
      current = current.children[element]!
    }
    
    current.isTerminating = true
    
    if let _ = current.associatedValues {
      current.associatedValues?.insert(shop)
    } else {
      current.associatedValues = [shop]
    }
  }
  
  func contains(_ collection: CollectionType) -> Bool {
    var current = root
    
    for element in collection {
      guard let child = current.children[element] else {
        return false
      }
      current = child
    }
    return current.isTerminating
  }
  
  func remove(_ collection: CollectionType) {
    var current = root
    
    for element in collection {
      guard let child = current.children[element] else {
        return
      }
      current = child
    }
    
    guard current.isTerminating else {
      return
    }
    current.isTerminating = false
    
    while let parent = current.parent,
      current.children.isEmpty && !current.isTerminating {
        parent.children[current.key!] = nil
        current = parent
    }
  }
  
  subscript(collection: CollectionType) -> Set<ShopData>? {
    var current = root
    
    for element in collection {
      guard let child = current.children[element] else {
        return nil
      }
      current = child
    }
    
    return current.associatedValues
  }
}

  // MARK: - Prefix searches
extension Trie where CollectionType: RangeReplaceableCollection, CollectionType.Element == Character {
  
  func collections(startingWith prefix: CollectionType) -> [ShopData] {
    var current = root
    for element in prefix {
      guard let child = current.children[element] else {
        return []
      }
      current = child
    }
    
    return collections(startingWith: prefix, after: current)
      .sorted { lhs, rhs in
        let lhsHasPrefix = lhs.name.lowercased().starts(with: prefix)
        let rhsHasPrefix = rhs.name.lowercased().starts(with: prefix)
        
        if lhsHasPrefix, !rhsHasPrefix {
          return true
          
        } else if !lhsHasPrefix, rhsHasPrefix {
          return false
          
        } else {
          return lhs.name < rhs.name
        }
      }
  }
  
  private func collections(startingWith prefix: CollectionType, after node: Node) -> Set<ShopData> {
    var results = Set<ShopData>()
    
    if node.isTerminating,
      let values = node.associatedValues {
      results.formUnion(values)
    }
    
    for child in node.children.values {
      var prefix = prefix
      prefix.append(child.key!)
      results.formUnion(collections(startingWith: prefix, after: child))
    }
    
    return results
  }
}
