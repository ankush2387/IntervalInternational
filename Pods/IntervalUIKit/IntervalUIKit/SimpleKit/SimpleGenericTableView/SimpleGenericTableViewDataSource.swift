//
//  SimpleGenericTableViewDataSource.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/14/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

final class SimpleGenericTableViewDataSource: NSObject {
    
    // MARK: - Public properties
    let heightForCells: CGFloat
    let cells: [UITableViewCell]
    
    // MARK: - Private properties
    fileprivate let didSelectRow: (Int) -> Void
    
    // MARK: - Lifecycle
    init(cells: [UITableViewCell], heightForCells: CGFloat, didSelectRow: @escaping (Int) -> Void) {
        self.cells = cells
        self.didSelectRow = didSelectRow
        self.heightForCells = heightForCells
    }
}

extension SimpleGenericTableViewDataSource: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let simpleActionSheetTableViewCell = cells[indexPath.row] as? SimpleGenericTableViewCell,
            let cell = tableView.dequeueReusableCell(withIdentifier: simpleActionSheetTableViewCell.identifier, for: indexPath) as? SimpleGenericTableViewCell else {
            return UITableViewCell()
        }

        cell.setUI(for: indexPath.row)
        guard let tableViewCell = cell as? UITableViewCell else { return UITableViewCell() }
        return tableViewCell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightForCells
    }
}

extension SimpleGenericTableViewDataSource: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectRow(indexPath.row)
    }
}
