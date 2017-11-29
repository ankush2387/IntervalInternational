//
//  SimpleActionSheetViewModel.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/15/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

final public class SimpleActionSheetViewModel<T: UITableViewCell> where T: SimpleGenericTableViewCell {
    
    // MARK: - Public properties
    let cells: [T]
    let title: String
    let didCancel: (() -> Void)?
    let dataSource: SimpleGenericTableViewDataSource
    
    // MARK: - Lifecycle
    public init(cells: [T], heightForCells: CGFloat, title: String, didCancel: (() -> Void)? = nil, didSelectRow: @escaping (Int) -> Void) {
        self.cells = cells
        self.title = title
        self.didCancel = didCancel
        self.dataSource = SimpleGenericTableViewDataSource(cells: self.cells, heightForCells: heightForCells, didSelectRow: didSelectRow)
    }
}
