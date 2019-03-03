//
//  ReusableViews.swift
//  MailDemoApp
//
//  Created by Azat Almeev on 23/02/2019.
//  Copyright © 2019 Azat Almeev. All rights reserved.
//

import UIKit

private extension UITableViewCell {
    
    class var selfName: String {
        let identifier = Bundle(for: self).bundleIdentifier?.components(separatedBy: ".").last ?? "MailDemoApp"
        return NSStringFromClass(self).replacingOccurrences(of: "\(identifier).", with: "")
    }
    
    class var cellIdentifier: String {
        return "\(selfName)Identifier"
    }
}

extension UITableView {
    
    func register<T: UITableViewCell>(with type: T.Type) {
        register(T.self, forCellReuseIdentifier: T.cellIdentifier)
    }
    
    func dequeue<T: UITableViewCell>(with type: T.Type) -> T {
        return dequeueReusableCell(withIdentifier: type.cellIdentifier) as! T
    }
}
