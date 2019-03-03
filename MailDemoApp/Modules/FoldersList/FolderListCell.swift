//
//  FolderListCell.swift
//  MailDemoApp
//
//  Created by Azat Almeev on 23/02/2019.
//  Copyright © 2019 Azat Almeev. All rights reserved.
//

import UIKit

class FolderListCell: UITableViewCell {
    
    private (set) var folderId: String!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configured(with folder: MDFolder) -> Self {
        folderId = folder.id
        textLabel?.text = folder.title
        accessoryType = .disclosureIndicator
        return self
    }
}
