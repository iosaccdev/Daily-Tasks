//
//  TableView+Extensions.swift
//  WebviewTestTask
//
//  Created by Tania Harbarchuk on 19.01.2024.
//

import UIKit

extension UITableView {
    func register<T: UITableViewCell>(with cellType: T.Type) {
        register(UINib(nibName: String(describing: cellType), bundle: nil), forCellReuseIdentifier: String(describing: cellType))
    }
}
