//
//  tst.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 17.11.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

func createLayout() -> UICollectionViewLayout {
    let layout = UICollectionViewCompositionalLayout {
        (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

        let leadingItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7),
                                              heightDimension: .fractionalHeight(1.0)))
        leadingItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

        let trailingItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(0.3)))
        trailingItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        let trailingGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3),
                                              heightDimension: .fractionalHeight(1.0)),
            subitem: trailingItem, count: 2)

        let nestedGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(0.4)),
            subitems: [leadingItem, trailingGroup])
        let section = NSCollectionLayoutSection(group: nestedGroup)
        return section

    }
    return layout
}
