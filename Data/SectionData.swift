//
//  HomeCellSectionData.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 16.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class SectionData {
    
    let sectionTitle: String
    var cells: [CellData]
    let identifier = UUID()
    
    init(sectionTitle: String, cells: [CellData]) {
        self.sectionTitle = sectionTitle
        self.cells = cells
    }
    
    convenience init(sectionTitle: String) {
        self.init(sectionTitle: sectionTitle, cells: [])
    }
}

// MARK: - Hashable
extension SectionData: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: SectionData, rhs: SectionData) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
