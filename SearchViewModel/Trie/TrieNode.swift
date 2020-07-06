//
//  TrieNode.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 06.07.2020.
//  Copyright © 2020 Nikita Konashenko. All rights reserved.
//

import Foundation

class TrieNode<Key: Hashable> {
  
  var key: Key?
  
  weak var parent: TrieNode?
  
  var children: [Key : TrieNode] = [:]
  
  var isTerminating = false
  
  var associatedValues: Set<ShopData>?
  
  init(key: Key?, parent: TrieNode?) {
    self.key = key
    self.parent = parent
  }
}
