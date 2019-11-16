//
//  HomeCellSectionData.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 16.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

struct HomeSectionData: Hashable {
    
    let sectionTitle: String
    let cells: [HomeCellData]
    
    let identifier = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
